local shell = require("shell")
local serialization = require("serialization")

local args, options = shell.parse(...)
if (#args == 0 and not options.d) or (not options.d and not options.e) then 
  print("Usage: autorun [-det] <file>")
  print(" -d: disable")
  print(" -e: enable") 
  print(" -t: timeout (default: 5)")
  return
end
file = io.open("/home/autorun.cfg", "w")
io.output(file)
data = {}
if options.d then
data["file"] = ""
data["enabled"] = "false"
data["timeout"] = 5
print("Autorun disabled")
end
if options.e then
if options.t then  
	data["file"] = args[2]
	print("Autorun enabled with " .. args[2] .. " timeout = " .. args[1])
else 
	data["file"] = args[1]
	print("Autorun enabled with " .. args[1])
end
data["enabled"] = "true"
if options.t then 
	data["timeout"] = args[1]
end
end
io.write(serialization.serialize(data))
io.close()
io.output(io.stdout)
return