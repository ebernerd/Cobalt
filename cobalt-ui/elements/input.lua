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
	tabindex = 1,
}
input.__index = input

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

function input:update( dt )
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
		local t = self.text
		if #self.text > self.w-1 then
			t = self.text:sub( #self.text-self.w+1, #self.text )
		end
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
		if self.flash and self.active then
			self.parent.surf:drawText( math.floor(self.x+#t+self.marginleft), math.floor(self.y+self.margintop), "_", bc, fc )
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
				self.text = self.text:sub(1, #self.text-1 )
			elseif keycode == 211 then

			elseif keycode == 28 then
				self.active = false
				if self.oncomplete then self:oncomplete() end
			end
		end
	end
end

function input:textinput( t )
	if self.state == cobalt.state or self.state == "_ALL" then
		if self.active and (#self.text < self.maxlength or self.maxlength < 0) then
			self.text = self.text .. t
		end
	end
end

return input
