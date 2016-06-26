local radio = {

	x = 0,
	y = 0,
	backColour = colours.lightGrey,
	foreColour = colours.black,
	char = "o",
	selected = false,
	group = "_MAIN",
	visible = true,
	type = "radio",
	label = "A Radio"

}
radio.__index = radio


function radio.new( data, parent )
	data = data or { }
	local self = setmetatable( data, radio )
	self.parent = parent
	self.state = data.state or parent.state
	table.insert( parent.children, self )
	return self
end

function radio:getAbsX()
	return self.x + self.parent:getAbsX()
end

function radio:getAbsY()
	return self.y + self.parent:getAbsY()
end

function radio:draw()
	if self.state == cobalt.state or self.state == "_ALL" and self.visible then
		cobalt.g.pixel( self:getAbsX(), self:getAbsY(), self.backColour )
		cobalt.g.setColour( self.foreColour )
		if self.selected then
			cobalt.g.print( self.char:sub(1,1), self:getAbsX(), self:getAbsY() )
		end
		cobalt.g.setBackgroundColour( self.parent.backColour )
		cobalt.g.setBackgroundColour( self.parent.backColour )
		cobalt.g.print( self.label, self:getAbsX() + 2, self:getAbsY())
	end
end

function radio:mousepressed( x, y, button )
	if self.state == cobalt.state or self.state == "_ALL" and self.visible then
		if button == 1 and x == self:getAbsX() and y == self:getAbsY() then

		end
	else
		self.selected = false
	end
end

function radio:mousereleased( x, y, button )
	if self.state == cobalt.state or self.state == "_ALL" and self.visible then
		if button == 1 and x == self:getAbsX() and y == self:getAbsY() then
			self.selected = true
			for k, v in pairs( self.parent.children ) do
				if v.type and v.type == "radio" and v ~= self then
					if v.group == self.group then
						v.selected = false
					end
				end
			end
		end
	else
		self.selected = false
	end
end

return radio
