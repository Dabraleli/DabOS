local fs = require("filesystem")
 
if fs.get("bin/edit.lua") == nil or fs.get("bin/edit.lua").isReadOnly() then
    print("Floppy disk filesystem detected: type \"install\" in command line and install OpenOS to your HDD. After that run DabOS installer again.")
    print(" ")
else
    local installerPath = "/bin/installer.lua"
    print("Downloading DabOS installer...")
    fs.makeDirectory(fs.path(installerPath))
    loadfile("/bin/wget.lua")("https://raw.githubusercontent.com/Dabraleli/DabOS/master/Installer/installer.lua", installerPath, "-fq")
    dofile(installerPath)
end