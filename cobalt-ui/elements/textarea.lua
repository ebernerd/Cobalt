local textarea = {
	x = 1,
	y = 1,
	w = 10,
	h = 5,
	backPassiveColour = colours.lightGrey,
	backActiveColour = colours.lightGrey,
	forePassiveColour = colours.grey,
	foreActiveColour = colours.black,
	placeholderColour = colours.grey,
	placeholder = "",
	pos = 1,
	line = 1,
	drawposx = 1,
	drawposy = 1,
	scrollx = 1,
	scrolly = 1,

	lines = {[1]=""},

	active = false,

	autox = "",
	autoy = "",
	autow = "",
	automt = "",
	automl = "",
	marginleft = 0,
	margintop = 0,

	maxlength = -1,

	visible = true,

	cfl = 0,
	flash = false,
}
textarea.__index = textarea

function textarea.new( data, parent )
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
	local self = setmetatable(data,textarea)
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

function textarea:update( dt )
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

function textarea:updateDrawPos( posx, posy )
	local posx = posx or 0
	local posy = posy or 0



	if posx > 0 then
		if self.pos <= #self.lines[self.line] then
			self.pos = self.pos + posx
		end
	elseif posx < 0 then
		if self.pos > 1 then
			self.pos = self.pos + posx
		end
	end
	if posy > 0 then
		if self.line + posy <= #self.lines then
			self.line = self.line + posy
			if self.pos > #self.lines[self.line]+1 then
				self.pos = #self.lines[self.line]+1
			end
		end
	elseif posy < 0 then
		if (self.line + posy) >= 1 then
			self.line = self.line + posy
			if self.pos > #self.lines[self.line]+1 then
				self.pos = #self.lines[self.line]+1
			end
		end
	end
	self.drawposx = ( self.pos - self.scrollx ) + self.x + self.marginleft
	self.drawposy = ( self.line - self.scrolly ) + self.y + self.margintop
	if self.drawposx < self.x + self.marginleft then
		if self.scrollx > 1 then
			repeat
				self.scrollx = self.scrollx - 1
				self.drawposx = ( self.pos - self.scrollx ) + self.x + self.marginleft
			until self.drawposx > self.x + self.marginleft - 1
		end
	elseif self.drawposx > self.w + self.x + self.marginleft then
		repeat
			self.scrollx = self.scrollx + 1
			self.drawposx = ( self.pos - self.scrollx ) + self.x + self.marginleft
		until self.drawposx < self.w + self.x + self.marginleft + 1
	end
	if self.drawposy < self.y + self.margintop then
		self.scrolly = self.scrolly - 1
		self.drawposy = ( self.line - self.scrolly ) + self.y + self.margintop
	elseif self.drawposy  > self.h + self.y + self.margintop then
		self.scrolly = self.scrolly + 1
		self.drawposy = ( self.line - self.scrolly ) + self.y + self.margintop
	end

end

function textarea:getPercentages()
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

function textarea:resize()
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

function textarea:setMargins( t, l )
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

function textarea:getAbsX()
	return self.x + self.parent:getAbsX()-1 + self.marginleft
end

function textarea:getAbsY()
	return self.y + math.floor(self.parent:getAbsY())-1 + self.margintop
end
function textarea:draw()

	if (self.state == cobalt.state or self.state == "_ALL") then

		local bg = self.backPassiveColour
		local fg = self.forePassiveColour
		if self.active then
			bg = self.backActiveColour
			fg = self.foreActiveColour
		end
		self.parent.surf:fillRect( self.x + self.marginleft, self.y + self.margintop, self.x + self.marginleft + self.w, self.y + self.margintop + self.h, " ", bg )
		local l = 0
		for i = self.scrolly, self.scrolly+self.h do
			if self.lines[i] and type(self.lines[i]) == "string" then
				local t = self.lines[i]:sub( self.scrollx, self.scrollx + self.w ) or " "
				self.parent.surf:drawText( self.x + self.marginleft, self.y + self.margintop + l, t, nil, fg )
				l = l + 1
			end
		end
		local t = self.lines[self.line]:sub( self.scrollx, self.scrollx + self.w ) or " "
		if self.flash then
			local c = t:sub( self.pos-self.scrollx+1, self.pos-self.scrollx+1)
			if #c < 1 then
				c = " "
			end
			self.parent.surf:drawPixel( self.drawposx, self.drawposy, c, fg, bg )
		end

	end

end

function textarea:mousepressed( x, y, button )
	if (self.state == cobalt.state or self.state == "_ALL") then
		if x >= self:getAbsX() and x <= self:getAbsX() + self.w and y >= self:getAbsY() and y <= self:getAbsY() + self.h then
			self.active = true
			local relx, rely = math.floor(x - self:getAbsX()), math.floor(y-self:getAbsY())
			relx = relx + self.scrollx
			rely = rely + self.scrolly
			self.cfl = 0
			self.flash = true
			if self.lines[rely] then
				self.line = rely
				self.pos = relx
				if self.pos > #self.lines[self.line] then self.pos = #self.lines[self.line]+1 end
				self:updateDrawPos()
			else
				self.line = #self.lines
				self.pos = relx
				if self.pos > #self.lines[self.line] then self.pos = #self.lines[self.line]+1 end
				self:updateDrawPos()
			end
		else
			self.active = false
		end
	end
end

function textarea:keypressed( keycode, key )
	if self.state == cobalt.state or self.state == "_ALL" and self.active then
		if key == "enter" then
			local lstr = self.lines[self.line]:sub(self.pos)
			self.lines[self.line] = self.lines[self.line]:sub(1, self.pos-1)

			self.line = self.line + 1
			table.insert( self.lines, self.line, lstr or " ")

			self.pos = 1
			self.scrollx = 1
			self:updateDrawPos()
		elseif key == "backspace" then
			if self.pos > 1 then
				self.lines[self.line] = self.lines[self.line]:sub(1, self.pos-2) .. self.lines[self.line]:sub( self.pos )
				self:updateDrawPos(-1)
			else
				if self.line > 1 then
					local lstr = self.lines[self.line]:sub(self.pos)
					self.lines[self.line] = self.lines[self.line]:sub(1, self.pos)
					table.remove( self.lines, self.line)
					self.line = self.line - 1
					self:updateDrawPos(#self.lines[self.line], 0 )
					self.lines[self.line] = self.lines[self.line]:sub(1, self.pos) .. lstr .. self.lines[self.line]:sub(self.pos+#lstr)

				end
			end
		elseif key == "tab" then
			self.lines[self.line] = self.lines[self.line]:sub(1, self.pos-1) .. "   " .. self.lines[self.line]:sub( self.pos )
			self:updateDrawPos(3,0)
		elseif key == "delete" then
			self.lines[self.line] = self.lines[self.line]:sub(1, self.pos-1) .. self.lines[self.line]:sub( self.pos +1 )
			if self.pos == #self.lines[self.line] + 1 then
				if self.lines[self.line+1] then
					local lstr = self.lines[self.line+1]
					table.remove( self.lines, self.line+1 )
					self.lines[self.line] = self.lines[self.line]:sub(1, self.pos ) .. lstr
				end
			end
		elseif key == "left" then
			if self.pos > 1 then
				self:updateDrawPos(-1)
			elseif self.pos == 1 then
				if self.line > 1 then
					self:updateDrawPos( #self.lines[self.line-1], -1 )
				end
			end
		elseif key == "right" then
			if self.pos <= #self.lines[self.line] then
				self:updateDrawPos(1)
			else
				if self.lines[self.line+1] then
					self.pos = 1
					self.scrollx = 1
					self:updateDrawPos(0, 1)
				end
			end
		elseif key == "up" then
			if self.line > 1 then
				self:updateDrawPos( 0, -1 )
			end
		elseif key == "down" then
			if self.line + 1 <= #self.lines then
				self:updateDrawPos( 0, 1 )
			end
		elseif key == "end" then
			self.pos = #self.lines[self.line]+1
			self:updateDrawPos()
		elseif key == "home" then
			self.pos = 1
			self:updateDrawPos()
		end
		self.cfl = 0
		self.flash = true
	end
end

function textarea:textinput( t )
	if (self.state == cobalt.state or self.state == "_ALL") then
		if self.active then
			if #self.lines[self.line] + 1 <= self.maxlength or self.maxlength < 0 then
				self.lines[self.line] = self.lines[self.line]:sub(1, self.pos-1) .. t .. self.lines[self.line]:sub( self.pos )
				self:updateDrawPos(1)
			end
		end
	end
end

function textarea:paste( text )
	if (self.state == cobalt.state or self.state == "_ALL") then
		if self.active then
			self.lines[self.line] = self.lines[self.line]:sub(1, self.pos-1) .. text .. self.lines[self.line]:sub( self.pos )
			self:updateDrawPos(#text)
		end
	end
end

return textarea
