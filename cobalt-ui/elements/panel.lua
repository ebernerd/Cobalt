local panel = {
	x = 0,
	y = 0,
	w = 10,
	h = 5,
	backColour = colours.white,
	foreColour = colours.black,

	state = "_ALL",
	isroot = false,
	sortChildren = true,
	type = "panel",
	alwaysfocus = false,
}
panel.__index = panel

function panel.new( data, parent, isroot )
	local self = setmetatable(data,panel)
	self.children = { }
	if isroot then
		self.y = self.y + 1
		self.x = self.x + 1
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
		return self.x + self.parent:getAbsX()
	end
	return self.x
end

function panel:getAbsY()
	if not self.isroot then
		return self.y + self.parent:getAbsY()
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

function panel:update( dt )

	for i, v in pairs( self.children ) do
		if v.update then v:update() end
	end

end

function panel:draw( )
	if self.state == cobalt.state or self.state == "_ALL" then
		cobalt.g.rect("fill", self:getAbsX(), self:getAbsY(), self.w, self.h, self.backColour)

		for i, v in pairs( self.children ) do
			if v.draw then v:draw() end
		end
	end
end

function panel:mousepressed( x, y, button )
	if self.alwaysfocus then
		self:bringToFront()
	end

	if x >= self:getAbsX() and x <= self:getAbsX() + self.w and y >= self:getAbsY() and y <= self:getAbsY() + self.h then
		self:bringToFront()

		if self.state == cobalt.state or self.state == "_ALL" then
			--

			for i, v in pairs( self.children ) do
				if v.mousepressed then v:mousepressed( x, y, button ) end
			end
		end

		return true
	end
end



function panel:mousereleased( x, y, button )

	if x >= self:getAbsX() and x <= self:getAbsX() + self.w and y >= self:getAbsY() and y <= self:getAbsY() + self.h then
		if self.state == cobalt.state or self.state == "_ALL" then
			--

			for i, v in pairs( self.children ) do
				if v.mousereleased then v:mousereleased( x, y, button ) end
			end
		end
		return true
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

function panel:keyreleased( keycode, key )
	if self.state == cobalt.state or self.state == "_ALL" then

		for k, v in pairs( self.children ) do
			if v.keyreleased then v:keyreleased( keycode, key ) end
		end

	end
end

return panel
