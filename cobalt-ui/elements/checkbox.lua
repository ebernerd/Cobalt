local checkbox = {

	x = 0,
	y = 0,
	backColour = colours.lightGrey,
	foreColour = colours.black,
	char = "x",
	selected = false,
	group = "_MAIN",
	visible = true,
	label = "A Checkbox",
	type = "checkbox",

}
checkbox.__index = checkbox


function checkbox.new( data, parent )
	data = data or { }
	local self = setmetatable( data, checkbox )
	self.parent = parent
	self.state = data.state or parent.state
	table.insert( parent.children, self )
	return self
end

function checkbox:getAbsX()
	return self.x + self.parent:getAbsX()
end

function checkbox:getAbsY()
	return self.y + self.parent:getAbsY()
end

function checkbox:draw()
	if self.state == cobalt.state or self.state == "_ALL" and self.visible then
		cobalt.g.pixel( self:getAbsX(), self:getAbsY(), self.backColour )
		cobalt.g.setColour( self.foreColour )
		if self.selected then
			cobalt.g.print( self.char:sub(1,1), self:getAbsX(), self:getAbsY() )
		end
		cobalt.g.setBackgroundColour( self.parent.backColour )
		cobalt.g.print( self.label, self:getAbsX() + 2, self:getAbsY())
	end
end

function checkbox:mousepressed( x, y, button )
	if self.state == cobalt.state or self.state == "_ALL" and self.visible then
		if button == 1 and x == self:getAbsX() and y == self:getAbsY() then

		end
	else
		self.selected = false
	end
end

function checkbox:mousereleased( x, y, button )
	if self.state == cobalt.state or self.state == "_ALL" and self.visible then
		if button == 1 and x == self:getAbsX() and y == self:getAbsY() then
			self.selected = not self.selected
		end
	else
		self.selected = false
	end
end

return checkbox
