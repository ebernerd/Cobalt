local text = {
	x = 0,
	y = 1,
	text = "Some Text",
	unformatted = "Some Text",
	foreColour = colours.black,
	type = "text",
	autofit = true,
	marginleft = 0,
	marginright = 0,
	margintop = 0,
	marginbottom = 0,
	automl = "",
	automr = "",
	automt = "",
	automb = "",
	wrap = "left",
	autow = "parent",
	autoh = true,
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
	return lines
end

function text:getPercentages()
	if type(self.w) == "string" then
		self.w = cobalt.getPercentage( self.w )
		self.autow = "perc:" .. self.w
	else
		self.autow = "none"
	end
	if type(self.h) == "string" then
		self.h = cobalt.getPercentage( self.h )
		self.autoh = "perc:" .. self.h
	else
		self.autoh = "none"
	end

	if type(self.marginleft) == "string" then
		self.marginleft = cobalt.getPercentage( self.marginleft )
		self.automl = "perc:" .. self.marginleft
	end
	if type(self.marginright) == "string" then
		self.marginright = cobalt.getPercentage( self.marginright )
		self.automr = "perc:" .. self.marginright
	end
	if type(self.margintop) == "string" then
		self.margintop = cobalt.getPercentage( self.margintop )
		self.automt = "perc:" .. self.margintop
	end
	if type(self.marginbottom) == "string" then
		self.marginbottom = cobalt.getPercentage( self.marginbottom )
		self.automl = "perc:" .. self.marginbottom
	end
	if type(self.x) == "string" then
		self.x = cobalt.getPercentage( self.x )
		self.autox = "perc:" .. self.x
	end
	if type(self.y) == "string" then
		self.y = cobalt.getPercentage( self.y )
		self.autoy = "perc:" .. self.y
	end
end

function text.new( data, parent )
	local self = setmetatable( data, text )

	self.parent = parent
	self:getPercenages()
	if self.text then self.unformatted = self.text; self.text = formatText( self.unformatted, self.w or self.parent.w ) end
	self:resize()
	self.backColour = data.backColour or parent.backColour
	self.state = data.state or parent.state
	table.insert( parent.children, self )
	return self
end

function text:setMargins( t, r, b, l )
	if t then
		self.margintop = t or self.margintop
		if type(t) == "string" then
			self:getPercentages()
		else
			self.automt = "none"
		end
	end
	if r then
		self.marginright = r or self.marginright
		if type(r) == "string" then
			self:getPercentages()
		else
			self.automr = "none"
		end
	end
	if b then
		self.margintop = b or self.margintop
		if type(b) == "string" then
			self:getPercentages()
		else
			self.automb = "none"
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
	elseif self.autow:sub( 1, 4 ) == "perc" then
		local perc = self.autow:match("perc:(%d+)")
		self.w = math.ceil( self.parent.w * cobalt.setPercentage( perc ) )
	end
	if self.automl:sub( 1, 4 ) == "perc" then
		local perc = self.automl:match("perc:(%d+)")
		self.marginleft = math.floor( self.parent.w * cobalt.setPercentage( perc ) )
	end
	if self.automr:sub( 1, 4 ) == "perc" then
		local perc = self.automr:match("perc:(%d+)")
		self.marginright = math.ceil( self.parent.w * cobalt.setPercentage( perc ) )
	end
	if self.automt:sub( 1, 4 ) == "perc" then
		local perc = self.automt:match("perc:(%d+)")
		self.margintop = math.floor( self.parent.h * cobalt.setPercentage( perc ) )
	end
	if self.automb:sub( 1, 4 ) == "perc" then
		local perc = self.automb:match("perc:(%d+)")
		self.marginbottom = math.ceil( self.parent.h * cobalt.setPercentage( perc ) )
	end
	if self.autox and self.autox:sub( 1, 4 ) == "perc" then
		local perc = self.autox:match("perc:(%d+)")
		self.x = math.ceil( self.parent.w * cobalt.setPercentage( perc ) )
	end
	if self.autoy and self.autoy:sub( 1, 4 ) == "perc" then
		local perc = self.autoy:match("perc:(%d+)")
		self.y = math.ceil( self.parent.h * cobalt.setPercentage( perc ) )
	end
	self.text = formatText( self.unformatted, self.w or self.parent.w )
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
				self.parent.surf:drawText( (self.w-self.x+1) - math.floor( #self.text[i] )+math.ceil( self.marginright ), self.y + (i-1)+self.margintop, self.text[i], self.backColour, self.foreColour )
			end
		elseif self.wrap == "center" then
			for i = 1, #self.text do
				self.parent.surf:drawText( math.ceil( (self.w-self.x)/2 )+1 - math.ceil( #self.text[i]/2 )+math.ceil( self.marginleft), self.y + (i-1) + self.margintop, self.text[i], self.backColour, self.foreColour )
			end
		else
			for i = 1, #self.text do
				self.parent.surf:drawText( self.x + math.ceil(self.marginleft), self.y + (i-1) + self.margintop, self.text[i], self.backColour, self.foreColour )
			end
		end
	end
end

return text
