local input = {
	x = 1,
	y = 1,
	w = 25,
	backPassiveColour = colours.white,
	backActiveColour = colours.white,
	forePassiveColour = colours.lightGrey,
	foreActiveColour = colours.black,
	placeholderColour = colours.lightGrey,
	placeholder = "",
	text = "",
	mask = "",
	active = false,
	timer = 0,
	flash = false,
	type = "input",
	autox = "",
	autoy = "",
	automl = "",
	automt = "",
	autow = "",
	marginleft = 0,
	margintop = 0,
	maxlength = -1,
	pos = 1,
	scroll = 0,
	drawx = 0,
}
input.__index = input

function input.new( data, parent )
	data = data or { }
	local self = setmetatable( data, input )
	self.parent = parent
	if type(self.w) == "string" then
		self.w = cobalt.getPercentage( self.w )
		self.autow = "perc:" .. self.w
	end
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

function input:resize()
	if self.autow:sub( 1, 4 ) == "perc" then
		local perc = self.autow:match("perc:(%d+)")
		cobalt.setPercentage( perc )
		self.w = math.ceil( self.parent.w * cobalt.setPercentage( perc ) )
	end
	if self.automl:sub( 1, 4 ) == "perc" then
		local perc = self.automl:match("perc:(%d+)")
		self.marginleft = math.floor( self.parent.w * cobalt.setPercentage( perc ) )
	end
	if self.automt:sub( 1, 4 ) == "perc" then
		local perc = self.automt:match("perc:(%d+)")
		self.margintop = math.floor( self.parent.h * cobalt.setPercentage( perc ) )-1
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

function input:getAbsX()
	return self.x + self.parent:getAbsX()-1 + self.marginleft
end

function input:getAbsY()
	return self.y + math.floor(self.parent:getAbsY())-1 + self.margintop
end

function input:update()
	if self.active then
		self.timer = self.timer + 0.1
		if self.timer > 0.5 then
			self.timer = 0
			self.flash = not self.flash
		end
	else
		self.flash = false
	end
end

function input:draw()


	if self.state == cobalt.state or self.state == "_ALL" then
		local bc = self.backPassiveColour
		local fc = self.forePassiveColour
		if self.active then
			bc = self.backActiveColour
			fc = self.foreActiveColour
		end
		self.parent.surf:drawLine( math.floor(self.x + self.marginleft), math.floor(self.y + self.margintop), math.floor(self.x + self.marginleft) + self.w, math.floor(self.y + self.margintop), " ", bc, fc )
		--local t = (self.text:sub( #self.text-self.w+self.scroll )):sub(1, self.w)
		local t = self.text:sub( self.scroll, self.scroll + self.w )
		if #self.text > 0 then
			if self.mask ~= ""  then
				local mskstr = ""
				for i = 1, #self.text do
					mskstr = mskstr .. self.mask
				end
				self.parent.surf:drawText( math.floor(self.x+ self.marginleft), math.floor(self.y+ self.margintop), mskstr, bc, fc )
			else
				self.parent.surf:drawText( math.floor(self.x+ self.marginleft), math.floor(self.y+ self.margintop), t, bc, fc )
			end
		else
			if not self.active then
				self.parent.surf:drawText( math.floor(self.x+ self.marginleft), math.floor(self.y+ self.margintop), self.placeholder, bc, self.placholderColour )
			end
		end
		if self.flash then
			--self.parent.surf:drawText( math.floor(self.x+#t+ self.marginleft), math.floor(self.y+ self.margintop), "_", bc, fc )
			local pixelchar = " "
			if self.text:sub( self.pos, self.pos ) ~= "" then
				pixelchar = self.text:sub(self.pos, self.pos)
			end
			self.parent.surf:drawPixel( math.floor(self.drawx), math.floor(self.y+ self.margintop), pixelchar, fc, bc )
		end
	end
end

function input:mousepressed( x, y, button )
	if button == 1 and x >= self:getAbsX() and x <= self:getAbsX() + self.w and y == self:getAbsY() then
		self.active = true
	end
end


function input:mousereleased( x, y, button )
	if button == 1 and x >= self:getAbsX() and x <= self:getAbsX() + self.w and y == self:getAbsY() then
		--
	else
		self.active = false
	end
end

function input:keypressed( keycode, key )

	if self.active then
		if self.state == cobalt.state or self.state == "_ALL" then
			self.timer = 0
			self.flash = true
			if keycode == 14 then
				if self.pos > 1 then

					self.pos = self.pos - 1

					self.text = self.text:sub( 1, self.pos-1 ) .. self.text:sub(self.pos+1, #self.text)
					if self.drawx-self.x == self.marginleft then
						self.scroll = self.scroll-1
					end
				end
			elseif keycode == 211 then
				if self.pos < #self.text+1 then
					self.text = self.text:sub( 1, self.pos-1 ) .. self.text:sub(self.pos+1, #self.text)
				end
			elseif keycode == 203 then
				if self.pos > 1 then
					self.pos = self.pos - 1
					if self.drawx-self.x == self.marginleft then
						self.scroll = self.scroll-1
					end
				end
			elseif keycode == 205 then
				if self.pos < #self.text+1 then
					self.pos = self.pos + 1
					if self.drawx - self.x == self.w+self.marginleft then
						self.scroll = self.scroll + 1
					end
				end
			elseif keycode == 28 then
				self.active = false
				if self.oncomplete then self:oncomplete() end
			end
			local s = 0
			if self.scroll == 0 then
				s = 1
			end
			self.drawx = self.pos - (self.scroll) - (self.x-self.marginleft-1)+s
		end
	end
end

function input:textinput( t )
	if self.state == cobalt.state or self.state == "_ALL" then
		if self.active and (#self.text < self.maxlength or self.maxlength < 0) then

			if self.drawx - self.x == self.w+self.marginleft-1 then
				self.scroll = self.scroll + 1
			end

			self.drawx = self.pos - self.scroll - (self.x-self.marginleft-1)+1

			self.pos = self.pos + 1
			self.text = self.text:sub( 1, self.pos-1 ) .. t .. self.text:sub(self.pos, #self.text)
		end
	end
end

return input
