local checkbox = {

	x = 1,
	y = 1,
	backColour = colours.lightGrey,
	foreColour = colours.black,
	char = "x",
	selected = false,
	group = "_MAIN",
	visible = true,
	label = "A Checkbox",
	type = "checkbox",
	automl = "",
	automt = "",
	autox = "",
	autoy = "",
	wrap = "left",
	marginleft = 0,
	margintop = 0,

}
checkbox.__index = checkbox


function checkbox.new( data, parent )
	data = data or { }
	local self = setmetatable( data, checkbox )
	if not self.val then self.val = self.label end
	self.w = #self.label + 2
	self.parent = parent
	if type(self.marginleft) == "string" then
		self.marginleft = cobalt.getPercentage( self.marginleft )
		self.automl = "perc:" .. self.marginleft
	end
	if type(self.margintop) == "string" then
		self.margintop = cobalt.getPercentage( self.margintop )
		self.automt = "perc:" .. self.margintop
	end
	if type(self.x) == "string" then
		self.x = cobalt.getPercentage( self.x )
		self.autox = "perc:" .. self.x
	end
	if type(self.y) == "string" then
		self.y = cobalt.getPercentage( self.y )
		self.autoy = "perc:" .. self.y
	end
	self:resize()
	self.state = data.state or parent.state
	table.insert( parent.children, self )
	return self
end

function checkbox:resize()
	if self.automl:sub( 1, 4 ) == "perc" then
		local perc = self.automl:match("perc:(%d+)")
		self.marginleft = math.floor( self.parent.w * cobalt.setPercentage( perc ) )
	end
	if self.automt:sub( 1, 4 ) == "perc" then
		local perc = self.automt:match("perc:(%d+)")
		self.margintop = math.floor( self.parent.h * cobalt.setPercentage( perc ) )
	end
	if self.autox and self.autox:sub( 1, 4 ) == "perc" then
		local perc = self.autox:match("perc:(%d+)")
		self.x = math.floor( self.parent.w * cobalt.setPercentage( perc ) )
	end
	if self.autoy and self.autoy:sub( 1, 4 ) == "perc" then
		local perc = self.autoy:match("perc:(%d+)")
		self.y = math.floor( self.parent.h * cobalt.setPercentage( perc ) )
	end
end

function checkbox:getAbsX()
	return self.x + self.parent:getAbsX() - 1 + self.marginleft
end

function checkbox:getAbsY()
	return self.y + self.parent:getAbsY() - 1 + self.margintop
end

function checkbox:draw()
	self.w = #self.label + 2
	if self.wrap == "center" then
		self.x = math.ceil( self.parent.w/2 - self.w/2 ) + self.marginleft
	end
	if self.state == cobalt.state or self.state == "_ALL" and self.visible then
		local char = " "
		if self.selected then
			char = self.char
		end
		self.parent.surf:drawPixel( math.ceil(self.x + self.marginleft), math.ceil(self.y + self.margintop), char, self.backColour, self.foreColour )
		self.parent.surf:drawText( math.ceil(self.x+2 + self.marginleft), math.ceil(self.y+ self.margintop), self.label, nil, self.foreColour )
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
