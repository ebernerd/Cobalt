local input = {
	x = 1,
	y = 1,
	w = 10,
	backPassiveColour = colours.lightGrey,
	backActiveColour = colours.lightGrey,
	forePassiveColour = colours.grey,
	foreActiveColour = colours.black,
	placeholderColour = colours.grey,
	placeholder = "",
	mask = false,
	pos = 1,
	drawpos= 1,
	scroll = 1,

	text = "",

	active = false,

	autox = "",
	autoy = "",
	autow = "",
	automt = "",
	automl = "",
	marginleft = 0,
	margintop = 0,

	displaytext = "",

	maxlength = -1,

	visible = true,

	cfl = 0,
	flash = false,
}
input.__index = input

function input.new( data, parent )
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
	local self = setmetatable(data,input)
	self.parent = parent
	self:getPercentages()
	self:resize()
	self:updateDrawPos(0)
	local highIndex = 1
	if not self.tabindex then
		for i, v in pairs( self.parent.children ) do
			if v.type and v.type == input and v.state == self.state then
				if highIndex < v.tabindex then
					highIndex = v.tabindex
				end
			end
		end
	end
	self.tabindex = highIndex + 1

	self.state = data.state or parent.state
	table.insert( parent.children, self )
	return self
end

function input:update( dt )
	if (self.state == cobalt.state or self.state == "_ALL") then
		if self.active then
			self.cfl = self.cfl + cobalt.updatespeed
			if self.cfl > 0.5 then
				self.flash = not self.flash
				self.cfl = 0
			end
		else
			self.cfl = 0
			self.flash = false
		end
	end
end

function input:updateDrawPos( pos )


	if pos > 0 then
		if self.pos <= #self.text then
			self.pos = self.pos + pos
		end
	elseif pos < 0 then
		if self.pos > 1 then
			self.pos = self.pos + pos
		end
	end
	self.drawpos = ( self.pos - self.scroll ) + self.x + self.marginleft
	if self.drawpos < self.x + self.marginleft then
		if self.scroll > 1 then
			self.scroll = self.scroll - 1
			self.drawpos = ( self.pos - self.scroll ) + self.x + self.marginleft
		end
	elseif self.drawpos > self.w + self.x + self.marginleft then
		self.scroll = self.scroll + 1
		self.drawpos = ( self.pos - self.scroll ) + self.x + self.marginleft
	end
	self.displaytext = self.text:sub( self.scroll, self.scroll + self.w )

end

function input:getPercentages()
	if type(self.w) == "string" then
		self.w = cobalt.getPercentage( self.w )
		self.autow = self.w
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

function input:resize()
	if type( self.autow ) == "number" then
		self.w = math.floor( self.parent.w * self.autow )
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

function input:setMargins( t, l )
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

function input:getAbsX()
	return self.x + self.parent:getAbsX()-1 + self.marginleft
end

function input:getAbsY()
	return self.y + math.floor(self.parent:getAbsY())-1 + self.margintop
end
function input:draw()

	if (self.state == cobalt.state or self.state == "_ALL") then
		local t = self.displaytext
		if self.mask then
			local str = ""
			for i =1, #t do
				str = str .. self.mask
			end
			t = str
		end

		local bg = self.backPassiveColour
		local fg = self.forePassiveColour
		if self.active then
			bg = self.backActiveColour
			fg = self.foreActiveColour
		end
		if #t == 0 and not self.active then
			t = self.placeholder:sub( 1, self.w )
			fg = self.placeholderColour
		end
		self.parent.surf:drawLine( self.x + self.marginleft, self.y + self.margintop, self.x + self.marginleft + self.w, self.y + self.margintop, " ", bg )
		self.parent.surf:drawText( self.x + self.marginleft, self.y + self.margintop, t, nil, fg )
		if self.flash then
			local c = t:sub( self.pos-self.scroll+1, self.pos-self.scroll+1)
			if #c < 1 then
				c = " "
			end
			self.parent.surf:drawPixel( self.drawpos, self.y + self.margintop, c, fg, bg )
		end

	end

end

function input:mousepressed( x, y, button )
	if (self.state == cobalt.state or self.state == "_ALL") then
		if x >= self:getAbsX() and x <= self:getAbsX() + self.w and y == self:getAbsY() then
			self.active = true
		else
			self.active = false
		end
	end
end

function input:keypressed( keycode, key )
	if key == "enter" then
		self.active = false
		if self.oncomplete then self:oncomplete() end
	elseif key == "backspace" then
		if self.pos > 1 then
			self.text = self.text:sub(1, self.pos-2) .. self.text:sub( self.pos )
			self:updateDrawPos(-1)
		end
	elseif key == "delete" then
		self.text = self.text:sub(1, self.pos-1) .. self.text:sub( self.pos +1 )
	elseif key == "left" then
		if self.pos > 1 then
			self:updateDrawPos(-1)
		end
	elseif key == "right" then
		if self.pos <= #self.text then
			self:updateDrawPos(1)
		end
	end
	self.cfl = 0
	self.flash = true
	self.displaytext = self.text:sub( self.scroll, self.scroll + self.w )
end

function input:textinput( t )
	if (self.state == cobalt.state or self.state == "_ALL") then
		if self.active then
			if #self.text + 1 <= self.maxlength or self.maxlength < 0 then
				self.text = self.text:sub(1, self.pos-1) .. t .. self.text:sub( self.pos )
				self:updateDrawPos(1)
			end
		end
	end
end

function input:paste( text )
	if (self.state == cobalt.state or self.state == "_ALL") then
		if self.active then
			self.text = self.text:sub(1, self.pos-1) .. text .. self.text:sub( self.pos )
			self:updateDrawPos(#text)
		end
	end
end

return input
