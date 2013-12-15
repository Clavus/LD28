
Box = class("Box", Entity)
Box:include(mixin.PhysicsActor)

function Box:initialize( world )
	
	Entity.initialize(self)
	
	self._img = Sprite({
		image = resource.getImage(FOLDER.ASSETS.."box.png"),
		origin_pos = Vector(32, 32)
	}) 
	
	self:initializeBody( world )
	
end

function Box:initializeBody( world )
	
	self._body = love.physics.newBody(world, 0, 0, "dynamic")
	self._body:setMass(10)
	
	self._shape = love.physics.newRectangleShape( 64, 64 )
	self._fixture = love.physics.newFixture(self._body, self._shape)
	self._fixture:setFriction( 30 )
	self._fixture:setRestitution( 0.02 )
	self._fixture:setUserData(self)
	
end

function Box:draw()
	
	local x, y = self:getPos()
	self._img:draw( x, y, self._body:getAngle() )
	
	--love.graphics.line(self._body:getWorldPoints(self._shape:getPoints()))	
	
end