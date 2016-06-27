local button = {
	x = 1,
	y = 1,
	w = 11,
	h = 2,
	text = "A button",
	backColour = colours.cyan,
	foreColour = colours.white,
	selected = false,
	visible = true,
	type = "button",
}
button.__index = button

function button.new( data, parent )
	data = data or { }
	local self = setmetatable( data, button )
	self.parent = parent
	self.state = data.state or parent.state
	table.insert( parent.children, self )
	return self
end

function button:getAbsX()
	return self.x + self.parent:getAbsX()-1
end

function button:getAbsY()
	return self.y + self.parent:getAbsY()-1
end

function button:centerInParent( x, y )
	x = x or true
	y = y or false
	if x then
		self.x = math.ceil(self.parent.w/2 - self.w/2)
	end
	if y then
		self.y = math.floor(self.parent.h/2 - self.h/2)
	end
end


function button:draw()
	if self.state == cobalt.state or self.state == "_ALL" and self.visible then
		local colour = self.backColour
		if self.selected then
			colour = cobalt.g.lighten( self.backColour )
		end
		if self.h == 1 then
			self.parent.surf:drawLine( self.x, self.y+1, self.x + self.w, self.y+1, " ", colour, self.foreColour )
		else
			self.parent.surf:fillRect( self.x, self.y, self.x + self.w, self.y + self.h, " ", colour, self.foreColour )
		end
		self.parent.surf:drawText( math.ceil(self.x+self.w/2-#self.text/2), math.ceil(self.y+self.h/2), self.text, colour, self.foreColour )
	end
end

function button:mousepressed( x, y, button )
	if self.state == cobalt.state or self.state == "_ALL" and self.visible then
		if button == 1 and x >= self:getAbsX() and x <= self:getAbsX() + self.w and y >= self:getAbsY() and y <= self:getAbsY() + self.h then
			self.selected = true
		end
	end
end

function button:mousereleased( x, y, button )
	if self.state == cobalt.state or self.state == "_ALL" and self.visible then
		if button == 1 and x >= self:getAbsX() and x <= self:getAbsX() + self.w and y >= self:getAbsY() and y <= self:getAbsY() + self.h then
			if self.selected then
				if self.onclick then
					self.onclick()
				end
				self.selected = false
			end
		else
			self.selected = false
		end
	end
end

return button
