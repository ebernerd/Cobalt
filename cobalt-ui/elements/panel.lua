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
}
panel.__index = panel

function panel.new( data, parent, isroot )
	local self = setmetatable(data,panel)
	self.children = { }
	self.surf = surface.create( self.w, self.h, " ", self.backColour, self.foreColour )
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
	return self
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

function panel:centerInParent( x, y )
	x = x or true
	y = y or false
	if x then
		self.x = math.ceil(self.parent.w/2 - self.w/2)
	end
	if y then
		self.y = math.floor(self.parent.h/2 - self.h/2)
	end
end

function panel:update( dt )

	for i, v in pairs( self.children ) do
		if v.update then v:update() end
	end

end

function panel:draw( )
	if self.state == cobalt.state or self.state == "_ALL" then
		self.surf:clear(" ", self.backColour, self.foreColour)
		for i, v in pairs( self.children ) do
			if v.draw then v:draw() end
		end
		if self.isroot then
			self.surf:render(term, self.x, self.y, self.scrollx, self.scrolly, self.scrollx + self.w, self.scrolly+self.h)
		else
			self.parent.surf:drawSurface(self.x, self.y, self.surf)
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
