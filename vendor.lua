-- Vending Machine Software V2 by BlackDragon_B and znepb
local config = require("config")
local turtleNetworkID = config.turtleNetworkID

local waitTime = 1

local mon = peripheral.find("monitor")
local speaker = peripheral.find("speaker")
local chest = peripheral.find("minecraft:ender chest")

local function default()
    mon.setTextColor(colors.lightGray)
    mon.setBackgroundColor(colors.gray)
    mon.setTextScale(0.5)
    mon.clear()
    mon.setCursorPos(2, 4)
    mon.write("Free Computer")
    mon.setCursorPos(3, 7)
    mon.write("Click here!")
end

local function sleeping()
    mon.setTextColor(colors.lightGray)
    mon.setBackgroundColor(colors.gray)
    mon.clear()
    mon.setCursorPos(3, 5)
    mon.write("Please wait")
end

local function getFirst() -- Just to get first item in a chest
    local items = chest.list()
    for i, v in pairs(items) do
        return i
    end
    return
end

while true do
    default()
    speaker.playSound("entity.experience_orb.pickup", 1, 1)

    -- Pull a chest into turtles first slot
    if turtle.getItemCount(1) == 0 then
        chest.pushItems("turtle_" .. tostring(turtleNetworkID), getFirst(), 1, 1)
    end

    -- Wait until monitor is touched
    os.pullEvent("monitor_touch")

    -- Drop the computer
    turtle.drop(1)

    speaker.playSound("entity.player.levelup", 1, 1)

    -- Wait 30 seconds before next drop
    sleeping()
    sleep(waitTime)
end