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
	maxlength = -1
}
input.__index = input

function input.new( data, parent )
	data = data or { }
	local self = setmetatable( data, input )
	self.parent = parent
	self.state = data.state or parent.state
	table.insert( parent.children, self )
	return self
end

function input:getAbsX()
	return self.x + self.parent:getAbsX()-1
end

function input:getAbsY()
	return self.y + math.floor(self.parent:getAbsY())-1
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
		self.parent.surf:drawLine( math.floor(self.x), math.floor(self.y), math.floor(self.x) + self.w, math.floor(self.y), " ", bc, fc )
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
				self.parent.surf:drawText( math.floor(self.x), math.floor(self.y), mskstr, bc, fc )
			else
				self.parent.surf:drawText( math.floor(self.x), math.floor(self.y), t, bc, fc )
			end
		else
			if not self.active then
				self.parent.surf:drawText( math.floor(self.x), math.floor(self.y), self.placeholder, bc, self.placholderColour )
			end
		end
		if self.flash then
			self.parent.surf:drawText( math.floor(self.x+#t), math.floor(self.y), "_", bc, fc )
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
