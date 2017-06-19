local fs = require("filesystem")

print("Downloading gitrepo...")
loadfile("/bin/wget.lua")("https://raw.githubusercontent.com/Dabraleli/DabOS/master/bin/gitrepo.lua", "/gitrepo.lua", "-fq")
os.execute("/gitrepo.lua Dabraleli/DabOS / y")
fs.remove("/gitrepo.lua")