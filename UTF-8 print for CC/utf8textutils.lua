---@module "cctAPI"

---example:
---```
---for pos, code in codes("你好world") do
---    print(pos, code)
---end
------>
---1	20320
---4	22909
---7	119
---8	111
---9	114
---10	108
---11	100
---```
---@param str string
---@return fun():pos:integer, code:integer
local function codes(str)
    local len = #str
    local i = 0

    local function illegalChar()
        error("Illegal UTF-8 character at position " .. tostring(i))
    end

    return function()
        i = i + 1
        ---@diagnostic disable-next-line
        if i > len then return end

        local pos = i
        local byte = string.byte(str, i)

        -- Single-byte character
        if byte < 0x80 then
            return pos, byte

            -- Multi-byte sequences
        elseif byte >= 0xC0 then
            local bytes_remaining, code = 0, 0

            if byte < 0xE0 then -- 2-byte sequence
                bytes_remaining = 1
                code = byte - 0xC0
            elseif byte < 0xF0 then -- 3-byte sequence
                bytes_remaining = 2
                code = byte - 0xE0
            elseif byte < 0xF8 then -- 4-byte sequence
                bytes_remaining = 3
                code = byte - 0xF0
            else
                illegalChar()
            end

            -- Validate remaining bytes
            if i + bytes_remaining > len then
                illegalChar()
            end

            -- Calculate code point
            for j = 1, bytes_remaining do
                i = i + 1
                local next_byte = string.byte(str, i)
                if next_byte < 0x80 or next_byte >= 0xC0 then
                    illegalChar()
                end
                code = code * 0x40 + (next_byte - 0x80)
            end

            return pos, code
        else
            illegalChar()
            ---@diagnostic disable-next-line
        end
    end
end

---@type FontFamily
local defaultFontFamily = {
    maxHeight = 4,
    [1] = require("fonts/fusion-pixel-12px-proportional-zh_hans")
}

---@param str string read in `"rb"` mode from file
---@param nStartPos integer? 1~n, -n~-1 to represent pos reverse
---@param nEndPos integer?   1~n, -n~-1 to represent pos reverse
---@return string substring sub string of utf8 character from `nStartPos` to `nEndPos`
local function sub(str, nStartPos, nEndPos)
    local charPos = 0
    local utf8charPosToStr = {}

    for pos, _ in codes(str) do
        charPos = charPos + 1
        utf8charPosToStr[charPos] = pos
    end

    nStartPos = nStartPos or 1
    nEndPos = nEndPos or charPos
    nStartPos = nStartPos < 0 and math.max(1, charPos + nStartPos + 1) or math.min(charPos, nStartPos)
    nEndPos = nEndPos < 0 and math.max(1, charPos + nEndPos + 1) or math.min(charPos, nEndPos)

    local startByte = utf8charPosToStr[nStartPos]
    local endByte = utf8charPosToStr[nEndPos + 1] and utf8charPosToStr[nEndPos + 1] - 1 or #str
    return string.sub(str, startByte, endByte)
end

---@class FontFamily
---@field maxHeight integer
---@diagnostic disable-next-line
---@field [integer] Font get from `require(font_name)`

---@param ... string module names of font, font should be
---@return FontFamily
local function getFontFamily(...)
    local fonts = { maxHeight = 0 }

    for i, path in ipairs({ ... }) do
        if not fs.exists(path .. ".lua") then
            error("Font module not found: " .. path)
        end

        local font = require(path)
        if not font[72] then
            error("'H'(ascII:72) not found in font  " .. path)
        end

        fonts[i] = font
        fonts.maxHeight = math.max(fonts.maxHeight, #font[72])
    end

    return fonts
end
---@alias bitmap string[] the bitmap of a character

---@param code integer
---@param fontFamily FontFamily
---@return bitmap
local function getCharMap(code, fontFamily)
    local cm
    for _, font in ipairs(fontFamily) do
        cm = font[code]
        if cm then
            return cm
        end
    end
    error(("char of utf8 %d is not supported"):format(code))
end

---@class Config
---@field fontFamily FontFamily?
---@field textColor number?
---@field backgroundColor number?
---@field masking [integer, integer, integer, integer]?
---@field autoScroll boolean
---@field autoNewLine boolean
---@field autoWrapMode "n"|"b"|"-"?
---@field autoWrapLen integer?
---@field avoidBorder boolean
---@field tabLen integer?

---@see Config
---@param preset "noauto"?
---@return Config
local function getCfg(preset)
    ---@type Config
    local base = {
        fontFamily = defaultFontFamily,
        textColor = nil,
        backgroundColor = nil,
        masking = nil,
        autoScroll = true,
        autoNewLine = true,
        autoWrapMode = "b",
        autoWrapLen = nil,
        avoidBorder = true,
        tabLen = 2
    }
    if preset == "noauto" then
        base.autoScroll = false
        base.autoNewLine = false
        base.autoWrapMode = "n"
    end
    return base
end


---`str` should be read in `"rb"` mode from file <br>
---`cfg` see [`getCfg()`](lua://Config)
---### Config
---- **textColor**
---- **backgroundColor**
---- **fontFamily** use [`getFontFamily()`](lua://FontFamily) to modify
---- **masking** representing x1, y1, x2, y2 of 2 coordinates, concent out of the rectange range won't print
---- **autoScroll** if true, if next line is over-height, [`term.scroll()`](https://tweaked.cc/module/term.html#v:scroll) will be called, masking will also be scrolled
---- **autoNewLine** if true, the output will be like a `\n` added to the end
---- **autoWrapMode** <br>
----- `"n"` do not auto wrap<br>
----- `"b"` English letter will not be broken<br>
----- `"-"` English letter will be broken by a `'-'`<br>
---here 'letter' matches regex `(?<![a-zA-Z'])[a-zA-Z']+-?`<br>
---actually realized avoid using `luautf8` or regex matching
---- **autoWrapLen** the maximum distance a line goes from the terminal's left
---- **avoidBorder** if true, autoScroll and autoWrap will avoid printing border pixels, which have render issue<br>
---for example, autoWrap will start new line at pos (2, y) instead of (1, y)
---- **tabLen** the count of `' '` to replace `'\t'`
---@param str string
---@param cfg Config?
local function printUtf8(str, cfg)
    local cursorX, cursorY = term.getCursorPos()
    local termWidth, termHeight = term.getSize()

    local cfg = cfg or getCfg()
    local oriTextColor, oriBackgroundColor = term.getTextColor(), term.getBackgroundColor()
    local textColor = cfg.textColor or oriTextColor
    local backgroundColor = cfg.backgroundColor or oriBackgroundColor
    local masking = cfg.masking
    local autoScroll = cfg.autoScroll or true
    local autoNewLine = cfg.autoNewLine
    local autoWrapMode = cfg.autoWrapMode or "b"
    local autoWrapLen = cfg.autoWrapLen or termWidth
    local avoidBorder = cfg.avoidBorder
    local fontFamily = cfg.fontFamily or defaultFontFamily
    local tabLen = cfg.tabLen or 2
    str = string.gsub(str, '\t', string.rep(" ", tabLen))
    local fontHeight = fontFamily.maxHeight
    if avoidBorder and autoWrapMode ~= "n" then
        autoWrapLen = math.min(termWidth - 1, autoWrapLen)
        cursorX = math.max(2, cursorX)
        cursorY = math.max(2, cursorY)
    end
    local maxHeight = avoidBorder and termHeight - 1 or termHeight
    ---@type integer[]
    local letterBuffer = {}
    local dashWidth = #getCharMap(45, fontFamily)[1]
    ---@type { pos: [integer, integer], code: integer }[]
    local charBuffer = {}
    
    ---@param x integer
    ---@param y integer
    ---@return boolean
    local function bInMasking(x, y)
        ---@diagnostic disable-next-line
        return x >= masking[1] and x <= masking[3] and y >= masking[2] and y <= masking[4]
    end
    ---add new line to charBuffer
    local function posNewLine()
        cursorX = avoidBorder and 2 or 1
        if autoScroll and cursorY + fontHeight > maxHeight then
            -- scroll term and masking
            term.scroll(fontHeight)
            for _, char in ipairs(charBuffer) do
                char.pos[2] = char.pos[2] - fontHeight
            end
            if masking then
                masking[2] = masking[2] - fontHeight
                masking[4] = masking[4] - fontHeight
            end
        else
            cursorY = cursorY + fontHeight
        end
    end
    ---print char in charBuffer
    local function printChar()
        local bIsLastReversed = false
        term.setTextColor(textColor)
        term.setBackgroundColor(backgroundColor)
        for _, char in ipairs(charBuffer) do
            ---@type bitmap
            local charMap
            local code = char.code
            for _, font in ipairs(fontFamily) do
                if font[code] then
                    charMap = font[code]
                    break
                end
            end

            local width, height = #charMap[1], #charMap
            local cursorX, cursorY = unpack(char.pos)
            if height < fontHeight then
                if bIsLastReversed then
                    bIsLastReversed = false
                    term.setTextColor(textColor)
                    term.setBackgroundColor(backgroundColor)
                end
                for _ = 1, fontHeight - height do
                    term.setCursorPos(cursorX, cursorY)
                    term.write(string.rep(" ", width))
                    cursorY = cursorY + 1
                end
            end
            for y = 1, height do
                local posY = cursorY + y - 1
                term.setCursorPos(cursorX, posY)
                local sCharMapBuffer = charMap[y]
                for x = 1, width do
                    if not masking or bInMasking(cursorX + x - 1, posY) then
                        local code = string.byte(sCharMapBuffer, x)
                        if code < 128 then
                            code = code + 128
                            if not bIsLastReversed then
                                bIsLastReversed = true
                                term.setTextColor(backgroundColor)
                                term.setBackgroundColor(textColor)
                            end
                        else
                            if bIsLastReversed then
                                bIsLastReversed = false
                                term.setTextColor(textColor)
                                term.setBackgroundColor(backgroundColor)
                            end
                        end
                        term.write(string.char(code))
                    else
                        term.setCursorPos(cursorX + x, posY)
                    end
                end
            end
        end
        term.setTextColor(oriTextColor)
        term.setBackgroundColor(oriBackgroundColor)
        if autoNewLine then
            term.setCursorPos(1, cursorY + fontHeight)
        else
            term.setCursorPos(cursorX, cursorY)
        end
    end
    local bIsLetter = false
    local function releaseLetter()
        if bIsLetter then
            if autoWrapMode == "-" then
                local widthSum = cursorX - 1
                local widthBuffer = {}
                for index, letter in ipairs(letterBuffer) do
                    widthBuffer[index] = #getCharMap(letter, fontFamily)[1]
                end
                local ind = 1
                local letterBufferLen = #letterBuffer
                local lastDashPos = 1


                while ind <= letterBufferLen do
                    widthSum = widthSum + widthBuffer[ind]
                    if widthSum > autoWrapLen then
                        while widthSum + dashWidth > autoWrapLen do
                            if ind == lastDashPos then
                                -- when have to insert dash in the first character, posNewLine() or throw
                                if ind == 1 and cursorX ~= (avoidBorder and 2 or 1) then
                                    widthSum = 0
                                else
                                    error("dash too wide or autoWrapLen too small")
                                end
                            end
                            widthSum = widthSum - widthBuffer[ind]
                            ind = ind - 1
                        end
                        -- pos letters before dash
                        for i = lastDashPos, ind do
                            charBuffer[#charBuffer + 1] = {
                                pos = { cursorX, cursorY },
                                code = letterBuffer[i]
                            }
                            cursorX = cursorX + widthBuffer[i]
                        end
                        if widthSum >= 0 then
                            -- add dash
                            charBuffer[#charBuffer + 1] = {
                                pos = { cursorX, cursorY },
                                code = 45
                            }
                        end
                        -- reset
                        widthSum = 0
                        lastDashPos = ind + 1
                        posNewLine()
                    end
                    ind = ind + 1
                end
                -- pos letters after dash
                for i = lastDashPos, letterBufferLen do
                    charBuffer[#charBuffer + 1] = {
                        pos = { cursorX, cursorY },
                        code = letterBuffer[i]
                    }
                    cursorX = cursorX + widthBuffer[i]
                end
            elseif autoWrapMode == "b" then
                local widthSum = cursorX - 1
                local widthBuffer = {}
                local ind = 1
                local letterBufferLen = #letterBuffer
                while ind <= letterBufferLen do
                    local charMapWidth = #getCharMap(letterBuffer[ind], fontFamily)[1]
                    widthBuffer[ind] = charMapWidth
                    widthSum = widthSum + charMapWidth
                    ind = ind + 1
                end

                local forceNewLineFlag = false
                if widthSum > autoWrapLen then
                    if cursorX == (avoidBorder and 2 or 1) then
                        forceNewLineFlag = true
                    else
                        widthSum = widthSum - cursorX + 1
                        if widthSum > autoWrapLen then
                            forceNewLineFlag = true
                        else
                            posNewLine()
                        end
                    end
                end
                if forceNewLineFlag then
                    for i = 1, letterBufferLen do
                        if cursorX + widthBuffer[i] > autoWrapLen then
                            posNewLine()
                        end
                        charBuffer[#charBuffer + 1] = {
                            pos = { cursorX, cursorY },
                            code = letterBuffer[i]
                        }
                        cursorX = cursorX + widthBuffer[i]
                    end
                else
                    for i = 1, letterBufferLen do
                        charBuffer[#charBuffer + 1] = {
                            pos = { cursorX, cursorY },
                            code = letterBuffer[i]
                        }
                        cursorX = cursorX + widthBuffer[i]
                    end
                end
            elseif autoWrapMode == "n" then
                for _, letter in ipairs(letterBuffer) do
                    charBuffer[#charBuffer + 1] = {
                        pos = { cursorX, cursorY },
                        code = letter
                    }
                    cursorX = cursorX + #getCharMap(letter, fontFamily)[1]
                end
            end
            letterBuffer = {}
            bIsLetter = false
        end
    end

    local lastLR = false
    for _, code in codes(str) do
        -- handle break line, \r, \n and \r\n will be transferred
        if code == 13 then
            releaseLetter()
            lastLR = true
            posNewLine()
        elseif code == 10 and not lastLR then
            lastLR = false
            releaseLetter()
            posNewLine()

            -- record letter for break line
        elseif code == 45 and bIsLetter then
            lastLR = false
            letterBuffer[#letterBuffer + 1] = code
            releaseLetter()
        elseif code >= 65 and code <= 90 or (code >= 97 and code <= 122) or code == 39 then
            lastLR = false
            letterBuffer[#letterBuffer + 1] = code
            bIsLetter = true

            -- pos char
        else
            lastLR = false
            releaseLetter()
            local charMapWidth = #getCharMap(code, fontFamily)[1]
            if autoWrapMode ~= "n" and cursorX + charMapWidth - 1 > autoWrapLen then
                posNewLine()
            end
            charBuffer[#charBuffer + 1] = {
                pos = { cursorX, cursorY },
                code = code
            }
            cursorX = cursorX + charMapWidth
        end
    end
    releaseLetter()
    printChar()
end
return {
    codes = codes,
    printUtf8 = printUtf8,
    getFontFamily = getFontFamily,
    sub = sub,
    getCfg = getCfg,
    getCharMap = getCharMap
}
