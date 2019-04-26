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
	marginleft = 0,
	margintop = 0,
	automl = "",
	automt = "",
	autow = "perc:50",
	wrap = "left",
	autoh = true,
	enabled = true,
}
button.__index = button

function button:getPercentages()
	if type(self.w) == "string" then
		self.w = cobalt.getPercentage( self.w )
		self.autow = self.w
	else
		self.autow = "none"
	end
	if type(self.h) == "string" then
		self.h = cobalt.getPercentage( self.h )
		self.autoh = self.h
	else
		self.autoh = "none"
	end

	if type(self.marginleft) == "string" then
		self.marginleft = cobalt.getPercentage( self.marginleft )
		self.automl = self.marginleft
	end
	if type(self.margintop) == "string" then
		self.margintop = cobalt.getPercentage( self.margintop )
		self.automt = self.margintop
	end
	if type(self.x) == "string" then
		self.x = cobalt.getPercentage( self.x )
		self.autox = self.x
	end
	if type(self.y) == "string" then
		self.y = cobalt.getPercentage( self.y )
		self.autoy = self.y
	end
end

function button.new( data, parent )
	data = data or { }
	if data.style then
		local t = data.style
		for k, v in pairs( t ) do
			if not data[k] then
				data[k] = v
			end
		end
		data.style = nil
	end
	local self = setmetatable(data,button)
	self.parent = parent
	self:getPercentages()
	self:resize()
	self.state = data.state or parent.state
	table.insert( parent.children, self )
	return self
end

function button:setMargins( t, l )
	if t then
		self.margintop = t or self.margintop
		if type(t) == "string" then
			self:getPercentages()
		else
			self.automt = "none"
		end
	end
	if l then
		self.marginleft = l or self.marginleft
		if type(l) == "string" then
			self:getPercentages()
		else
			self.automl = "none"
		end
	end
	self:resize()
end

function button:resize( w, h )
	if w then
		self.w = w or self.w
		if type( self.w ) == "string" then
			self:getPercentages()
		else
			self.autow = "none"
		end
	end
	if h then
		self.h = h or self.h
		if type( self.h ) == "string" then
			self:getPercentages()
		else
			self.autoh = "none"
		end
	end
	if type( self.autow ) == "number" then
		self.w = math.floor( self.parent.w * self.autow )
	end
	if type( self.autoh ) == "number" then
		self.h = math.floor( self.parent.w * self.autow )
	end
	if type( self.automl ) == "number" then
		self.marginleft = math.floor( self.parent.w * self.automl )
	end
	if type( self.automt ) == "number" then
		self.margintop = math.floor( self.parent.h * self.automt )
	end
	if self.autox and type( self.autox ) == "number" then
		self.x = math.ceil( self.parent.w * self.autox )
	end
	if self.autoy and type( self.autoy ) == "number" then
		self.y = math.ceil( self.parent.h * self.autoy )
	end
end

function button:getAbsX()
	return math.floor(self.x + self.parent:getAbsX() + self.marginleft)-1
end

function button:getAbsY()
	return math.floor(self.y + self.parent:getAbsY() + self.margintop)-1
end

function button:draw()
	if self.state == cobalt.state or self.state == "_ALL" and self.visible then
		local colour = self.backColour
		if self.wrap == "center" then
			self.x = math.ceil( (self.parent.w/2)-self.w/2 + self.marginleft )
		end
		if self.selected then
			colour = cobalt.g.lighten( self.backColour )
		end
		if self.h == 1 then
			self.parent.surf:drawLine( self.x + self.marginleft, self.y + self.margintop, self.x + self.w+self.marginleft, self.y, " ", colour, self.foreColour )
			self.parent.surf:drawText( self.x+math.ceil((self.w/2)-#self.text/2 +  self.marginleft),self.y+ self.margintop, self.text, colour, self.foreColour )
		else
			self.parent.surf:fillRect( self.x + self.marginleft, self.y + self.margintop, self.x + self.w+self.marginleft, self.y + self.h, " ", colour, self.foreColour )
			self.parent.surf:drawText( self.x+math.ceil((self.w/2)-#self.text/2 +  self.marginleft), math.ceil(self.y+self.h/2)+ self.margintop, self.text, colour, self.foreColour )
		end
	end
end

function button:mousepressed( x, y, button )
	if (self.state == cobalt.state or self.state == "_ALL") and self.visible and self.enabled then
		if button == 1 then
			local h = self.h
			if self.h == 1 then h = 0 end
			if x >= self:getAbsX() and x <= self:getAbsX() + self.w and y >= self:getAbsY() and y <= self:getAbsY() + h then
				self.selected = true
			end
		end
	end
end

function button:mousereleased( x, y, button )
	if self.state == cobalt.state or self.state == "_ALL" and self.visible then
		local h = self.h
		if self.h == 1 then h = 0 end
		if button == 1 and x >= self:getAbsX() and x <= self:getAbsX() + self.w and y >= self:getAbsY() and y <= self:getAbsY() + h then
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