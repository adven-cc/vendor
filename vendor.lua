-- Vending Machine Software V4 by BlackDragon_B and znepb

local config = require("config")
local turtleNetworkID = config.turtleNetworkID
local waitTime = 0
if config.waitTime then
    waitTime = config.waitTime
else
    waitTime = 15
end
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
        local data = handle.readAll()
        if data ~= vendingFile.readAll() then
            print("Updating system.")
            vendingFile.close()
            local f = fs.open(s, "w")
            handle.close()
            print("Writing Data.")
            f.write(data)
            f.close()
            local request = http.post(config.websocketURL, "content=" .. ("(%s@%s) System has been updated to the newest github commit"):format(config.locationType, config.locationName))
            request.close()
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
    local x,y = mon.getSize()
    mon.setCursorPos(math.ceil((x-#config.DispensedItem)/2), 4)
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
print("Checking for updates.")
if not config.ignoreUpdate then 
    update()
end
local request = http.post(config.websocketURL, "content=" .. ("(%s@%s) Has been started"):format(config.locationType, config.locationName))
request.close()
while true do
    default()
    speaker.playSound("entity.experience_orb.pickup", 1, 1)

    -- Pull a chest into turtles first slot
    if turtle.getItemCount(1) == 0 then
        chest.pushItems("turtle_" .. tostring(turtleNetworkID), getFirst(), config.DispensedAmount, 1)
    end

    -- Wait until monitor is touched
    os.pullEvent("monitor_touch")

    -- Drop the item
    turtle.drop(config.DispensedAmount)

    speaker.playSound("entity.player.levelup", 1, 1)
    sleeping()
    
    local total = 0
    for slot, item in pairs(chest.list()) do
        total = total + item.count
    end

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

        local request = http.post(config.websocketURL, "content=" .. ("(%s@%s) %s withdrew %s %s (%s left)"):format(config.locationType, config.locationName, nearestPlayer, config.DispensedAmount, config.DispensedItem, total))
        request.close()
    end

    -- Wait 30 seconds before next drop
    sleep(waitTime)
end
