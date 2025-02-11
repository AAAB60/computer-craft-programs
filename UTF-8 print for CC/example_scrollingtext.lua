---@module "cctAPI"
local monitor = peripheral.find("monitor")
local computer = term.redirect(monitor)

-- suggested
monitor.setTextScale(0.5)

term.clear()
term.setCursorPos(1, 1)

local M = require("utf8textutils")

---@param str string
---@param fps number films per second
local function pirntScrolling(str, fps)
    str = str .. " "
    local termWidth = term.getSize()
    local cfg1 = M.getCfg("noauto")
    cfg1.masking = { 2, 2, termWidth - 1, cfg1.fontFamily.maxHeight + 1 }

    local spf = 1 / fps
    ---@type FontFamily
    local fontFamily = cfg1.fontFamily
    local wid = 0
    for _, code in M.codes(str) do
        local bm = M.getCharMap(code, fontFamily)
        wid = wid + #bm[1]
    end

    local cursorX = 2
    local cursorY = 2
    local maskingWidth = cfg1.masking[3] - cfg1.masking[1]
    local repeatNum = math.max(maskingWidth, wid)
    while true do
        cursorX = 2
        for i = 1, repeatNum do
            term.setCursorPos(cursorX, cursorY)
            M.printUtf8(str, cfg1)

            term.setCursorPos(cursorX + repeatNum, cursorY)
            M.printUtf8(str, cfg1)
            cursorX = cursorX - 1

            os.sleep(spf)
        end
    end
end

pirntScrolling("hello  -- by AAAB60", 5)
