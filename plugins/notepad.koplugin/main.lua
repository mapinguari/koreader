local Device = require("device")

if not Device:isTouchDevice() then
	return { disabled = true }
end

local FrameContainer = require("ui/widget/container/framecontainer")
local DataStorage = require("datastorage")
local UIManager = require("ui/uimanager")
local _ = require("gettext")
local Dispatcher = require("dispatcher")
local Screen = Device.screen

local Geom = require("ui/geometry")

local logger = require("logger")

local NotePadUI = require("notepadui")


local NotePad = FrameContainer:new{
	name = "texteditor",
	settings_file = DataStorage:getSettingsDir() .. "/notepad.lua",
	notepadui=nil
}

function NotePad:onDispatcherRegisterActions()
	--Dispatcher:registerAction("notepad_action", {category="none", event="NotePad", title=_("NotePad"), general=true})
end


function NotePad:init()
	self.onDispatcherRegisterActions()
	self.ui.menu:registerToMainMenu(self);

end

function NotePad:addToMainMenu(menu_items)
	menu_items.notepad = {
		text=("NotePad"),
		--sorting_hint="more_tools",
		-- a callback when tapping
		callback = function()
			self:createApp()
			UIManager:show(self.notepadui)
		end
	}
end

function NotePad:onNotePad()
	self:createApp()
	UIManager:show(self.notepadui)
end

function NotePad:createApp()
	if not self.notepadui then
		self.notepadui = NotePadUI:new{dimen=Geom:new{w=Screen:getWidth(), h=Screen:getHeight()}}
	end
end

return NotePad
