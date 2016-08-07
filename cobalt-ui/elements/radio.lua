local radio = {

	x = 1,
	y = 1,
	backColour = colours.lightGrey,
	foreColour = colours.black,
	char = "o",
	selected = false,
	group = "_MAIN",
	visible = true,
	type = "radio",
	label = "A Radio",
	autox = "",
	autoy = "",
	automl = "",
	automt = "",
	wrap = "left",
	marginleft = 0,
	margintop = 0,

}
radio.__index = radio

function radio:getPercentages()
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

function radio.new( data, parent )
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
	local self = setmetatable(data,radio)
	if not self.val then self.val = self.label end
	self.parent = parent
	self:getPercentages()
	self:resize()
	self.state = data.state or parent.state
	table.insert( parent.children, self )
	return self
end

function radio:getAbsX()
	return self.x + self.parent:getAbsX()-1 + self.marginleft
end

function radio:getAbsY()
	return self.y + self.parent:getAbsY()-1 + self.margintop
end

function radio:draw()
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
		self.parent.surf:drawText( math.ceil(self.x+2 + self.marginleft), math.ceil(self.y + self.margintop), self.label, nil, self.foreColour )
	end
end

function radio:setMargins( t, l )
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

function radio:resize()
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
