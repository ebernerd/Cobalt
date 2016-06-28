local text = {
	x = 0,
	y = 1,
	text = "Some Text",
	unformatted = "Some Text",
	foreColour = colours.black,
	type = "text",
	autofit = true,
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
	--[=[local str = ""
	for i=1, #lines do
		str = str .. lines[i]
	end
	return str--]=]
	return lines
end

function text.new( data, parent )
	local self = setmetatable( data, text )

	self.parent = parent
	if not self.w then
		self.w = self.parent.w
		self.autow = true

	else
		if type(self.w) == "string" then
			if self.w:sub( #self.w ) == "%" then
				local perc = self.w:sub( 1, #self.w-1 )
				perc = tonumber(perc)
				if perc > 100 or perc < 0 then
					error( "Invalid percentage" )
				else
					self.wperc = perc
					self.w = math.ceil( self.parent.w * tonumber( "0." .. perc ) )
					self.autow = "perc"
				end
			else
				error("Expected number or percentage")
			end
		end
	end
	if self.text then self.unformatted = self.text; self.text = formatText( self.unformatted, self.w or self.parent.w ) end
	self.backColour = data.backColour or parent.backColour
	self.state = data.state or parent.state
	table.insert( parent.children, self )
	return self
end

function text:resize()
	if self.autow=="parent" then
		self.w = self.parent.w
	elseif self.autow == "perc" then
		self.w = math.ceil( self.parent.w * tonumber( "0." .. self.wperc ) )
	end
	self.text = formatText( self.unformatted, self.w or self.parent.w )
end

function text:getAbsX()
	return self.x + self.parent:getAbsX()-1
end

function text:getAbsY()
	return self.y + self.parent:getAbsY()-1
end

function text:centerInParent( x, y )
	x = x or true
	y = y or false
	if x then
		self.x = math.ceil(self.parent.w/2 - #self.text/2)
	end
	if y then
		self.y = math.ceil(self.parent.h/2)
	end
end

function text:draw()
	if type(self.text) == "string" then
		self.unformatted = self.text
		self.text = formatText( self.unformatted, self.w or self.parent.w )
	end
	if self.state == cobalt.state or self.state == "_ALL" then
		if self.wrap == "right" then
			for i = 1, #self.text do
				self.parent.surf:drawText( (self.w-self.x+1) - math.floor( #self.text[i] ), self.y + (i-1), self.text[i], self.backColour, self.foreColour )
			end
		elseif self.wrap == "center" then
			for i = 1, #self.text do
				self.parent.surf:drawText( math.ceil( (self.w-self.x)/2 )+1 - math.ceil( #self.text[i]/2 ), self.y + (i-1), self.text[i], self.backColour, self.foreColour )
			end
		else
			for i = 1, #self.text do
				self.parent.surf:drawText( self.x, self.y + (i-1), self.text[i], self.backColour, self.foreColour )
			end
		end
	end
end

return text
