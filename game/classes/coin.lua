
Coin = class("Coin", Entity)
Coin:include(mixin.PhysicsActor)
Coin:include(mixin.CollisionResolver)

function Coin:initialize( world )
	
	Entity.initialize(self)
	
	self._sprite = StateAnimatedSprite( SPRITELAYOUT["coin"], FOLDER.ASSETS.."coin.png", Vector(0,0), Vector(32, 32), Vector(16, 16) )
	self._sprite:setState("default")
	
	self._sound_coin = resource.getSound( FOLDER.ASSETS.."coin.wav", "static" )
	self._sound_coin:setVolume( 0.5 )
	
	self:initializeBody( world )
	
end

function Coin:initializeBody( world )
	
	self._body = love.physics.newBody(world, 0, 0, "kinematic")
	self._body:setMass(10)
	self._body:setGravityScale( 0 )
	
	self._shape = love.physics.newCircleShape( 16 )
	self._fixture = love.physics.newFixture(self._body, self._shape)
	self._fixture:setSensor( true )
	self._fixture:setUserData(self)
	
end

function Coin:update( dt )
	
	self._sprite:update( dt )
	
end

function Coin:draw()
	
	if self._pickedup then return end
	
	local x, y = self:getPos()
	self._sprite:draw( x, y )
	
	--love.graphics.line(self._body:getWorldPoints(self._shape:getPoints()))	
	
end

function Coin:beginContactWith( other, contact, myFixture, otherFixture, selfIsFirst )
	
	if (instanceOf( Motorcycle, other) and not self._pickedup) then
		
		self._sound_coin:play()
		game.addScore( 250 )
		
		self._pickedup = true
		
	end
	
end

function Coin:reset()
	
	self._pickedup = false
	
end