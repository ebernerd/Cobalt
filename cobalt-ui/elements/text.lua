local text = {
	x = 0,
	y = 1,
	text = "Some Text",
	unformatted = "Some Text",
	foreColour = colours.black,
	type = "text",
	autofit = true,
	marginleft = 0,
	margintop = 0,
	automl = "",
	automt = "",
	wrap = "left",
	autow = "parent",
	autoh = true,
	lines = 0,
}
text.__index = text

local function splitBySpace( text )
	local t = { }
	for i in string.gmatch( text, "%S+" ) do
		t[#t+1] = i
	end
	return t
end

local function formatText( text, w )
	local t = splitBySpace( text )
	local lines = {[1] = ""}
	local line = 1
	for i=1, #t do
		if #tostring(lines[line].." "..t[i]) > w then
			lines[line] = lines[line] .. "\n"
			line = line + 1
			lines[line] = " " .. t[i]
		else
			lines[line] = lines[line] .. " " .. t[i]
		end
	end
	return lines, #lines
end

function text:getPercentages()
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

function text.new( data, parent )
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
	local self = setmetatable(data,text)

	self.parent = parent
	self:getPercentages()
	if self.text then self.unformatted = self.text; self.text = formatText( self.unformatted, self.w or self.parent.w ) end
	self:resize()
	self.backColour = data.backColour or parent.backColour
	self.state = data.state or parent.state
	table.insert( parent.children, self )
	return self
end

function text:setMargins( t, l )
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

function text:resize()
	if self.autow=="parent" then
		self.w = self.parent.w
	elseif type( self.autow ) == "number" then
		self.w = math.ceil( self.parent.w * self.autow )
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
	self.text, self.lines = formatText( self.unformatted, self.w or self.parent.w )
end

function text:getAbsX()
	return self.x + self.parent:getAbsX()-1
end

function text:getAbsY()
	return self.y + self.parent:getAbsY()-1
end

function text:draw()
	if type(self.text) == "string" then
		self.unformatted = self.text
		self.text = formatText( self.unformatted, self.w or self.parent.w )
	end
	if self.state == cobalt.state or self.state == "_ALL" then
		if self.wrap == "right" then
			for i = 1, #self.text do
				self.parent.surf:drawText(self.parent.w - math.floor( #self.text[i] )+1, self.y + (i-1)+self.margintop, self.text[i], self.backColour, self.foreColour )
			end
		elseif self.wrap == "center" then
			for i = 1, #self.text do
				self.parent.surf:drawText( math.ceil( self.parent.w/2- #self.text[i]/2 )+math.ceil( self.marginleft), self.y + (i-1) + self.margintop, self.text[i], self.backColour, self.foreColour )
			end
		else
			for i = 1, #self.text do
				self.parent.surf:drawText( self.x + math.ceil(self.marginleft), self.y + (i-1) + self.margintop, self.text[i], self.backColour, self.foreColour )
			end
		end
	end
end

return text
