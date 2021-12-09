local IconButton = require("ui/widget/iconbutton")
local InputContainer = require("ui/widget/container/inputcontainer")
local WidgetContainer = require("ui/widget/container/widgetcontainer")
local InfoMessage = require("ui/widget/infomessage")
local UIManager = require("ui/uimanager")
local ButtonTable = require("ui/widget/buttontable")
--local Button = require("ui/widget/")
local VerticalGroup = require("ui/widget/verticalgroup")
local BlitBuffer = require("ffi/blitbuffer")
local Button = require("ui/widget/button")

local Geom = require("ui/geometry")

local InputMenu = VerticalGroup:new{
	penSet = nil, -- function to pass the pen up to the parent
	expanded= false, -- show the entire menu on the side
	show_parent=nil -- widget to set dirty when this requires a redraw
}


function InputMenu:init()
	local menuButton = IconButton:new{
		icon="notepad.menu",
		dimen= Geom:new{w=50,h=50},
		callback = function()
			self:onMenuTap()
		end
	}

	--local penImage = BlitBuffer.new(50,50)
	--penImage:paintCircle(25,25,10,nil,2)
	local penButton = IconButton:new{
		--text="pen",
		icon="pen",
		--image = penImage,
		dimen=Geom:new{w=50,h=50},
		callback=function()
			self.penSet({
				r=3,
				color=BlitBuffer.gray(1)
			})
			self:collapse()
		end
	}

	--local penImage = BlitBuffer.new(50,50)
	--penImage:paintCircle(25,25,10,nil,2)
	local eraserButton = IconButton:new{
		icon="eraser",
		--text="eraser", 
		--image = penImage,
		dimen=Geom:new{w=50,h=50},
		callback=function()
			self.penSet({
				r=20,
				color=BlitBuffer.gray(0)
			})
			self:collapse()
		end
	}
	self.penButton = penButton
	self.eraserButton = eraserButton

	table.insert(self, menuButton)

end


function InputMenu:onMenuTap()
	if self.expanded then
		self:collapse()
	self.penSet({r=10})
	else
		self:expand()
	self.penSet({r=3})
	end
end

function InputMenu:collapse()
	table.remove(self)
	table.remove(self)
	self.expanded = false
	self:resetLayout()
	-- FIX THIS TO NOT REQUIRE A CALL TO "ALL"
	UIManager:setDirty("all") --self.show_parent)
end

function InputMenu:expand()
	table.insert(self,self.penButton)
	table.insert(self,self.eraserButton)
	self.expanded= true
	self:resetLayout()
	UIManager:setDirty("all") --self.show_parent)
end

return InputMenu

