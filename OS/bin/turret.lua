local component = require("component")
local shell = require("shell")

local function applyForAll(list, method, value)
	for i = 1, #list do
		component.invoke(list[i].address, method, value)
	end
end

local function printHelp()
	print("Usage: ")
	print(" turret trustedplayer <remove | add> <nick>")
	print(" turret tp <remove | add> <nick>")
	print(" turret trustedplayer list")
	print(" turret tp list")
	print(" turret setattack <mobs | neutrals | players> <true | false>")
	print(" turret sa <mobs | neutrals | players> <true | false>")
	print(" status")
	return
end

function ternary ( cond , T , F )
    if cond then return T else return F end
end

local args = shell.parse(...)
if #args == 0 then
	printHelp()
end

local candidates = {}
for address in component.list("tierOneTurretBase") do
  local dev = component.proxy(address)
   table.insert(candidates, dev)
end

for address in component.list("tierTwoTurretBase") do
  local dev = component.proxy(address)
   table.insert(candidates, dev)
end

for address in component.list("tierThreeTurretBase") do
  local dev = component.proxy(address)
   table.insert(candidates, dev)
end

for address in component.list("tierFourTurretBase") do
  local dev = component.proxy(address)
   table.insert(candidates, dev)
end

for address in component.list("tierFiveTurretBase") do
  local dev = component.proxy(address)
   table.insert(candidates, dev)
end

if #args > 2 then
	if args[1] == "tp" or args[1] == "trustedplayer" then
		if args[2] == "list" then 
			print(candidates[0].getTrustedPlayers()) 
			return 
		end
		if args[2] == "remove" then
			if #args == 3 then
				applyForAll(candidates, "removeTrustedPlayer", args[3]) 
				return
			else printHelp() end
		end
		if args[2] == "add" then
			if #args == 3 then 
				applyForAll(candidates, "addTrustedPlayer", args[3]) 
				return 
			else printHelp() end
		end
	end
	if args[1] == "setattack" or args[1] == "sa" then
		if args[2] == "mobs" then
			if #args == 3 then
				applyForAll(candidates, "setAttacksMobs", args[3] == "true" and true or false)
				return
			else printHelp() end
		end
		if args[2] == "neutrals" then
			if #args == 3 then
				applyForAll(candidates, "setAttacksNeutrals", args[3] == "true" and true or false)
				return
			else printHelp() end
		end
		if args[2] == "players" then
			if #args == 3 then
				applyForAll(candidates, "setAttacksPlayers", args[3] == "true" and true or false)
				return
			else printHelp() end
		end
	end
end
if #args == 1 then
   if args[1] == "status" then
   		local ActLength = 4 
   		local PlaLength = 4
   		local MobLength = 4
   		local NeuLength = 4
   		for i = 1, #candidates do
   			if not component.invoke(candidates[i].address, "getActive") then ActLength = 5 end
   			if not component.invoke(candidates[i].address, "isAttacksPlayers") then PlaLength = 5 end
   			if not component.invoke(candidates[i].address, "isAttacksMobs") then MobLength = 5 end
   			if not component.invoke(candidates[i].address, "isAttacksNeutrals") then NeuLength = 5 end
   		end
   		print("Num Add    Act " .. (ternary(ActLength == 4, "", " ")) .. " Pla " .. (ternary(PlaLength == 4, "", " ")) .. " Mob " .. (ternary(MobLength == 4, "", " ")) .. " Neu")
   		for i = 1, #candidates do
   			print(i .. ".  " .. candidates[i].address:sub(1, 6) .. " " .. tostring(component.invoke(candidates[i].address, "getActive") and true or false) .. 
   				" " .. tostring(component.invoke(candidates[i].address, "isAttacksPlayers") and true or false) .. 
   				" " .. tostring(component.invoke(candidates[i].address, "isAttacksMobs") and true or false) .. 
   				" " .. tostring(component.invoke(candidates[i].address, "isAttacksNeutrals") and true or false))
   		end
   end
end