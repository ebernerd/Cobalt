local panel = {
	x = 1,
	y = 1,
	w = 10,
	h = 5,
	backColour = colours.white,
	foreColour = colours.black,

	state = "_ALL",
	isroot = false,
	sortChildren = true,
	type = "panel",
	alwaysfocus = false,
	scrollx = 0,
	scrolly = 0,
	autosize = true,
	marginleft = 0,
	marginright = 0,
	margintop = 0,
	marginbottom = 0,
	autow = "none",
	autoh = "none",
	automl = false,
	automr = false,
	automt = false,
	automb = false,
	wrap = "left",
}
panel.__index = panel

function panel.new( data, parent, isroot )
	local self = setmetatable(data,panel)

	if not isroot then
		self:resize()
	end

	self.children = { }
	self.bw = self.w
	self.bh = self.h
	if isroot then
		table.insert( cui.roots, self )
		self.isroot = true
	else
		if not parent then
			error( "Expected parent object")
		end
		table.insert( parent.children, self )
		self.parent = parent
	end
	if type(self.w) == "string" then
		self.w = cobalt.getPercentage( self.w )
		self.autow = "perc:" .. self.w
	end
	if type(self.h) == "string" then
		self.h = cobalt.getPercentage( self.h )
		self.autoh = "perc:" .. self.h
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


	self:resize()
	return self
end

function panel:resize()
	if self.autow:sub( 1, 4 ) == "perc" then
		local perc = self.autow:match("perc:(%d+)")
		if self.parent then
			self.w = math.ceil( self.parent.w * cobalt.setPercentage( perc ) )
		else
			self.w = math.ceil( cobalt.window.getWidth() * cobalt.setPercentage( perc ) )
		end
	end
	if self.automl and self.automl:sub( 1, 4 ) == "perc" then
		local perc = self.automl:match("perc:(%d+)")
		if self.parent then
			self.marginleft = math.ceil( self.parent.w * cobalt.setPercentage( perc ) )
		else
			self.marginleft = math.ceil( cobalt.window.getWidth() * cobalt.setPercentage( perc ) )
		end
	end
	if self.automr and self.automr:sub( 1, 4 ) == "perc" then
		local perc = self.automr:match("perc:(%d+)")
		if self.parent then
			self.marginright = math.ceil( self.parent.w * cobalt.setPercentage( perc ) )
		else
			self.marginright = math.ceil( cobalt.window.getWidth() * cobalt.setPercentage( perc ) )
		end
	end
	if self.automt and self.automt:sub( 1, 4 ) == "perc" then
		local perc = self.automt:match("perc:(%d+)")
		if self.parent then
			self.margintop = math.ceil( self.parent.w * cobalt.setPercentage( perc ) )
		else
			self.margintop = math.ceil( cobalt.window.getWidth() * cobalt.setPercentage( perc ) )
		end
	end
	if self.automb and self.automb:sub( 1, 4 ) == "perc" then
		local perc = self.automb:match("perc:(%d+)")
		if self.parent then
			self.marginbottom = math.ceil( self.parent.w * cobalt.setPercentage( perc ) )
		else
			self.marginbottom = math.ceil( cobalt.window.getWidth() * cobalt.setPercentage( perc ) )
		end
	end
	if self.autox and self.autox and self.autox:sub( 1, 4 ) == "perc" then
		local perc = self.autox:match("perc:(%d+)")
		if self.parent then
			self.x = math.ceil( self.parent.w * cobalt.setPercentage( perc ) )
		else
			self.x = math.ceil( cobalt.window.getWidth() * cobalt.setPercentage( perc ) )
		end
	end
	if self.autoy and self.autoy and self.autoy:sub( 1, 4 ) == "perc" then
		local perc = self.autoy:match("perc:(%d+)")
		if self.parent then
			self.y = math.ceil( self.parent.w * cobalt.setPercentage( perc ) )
		else
			self.y = math.ceil( cobalt.window.getWidth() * cobalt.setPercentage( perc ) )
		end
	end
	self.surf = surface.create( self.w, self.h, " ", self.backColour, self.foreColour )
end

function panel:getAbsX()
	if not self.isroot then
		return self.x + self.parent:getAbsX()-1
	end
	return self.x
end

function panel:getAbsY()
	if not self.isroot then
		return self.y + math.floor(self.parent:getAbsY())-1
	end
	return self.y
end

function panel:getAbsW()
	return self:getAbsX() + self.w
end

function panel:getAbsH()
	return self:getAbsY() + self.h
end

function panel:setBackgroundColour( colour )
	self.backColour = colour or self.backColour
end

function panel:add( type, data )
	return cui.elements[type].new( data, self, false )
end

function panel:bringToFront()

	if self.parent and self.parent.sortChildren then
		for k, v in pairs( self.parent.children ) do
			if v == self then
				table.remove( self.parent.children, k )
				table.insert( self.parent.children, 1, v )
			end
		end
	else
		for k, v in pairs( cui.roots ) do
			if v == self then
				table.remove( cui.roots, k )
				table.insert( cui.roots, 1, v )
			end
		end
	end

end
function panel:sendToBack()

	if self.parent and self.parent.sortChildren then
		for k, v in pairs( self.parent.children ) do
			if v == self then
				table.remove( self.parent.children, k )
				table.insert( self.parent.children, #self.parent.children, v )
			end
		end
	else
		for k, v in pairs( cui.roots ) do
			if v == self then
				table.remove( cui.roots, k )
				table.insert( cui.roots, #cui.roots, v )
			end
		end
	end

end

function panel:update( dt )
	if self.w ~= self.bw then
		for i, v in pairs( self.children ) do
			if v.onparentresize then v:resize() end
		end
		self.bw = self.w
		self:resize()
	end
	if self.h ~= self.bh then
		for i, v in pairs( self.children ) do
			if v.resize then v:resize() end
		end
		self.bh = self.h
		self:resize()
	end
	for i, v in pairs( self.children ) do
		if v.update then v:update() end
	end

end

function panel:draw( )
	if self.wrap == "center" then
		self.x = ( self.parent.w/2 - self.w/2 ) + self.marginleft
	end
	if self.state == cobalt.state or self.state == "_ALL" then
		self.surf:clear(" ", self.backColour, self.foreColour)
		for i, v in pairs( self.children ) do
			if v.draw then v:draw() end
		end
		if self.isroot then
			self.surf:render(term, self.x+self.marginleft, self.y+self.margintop, self.scrollx, self.scrolly, self.scrollx + self.w, self.scrolly+self.h)
		else
			self.parent.surf:drawSurface(self.x+self.marginleft, self.y+self.marginright, self.surf)
		end
	end
end

function panel:mousepressed( x, y, button )
	if self.alwaysfocus then
		self:bringToFront()
	end

	if self.state == cobalt.state or self.state == "_ALL" then
		if x >= self:getAbsX() and x <= self:getAbsX() + self.w and y >= self:getAbsY() and y <= self:getAbsY() + self.h then
			self:bringToFront()
			for i, v in pairs( self.children ) do
				if v.mousepressed then v:mousepressed( x, y, button ) end
			end

			return true
		end
	end
end



function panel:mousereleased( x, y, button )

	if x >= self:getAbsX() and x <= self:getAbsX() + self.w and y >= self:getAbsY() and y <= self:getAbsY() + self.h then
		if self.state == cobalt.state or self.state == "_ALL" then
			for i, v in pairs( self.children ) do
				if v.mousereleased then v:mousereleased( x, y, button ) end
			end
			return true
		end
	end
end

function panel:textinput( t )

	if self.state == cobalt.state or self.state == "_ALL" then
		--

		for k, v in pairs( self.children ) do
			if v.textinput then v:textinput( t ) end
		end
	end

end

function panel:keypressed( keycode, key )
	if self.state == cobalt.state or self.state == "_ALL" then
		for k, v in pairs( self.children ) do
			if v.keypressed then v:keypressed( keycode, key ) end
		end

	end
end

function panel:mousedrag( x, y )
	for k, v in pairs( self.children ) do
		if v.mousedrag then v:mousedrag( x, y ) end
	end
end

function panel:keyreleased( keycode, key )
	if self.state == cobalt.state or self.state == "_ALL" then

		for k, v in pairs( self.children ) do
			if v.keyreleased then v:keyreleased( keycode, key ) end
		end

	end
end

return panel
