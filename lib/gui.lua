local component = require("component")
local event = require("event")
local thread = require("thread")
local gpu = component.gpu


local gui = {}

gui.blocks = {}

function gui.listenEvent(event, screenAddress, x, y, button, playerName)
	for name, block in pairs(gui.blocks) do
		if(x >= block.x and x <= block.x + block.w and y >= block.y and y <= block.y + block.h) then
			thread.create(block.func)
		end
	end
end

function gui.listen()
	event.listen("touch", gui.listenEvent)

end

function gui.init()
	thread.init()
	thread.create(gui.listen)
end

function gui.button(x, y, w, h, name, text, func)
	-- body
	gui.blocks[name] = {}
	gui.blocks[name].type = "button"
	gui.blocks[name].x = x
	gui.blocks[name].y = y
	gui.blocks[name].w = w
	gui.blocks[name].h = h
	gui.blocks[name].text = text
	gui.blocks[name].name = name
	gui.blocks[name].func = func
end

function gui.checkbox(x, y, name, text, default, func)
	gui.blocks[name] = {}
	gui.blocks[name].type = "checkbox"
	gui.blocks[name].x = x
	gui.blocks[name].y = y
	gui.blocks[name].w = w
	gui.blocks[name].h = h
	gui.blocks[name].text = text
	gui.blocks[name].name = name
	gui.blocks[name].default = default
	gui.blocks[name].func = func
end

function gui.draw()
	local w, h = gpu.getResolution()
	gpu.fill(1, 1, w, h, " ")
	foreground = gpu.setForeground(0x000000)
	background = gpu.setBackground(0xFFFFFF)
	for name, block in pairs(gui.blocks) do

		if(block.type == "button") then
			gpu.fill(block.x, block.y, block.w, block.h, " ")
			gpu.set(block.x  + (block.w / 2 - #block.text / 2), block.y + math.floor(block.h  / 2), block.text)
			
		end
	end
	gpu.setForeground(foreground)
	gpu.setBackground(background)
end

return gui