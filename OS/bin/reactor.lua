local computer = require("computer")
local component = require("component")
local syslog = require("syslog")


local modem = nil
if component.isAvailable("modem") then
modem = component.modem
end
local br_reactor = nil


local serialization = require("serialization")
local term = require("term")
local os = require("os")
local gpu = component.gpu
local network = require("network")
local shell = require("shell")

gpu.setResolution(80, 25)

local args, options = shell.parse(...)

if args[1] == "server" then
br_reactor = component.br_reactor
end

reactor = {}
reactor.clients = {}

if #args == 0 then
print("Modes available: server, client")
return
end

function reactor.writeData(data)
	if data["active"] then
		print("Status: Working")
		else print("Status: Stopped")
	end
	print("")
	print("Energy: " .. tonumber(data["energy"]))
	print("Rods: ".. data["rods"])
	print("Fuel temperature " .. math.floor(data["fuel_temp"]))
	print("Casing temperature " .. math.floor(data["casing_temp"]))
	print("Fuel amount " .. math.floor(data["fuel"]) .. "/" .. math.floor(data["fuel_max"]))
	print("Output " .. math.floor(data["output"]))
end

function reactor.doHandshake(data)
	syslog.write(data["remoteAddress"] .. " trying to connect")
	array = {}
	array["remoteAddress"] = data["remoteAddress"]
	array["payload"] = data["payload"]
	reactor.clients[array["remoteAddress"]:sub(1,6)] = array
	syslog.write(reactor.clients[data["remoteAddress"]:sub(1,6)]["payload"])
end

function reactor.readServerData(data)
	reactorStatus = serialization.unserialize(data["payload"])
	syslog.write(data["payload"])
	term.clear()
	reactor.writeData(reactorStatus)
end

function reactor.init()
	syslog.write("Reactor module initialaztion start")
	if component.isAvailable("modem") then
		syslog.write("Modem found")
		res = modem.open(1100)
		if res then syslog.write("Modem: port 1100 ready") end
		network.startListening()
		if args[1] == "server" then network.addCallback("reactorServerConnect", reactor.doHandshake) end
		if args[1] == "client" then network.addCallback("reactorServerStatus", reactor.readServerData) end
	else syslog.write("Modem not found, offline mode enabled") 
	end
end

reactor.init()

if args[1] == "client" then
	print("Sending pairing packet")
	modem.broadcast(1100, "reactorServerConnect connectionAsk")
	while true do
		result = require("event").pull(0.5, "key")
    	if result ~= nil then break end
	end
else
	while true do
		dataArray = {}
		dataArray["active"] = br_reactor.getActive()
		dataArray["energy"] = br_reactor.getEnergyStored()
		dataArray["rods"] = br_reactor.getNumberOfControlRods()
		dataArray["fuel_temp"] = br_reactor.getFuelTemperature()
		dataArray["casing_temp"] = br_reactor.getCasingTemperature()
		dataArray["fuel"] = br_reactor.getFuelAmount()
		dataArray["fuel_max"] = br_reactor.getFuelAmountMax()
		dataArray["output"] = br_reactor.getEnergyProducedLastTick()
		reactor.writeData(dataArray)
		for address, info in pairs(reactor.clients) do
			res = modem.send(info["remoteAddress"], 1100, "reactorServerStatus " .. serialization.serialize(dataArray))
			if res == false then
				syslog.write("Error sending to " .. info["remoteAddress"])
			else syslog.write("Successfully sent to " .. info["remoteAddress"]) end
			if br_reactor.getEnergyStored() < 2000000 then br_reactor.setActive(true) end
			if br_reactor.getEnergyStored() > 8000000 then br_reactor.setActive(false) end
		end
		os.sleep(1)
		term.clear()
	end
end