local text = {
	x = 0,
	y = 0,
	text = "Some Text",
	foreColour = colours.black,
	type = "text",
}
text.__index = text

function text.new( data, parent )
	local self = setmetatable( data, text )
	self.parent = parent
	self.backColour = data.backColour or parent.backColour
	self.state = data.state or parent.state
	table.insert( parent.children, self )
	return self
end

function text:getAbsX()
	return self.x + self.parent:getAbsX()
end

function text:getAbsY()
	return self.y + self.parent:getAbsY()
end

function text:centerInParent( x, y )
	x = x or true
	y = y or false
	if x then
		self.x = math.ceil(self.parent.w/2 - #self.text/2)
	end
	if y then
		self.y = math.floor(self.parent.h/2)
	end
end

local function fit( text, lim )
	if #text > lim then

	end
	return text
end

function text:draw()
	if self.state == cobalt.state or self.state == "_ALL" then
		cobalt.g.setColour( self.foreColour )
		cobalt.g.print(self.text, self:getAbsX(), self:getAbsY() )
	end
end

return text
