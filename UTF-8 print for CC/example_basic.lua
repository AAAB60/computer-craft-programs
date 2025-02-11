---@module "cctAPI"
local monitor = peripheral.find("monitor")
local computer = term.redirect(monitor)

-- suggested
monitor.setTextScale(0.5)

term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.clear()
term.setCursorPos(1, 1)

local function pirntBorderNum()
    local termWidth, termHeight = term.getSize()
    local n = math.floor((termWidth - 1) / 10) + 1
    local str = "0123456789"
    local tc = string.rep("48", 5)
    local bc = string.rep("84", 5)
    term.setCursorPos(1, 1)

    for i = 1, n do
        term.blit(str, tc, bc)
    end
    local num = 1
    local colorToggle = false
    term.setCursorPos(1, 2)
    for y = 2, termHeight do
        term.setCursorPos(1, y)
        if colorToggle then
            term.setBackgroundColor(colors.lightGray)
            term.setTextColor(colors.yellow)
            colorToggle = false
        else
            term.setBackgroundColor(colors.yellow)
            term.setTextColor(colors.lightGray)
            colorToggle = true
        end
        term.write(tostring(num))

        num = num + 1
        if num == 10 then
            num = 0
        end
    end
    term.setCursorPos(2, 2)
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
end
pirntBorderNum()
local M = require("utf8textutils")

-- NOTION:
--     CC compiler reads utf8 code as '?'
--     "print("你好世界")" will act the same as "print("????")"
--     read file in "rb" mode instead
local file = fs.open("text", "rb")
M.printUtf8(file.readLine())

local cfg1 = M.getCfg()
cfg1.fontFamily = M.getFontFamily("fonts/fusion-pixel-8px-proportional-zh_hans")
cfg1.textColor = colors.blue
cfg1.backgroundColor = colors.green
cfg1.autoWrapMode = "b"

M.printUtf8(M.sub(file.readLine(), 3, -1), cfg1)

local samplestr = "abcdefghijklmnopqrstuvwxyz"
local samplestr2 = samplestr:upper()
local samplestr1 = "0123456789"
cfg1.fontFamily = M.getFontFamily("fonts/fusion-pixel-12px-proportional-zh_hans")
--only if no utf8 character in str
M.printUtf8(samplestr, cfg1)
M.printUtf8(samplestr2, cfg1)
M.printUtf8(samplestr1, cfg1)