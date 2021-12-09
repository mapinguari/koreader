--
--Currently it works and it reasonably responsive however.
--TODO
--Fix pen/touch event slot clobbering
--	I hope the double release error we get will be fixed by sorting this out.
--decide if we can bypass the UI update queue for renders
--build the remainder of the UI
--
--fix draw circle - Something is going funny with line stride
--make the update window the correct size (There is a weird effect where if I use what I Think the bounding box should be nothing actually gets displayed)
--  I really am not sure why, but at the moment I have a hack of a larger update square and it seems to work
--Figure out how to write directly to the screen buffer and update. This would give a speed up in apparent response time
--Probably want to break this off ImageViewer. It works find at the moment but it wasn't designed for doing what it currently is doing

local BlitBuffer = require("ffi/blitbuffer")
local Widget = require("ui/widget/widget")
local ImageWidget = require("ui/widget/imagewidget")
local Logger = require("logger")
local UIManager = require("ui/uimanager")
local Device = require("device")
local Screen = Device.screen
local Geom = require("ui/geometry")

local logger = require("logger")


function get_points(p0,p1,m)
	local d = math.sqrt((p1.x - p0.x)^2 + (p1.y - p0.y)^2)
	if d < m then
		return {p1}
	end
	local v = {x = (p1.x - p0.x)/d, y = (p1.y - p0.y)/d}
	function add(p,v)
		return {x=p.x + v.x , y = p.y + v.y}
	end
	local ps = {}
	for _ = 1, d do
		if #ps < 1 then
			table.insert(ps, p0)
		else
			table.insert(ps,add(ps[#ps],v))
		end
	end
	return ps
end


local default_pen = {
	color = BlitBuffer.Color8(1),
	r = 3
}


local DrawLayer = ImageWidget:new{
	_bb = nil,
	last_point = nil,
	parent = nil

}

function DrawLayer:init()
	-- need to eventually set up loading and saving
	self.image = BlitBuffer.new(self.width, self.height)
	self:wipe()
end


function DrawLayer:onPenDraw(draw)
	--Draw drawing event to bb
	local pen = self.parent.pen or default_pen
	local r = pen.r
	local c = pen.color
	local ud
	if not draw.x or not draw.y then
		return true
	end

	if self.last_point and self.last_point.x and self.last_point.y then
		local ps = get_points(self.last_point, draw,r)
		for _,p in ipairs(ps) do
			self:safePaint(p.x,p.y,r,c)
			--self.image:paintRect(p.x,p.y,r,r,c)
		end
			local m = r
       ud = Geom:new{
           x = math.min(self.last_point.x, draw.x)-m,
           y = math.min(self.last_point.y, draw.y)-m,
           h = math.abs(self.last_point.y - draw.y)+2*m,
           w = math.abs(self.last_point.x - draw.x)+2*m
       }
	else
			self:safePaint(draw.x,draw.y,r,c)
      --  self.image:paintRect(draw.x,draw.y,r,r,c)
        ud = Geom:new{
            x = draw.x,
            y = draw.y,
            h = r,
            w = r
        }
	end
	--Ideally I want to paint circles but line stride looks like it is fucked up for some reason.
	--self._bb:paintCircle(draw.x,draw.y,r )
	self.last_point=draw

 	UIManager:setDirty(self.parent, "fast", ud, false)
 	--UIManager:setDirty(self, "fast", self.dimen, false)
	--UIManager:widgetRepaint(self,draw.x, draw.y)
	self:paintTo(Screen.bb, draw.x, draw.y)
	--Screen.bb:blitFrom(self._bb, ud.x,ud.y,0,0,ud.w,ud.h)
	--Screen:refreshFast(ud.x,ud.y,ud.w, ud.h)
	--Screen.bb:blitFrom(self._bb)
	--Screen:refreshFast()
	return true
end

function DrawLayer:onPenLift(draw)
	self.last_point=nil
	return true
end

function DrawLayer:onPenHover(draw)
	self.last_point=nil
	return true
end

function DrawLayer:wipe(geom)
	self.image:fill(BlitBuffer.gray(0))
end

function DrawLayer:onGesture(gesture)
	--local fauxdraw = {x=250, y=100,r=10}
	--self:onPenDraw(fauxdraw)
	return false
end

function DrawLayer:safePaint(x,y,r,c)
	if x and y and r and c then
			self.image:paintRect(x,y,r,r,c)
	end
end	


return DrawLayer

