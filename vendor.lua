-- Vending Machine Software V4 by BlackDragon_B and znepb

local config = require("config")
local turtleNetworkID = config.turtleNetworkID

local waitTime = 15

local mon = peripheral.find("monitor")
local speaker = peripheral.find("speaker")
local chest = peripheral.find("minecraft:ender chest")
local sensor = peripheral.find("plethora:sensor")
local sense

local restrictedEntites = {
    "Item",
    "Arrow",
    "Zombie",
    "Creeper",
    "Skeleton",
    "quark:flat_item_frame",
    "Spider",
    "ItemFrame",
    "Painting",
    "quark:glass_item_frame",
    "Chicken",
    "Cow",
    "Pig",
    "Enderman",
    "Witch"
}

if sensor then
    sense = sensor.sense
end

local function update()
    local s = shell.getRunningProgram()
    handle = http.get("https://raw.githubusercontent.com/adven-cc/vendor/master/vendor.lua")
    if not handle then
        print("Failed to update.")
    else
        local vendingFile = fs.open(s, "r")
        local updatedFile = http.get("https://raw.githubusercontent.com/adven-cc/vendor/master/vendor.lua").readAll()
        if updatedFile() =~ vendingFile.readAll() then
            vendingFile.close()
            updatedFile.close()
            data = handle.readAll()
            local f = fs.open(s, "w")
            handle.close()
            f.write(data)
            f.close()
            shell.run(s)
        end
        return
    end
end

local function default()
    mon.setTextColor(config.textColor)
    mon.setBackgroundColor(config.bgColor)
    mon.setTextScale(0.5)
    mon.clear()
    mon.setCursorPos(2, 4)
    mon.write(config.DispensedItem)
    mon.setCursorPos(3, 7)
    mon.write("Click here!")
end

local function sleeping()
    mon.setTextColor(config.textColor)
    mon.setBackgroundColor(config.bgColor)
    mon.clear()
    mon.setCursorPos(3, 5)
    mon.write("Please wait")
end

local function getFirst() -- Just to get first item in a chest
    local items = chest.list()
    for i, v in pairs(items) do
        if v.count >= config.DispensedAmount then return i end
    end
    return
end

function table.contains(tbl, value)
    for i, v in pairs(tbl) do
        if v == value then
            return true
        end
    end
    return false
end

while true do
    default()
    speaker.playSound("entity.experience_orb.pickup", 1, 1)

    -- Pull a chest into turtles first slot
    if turtle.getItemCount(1) == 0 then
        chest.pushItems("turtle_" .. tostring(turtleNetworkID), getFirst(), config.DispensedAmount, 1)
    end

    -- Wait until monitor is touched
    os.pullEvent("monitor_touch")

    -- Drop the computer
    turtle.drop(config.DispensedAmount)

    speaker.playSound("entity.player.levelup", 1, 1)
    sleeping()

    if config.websocketURL and config.websocketURL ~= "" then
        local nearestPlayer = "(unk)"
        if sense then
            local sensed = sense()
            for i, v in pairs(sensed) do
                if not table.contains(restrictedEntites, v.name) then
                    nearestPlayer = v.name
                    break
                end
            end
        end

        local request = http.post(config.websocketURL, "content=" .. ("(%s@%s) %s withdrew one %s"):format(config.locationType, config.locationName, nearestPlayer, config.DispensedItem))
        request.close()
    end

    -- Wait 30 seconds before next drop
    sleep(waitTime)
end
