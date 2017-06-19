local component = require("component")
local thread = require("thread")
local os = require("os")
local event = require("event")

local network = {}
network.callbacks = {}

thread.init()

local function starts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

function network.listen()
	while(true) do
		local _, _, remoteAddress, port, distance, payload = event.pull("modem_message")
		for i = 1, #network.callbacks do
			if starts(payload, network.callbacks[i]["name"]) then
				args = {}
				args["remoteAddress"] = remoteAddress
				args["port"] = port
				args["payload"] = payload:sub(#network.callbacks[i]["name"] + 2, #payload)
				network.callbacks[i].f(args)
			end
		end
	end
end

function network.startListening()
	thread.create(network.listen)
end

function network.addCallback(name, func)
	network.callbacks[#network.callbacks+1] = {}
	network.callbacks[#network.callbacks]["name"] = name;
	network.callbacks[#network.callbacks].f = func
end

return network