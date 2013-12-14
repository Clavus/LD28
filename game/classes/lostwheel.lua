
LostWheel = class("LostWheel", Entity)
LostWheel:include(mixin.PhysicsActor)

function LostWheel:initialize( world )
	
	Entity.initialize(self)
	
	self._img = Sprite({
		image = resource.getImage(FOLDER.ASSETS.."m_wheel.png"),
		origin_pos = Vector(35, 35)
	}) 
	
	self:initializeBody( world )
	
	self._body:applyLinearImpulse( 100, 0 )
	self._body:applyAngularImpulse( 1800 )
	
end

function LostWheel:initializeBody( world )
	
	self._body = love.physics.newBody(world, 0, 0, "dynamic")
	self._body:setMass(10)
	
	self._shape = love.physics.newCircleShape( 30 )
	self._fixture = love.physics.newFixture(self._body, self._shape)
	self._fixture:setFriction( 1 )
	self._fixture:setRestitution( 0.8 )
	
end

function LostWheel:draw()
	
	local x, y = self:getPos()
	self._img:draw( x, y, self._body:getAngle() )
	
end