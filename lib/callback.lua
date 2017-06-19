local component = require("component")
local thread = require("thread")
local event = require("event")

local callback = {}
callback.callbacks = {}

thread.init()

local function starts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

function network.listen()
	while(true) do
		local _, _, remoteAddress, port, distance, payload = event.pull("modem_message")
		if payload ~= nil then require("term").write(payload .. "\n") else require("term").write("nil") end
		for i = 1, #network.callbacks do
			if starts(payload, network.callbacks[i]["name"]) then
				require("term").write("Sending callback: " .. network.callbacks[i]["name"] .. "\n")
				network.callbacks[i].f(payload:sub(#network.callbacks[i]["name"] + 2, #payload))
			end
		end
	end
end

function network.startListening()
	require("term").write("Listening from start\n")
	event.listen
	thread.create(network.listen)
end

function network.addCallback(name, func)
	require("term").write("Callback added: " .. name .. "\n")
	network.callbacks[#network.callbacks+1] = {}
	network.callbacks[#network.callbacks]["name"] = name;
	network.callbacks[#network.callbacks].f = func
end

return network