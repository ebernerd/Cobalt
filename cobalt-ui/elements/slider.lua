local slider = {
	x = 0,
	y = 0,
	w = 10,
	h = 3,
	slx = 0,
	sly = 0,
	slw = 3,
	slh = 2,
	backColour = colours.grey,
	foreColour = colours.lightGrey,

	dx = 0,
	dy = 0,

	type = "slider",

	selected = false,
	visible = true,
}

function slider.new( data, parent )
	data = data or { }
	local self = setmetatable( data, slider )
	self.parent = parent
	self.state = data.state or parent.state
	table.insert( parent.children, self )
	return self
end


function slider:getAbsX()
	return self.x + self.parent:getAbsX()-1
end

function slider:getAbsY()
	return self.y + self.parent:getAbsY()-1
end

function slider:update( dt )

end

function slider:draw()
	self.parent.surf:fillRect( self.x, self.y, self.x + self.w, self.y + self.h, " ", self.backColour, self.foreColour )
	self.parent.surf:fillRect( self.x + self.slx, self.y + self.sly, self.x + self.slx + self.slw, self.y + self.slh + self.sly, " ", self.foreColour, self.foreColour )
end

function slider:mousepressed( x, y )
	if x >= self:getAbsX() + self.slx and x <= self:getAbsX() + self.w + self.slx + self.slw and y >= self:getAbsY() + self.sly and y <= self:getAbsY() + y + self.sly + self.slh then
		self.selected = true
		self.dx = x - self.slx
		self.dy = y - self.sly
	end
end

function slider:mousereleased( x, y )
	self.selected = false
end

function slider:mousedrag( x, y )
	if self.selected then
		self.slx = self.slx + (x-self.dx)
		self.sly = self.sly + (y-self.dy)
	end
end

return slider
