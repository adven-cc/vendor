print("Checking for software update...")

if fs.exists("vendor.lua") then
  local vendingFile = fs.open("vendor.lua", "r")
  local updatedFile = http.get("https://raw.githubusercontent.com/adven-cc/vendor/master/vendor.lua")

  local vendingData = vendingFile.readAll()
  local updatedData = updatedFile.readAll()

  vendingFile.close()
  updatedFile.close()

  if vendingData ~= updatedData then
    print("Writing new updated data...")

    local vendingUpdater = fs.open("vendor.lua", "w")
    vendingUpdater.write(updatedData)
    vendingUpdater.close()
    print("Update complete, starting vendor")
  else
    print("No updates available")
  end
else
  print("Downloading vendor software...")
  local vendor = http.get("https://raw.githubusercontent.com/adven-cc/vendor/master/vendor.lua")
  local data = vendor.readAll()
  vendor.close()

  local vendor = fs.open("vendor.lua", "w")
  vendor.write(data)
  vendor.close()
end

print("Starting vendor software")
shell.run("vendor.lua")