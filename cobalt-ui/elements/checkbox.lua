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
	self.w = #self.label + 2
	self.parent = parent
	self.state = data.state or parent.state
	table.insert( parent.children, self )
	return self
end

function checkbox:getAbsX()
	return self.x + self.parent:getAbsX() -1
end

function checkbox:getAbsY()
	return self.y + self.parent:getAbsY() - 1
end

function checkbox:centerInParent(x, y)
	x = x or true
	y = y or false
	if x then
		self.x = math.ceil(self.parent.w/2 - self.w/2)
	end
	if y then
		self.y = math.floor(self.parent.h/2 - self.h/2)
	end
end

function checkbox:draw()
	self.w = #self.label + 2
	if self.state == cobalt.state or self.state == "_ALL" and self.visible then
		local char = " "
		if self.selected then
			char = self.char
		end
		self.parent.surf:drawPixel( math.ceil(self.x), math.ceil(self.y), char, self.backColour, self.foreColour )
		self.parent.surf:drawText( math.ceil(self.x+2), math.ceil(self.y), self.label, nil, self.foreColour )
	end
end

function checkbox:mousepressed( x, y, button )
	if self.state == cobalt.state or self.state == "_ALL" and self.visible then
		if button == 1 and x >= self:getAbsX() and x <= self:getAbsX() + self.w and y == self:getAbsY() then

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
