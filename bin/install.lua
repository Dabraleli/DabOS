local component = require("component")
local computer = require("computer")
local event = require("event")
local unicode = require("unicode")
local shell = require("shell")
local filesystem = require("filesystem")

local args, options = shell.parse(...)

local candidates = {}
for address in component.list("filesystem") do
  local dev = component.proxy(address)
  if not dev.isReadOnly() and dev.address ~= computer.tmpAddress() and dev.address ~= computer.getBootAddress() then
    table.insert(candidates, dev)
  end
end

if #candidates == 0 then
  print("No writable disks found, aborting.")
  return
end

for i = 1, #candidates do
	local label = candidates[i].getLabel()
   	if label then
    	label = label .. " (" .. candidates[i].address:sub(1, 8) .. "...)"
  	else
    	label = candidates[i].address
  	end
  	print(i .. ") " .. label)
end

print("Current version: " .. _OSVERSION)
print("To select the device to install to, please enter a number between 1 and " .. #candidates .. ".")
print("Press 'q' to cancel the installation.")
local choice
while not choice do
  result = io.read()
  if result:sub(1, 1):lower() == "q" then
    return
  end
  local number = tonumber(result)
  if number and number > 0 and number <= #candidates then
    choice = candidates[number]
  else
    print("Invalid input, please try again.")
  end
end
candidates = nil

local name = _OSVERSION
print("Installing " .. name .." to device " ..  choice.address)
os.sleep(0.25)
local origin = options.from and options.from:sub(1,3) or computer.getBootAddress():sub(1, 3)
local mnt = choice.address:sub(1, 3)
for entry in filesystem.list("/") do
	if entry ~= "home/" and entry ~= "mnt/" and entry ~= "tmp/" then
		print("Writing " .. entry)
		local result, reason = os.execute("/bin/cp -r /mnt/" .. origin .. "/" .. entry .. " /mnt/" .. mnt .. "/")
		if not result then
  			error(reason, 0)
		end
	end
end
component.invoke(choice.address, "setLabel", _OSVERSION)

if not options.noreboot then
  print("All done! " .. ((not options.noboot) and "Set as boot device and r" or "R") .. "eboot now? [Y/n]")
  local result = io.read()
  if not result or result == "" or result:sub(1, 1):lower() == "y" then
    if not options.noboot then computer.setBootAddress(choice.address)end
    print("\nRebooting now!")
    computer.shutdown(true)
  end
end
print("Returning to shell.")
