local Device = require("device")
local Screen = Device.screen
local UIManager = require("ui/uimanager")

-- UI Components
local InputContainer = require("ui/widget/container/inputcontainer")
local OverlapGroup = require("ui/widget/overlapgroup")

--Plugin Components
local DrawLayer = require("drawlayer")
local InputMenu = require("inputmenu")

-- utilities
local util = require("util")
local logger = require("logger")

local NotePadUI = InputContainer:new{
	height = nil,
	width= nil,
	pen = nil,
	current_pad = nil,
	menu = nil,
}

function NotePadUI:init()
	if Device:hasKeys() then
		self.key_events.Home = {{"Home"}, doc= "open file browser"}
	end

	if not self.width then
		self.width = Screen:getWidth()
	end
	if not self.height then
		self.height = Screen:getHeight()
	end
	self.menu = InputMenu:new{
		penSet=function(pen) self:setPen(pen) end,
		show_parent = self
	}
end

function NotePadUI:newNotePad()
	self.current_pad = DrawLayer:new{width=self.width, height=self.height, parent=self}
end


function NotePadUI:onCloseWidget()
	self:free()
	table.remove(self)
	self.current_pad = nil
end

function NotePadUI:onShow()
	if not self.current_pad then
		self:newNotePad()
	end
	self.app = OverlapGroup:new{
		self.current_pad,
		self.menu
	}
	table.insert(self,self.app)
end



function NotePadUI:onHome()
	UIManager:close(self,"full")
	--self:showFileManager()
end

function NotePadUI:setPen(pen)
	self.pen = pen
end


--function NotePadUI:showFileManager(file)
--    local FileManager = require("apps/filemanager/filemanager")
--
--    local last_dir, last_file
--    if file then
--        last_dir, last_file = util.splitFilePathName(file)
--        last_dir = last_dir:match("(.*)/")
--    else
--        last_dir, last_file = self:getLastDirFile(true)
--    end
--    if FileManager.instance then
--        FileManager.instance:reinit(last_dir, last_file)
--    else
--        FileManager:showFiles(last_dir, last_file)
--    end
--end

--[[--
 Taken from ReaderUI. Might need. might not. 

]]
--function NotePadUI:registerModule(name, ui_module, always_active)
--    if name then
--        self[name] = ui_module
--        ui_module.name = "reader" .. name
--    end
--    table.insert(self, ui_module)
--    if always_active then
--        -- to get events even when hidden
--        table.insert(self.active_widgets, ui_module)
--    end
--end

--[[--
Handle pendraw events by passing off to appropriate draw layer
Probably need to handle pen features here
]]
--function NotePadUI:onPenDraw(draw)
--	self.drawLayer.onPenDraw(draw)
--end


return NotePadUI
