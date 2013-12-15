
Motorcycle = class("Motorcycle", Entity)
Motorcycle:include(mixin.PhysicsActor)
Motorcycle:include(mixin.CollisionResolver)

local wheel_x, wheel_y = -38, 38
local wheelTorque = 700000
local controlAngularImpulse = 8000
local boostImpulse = 400
local chargeDrainPSec = 300
local chargeRegenPSec = 400
local chargeRecoveryDelay = 3

function Motorcycle:initialize( world )
	
	Entity.initialize(self)
	
	self._img_frame = Sprite({
			image = resource.getImage(FOLDER.ASSETS.."m_frame.png"),
			origin_pos = Vector(70, 50)
	}) 
	
	self._img_wheel = Sprite({
			image = resource.getImage(FOLDER.ASSETS.."m_wheel.png"),
			origin_pos = Vector(35, 35)
	}) 
	
	self._img_engine = Sprite({
			image = resource.getImage(FOLDER.ASSETS.."m_engine.png"),
			origin_pos = Vector(58, 51)
	}) 
	
	self._img_suspension = Sprite({
			image = resource.getImage(FOLDER.ASSETS.."m_suspension.png"),
			origin_pos = Vector(54, 23)
	})
	
	self:initializeBody( world )
	
	self.maxHealth = 1000
	self.health = 1000
	
	self.maxCharge = 100
	self.charge = 100
	self.chargeRegenStart = 0
	
	self._lastGroundContact = 0

	-- initial push
	self._body:applyLinearImpulse( 250, -230 )
	
	gui:addDynamicElement(0, Vector(0,0), function()
		love.graphics.setColor( 100, 100, 100 )
		love.graphics.rectangle( "fill", 0, 0, 200, 30 )
		love.graphics.setColor( 50, 250, 50 )
		love.graphics.rectangle( "fill", 0, 0, 200 * (self.health / self.maxHealth), 30 )
	end, "charge")
	
	gui:addDynamicElement(0, Vector(0,0), function()
		love.graphics.setColor( 100, 100, 100 )
		love.graphics.rectangle( "fill", 0, 40, 200, 30 )
		love.graphics.setColor( 250, 50, 50 )
		love.graphics.rectangle( "fill", 0, 40, 200 * (self.charge / self.maxCharge), 30 )
	end, "charge")
	
	-- Create particle systems
	
	local system = love.graphics.newParticleSystem( resource.getImage(FOLDER.ASSETS.."fire.png"), 160 )
	system:setOffset( 0, 0 )
	system:setBufferSize( 2000 )
	system:setEmissionRate( 300 )
	system:setEmitterLifetime( -1 )
	system:setParticleLifetime( 1, 1 )
	system:setColors( 255, 100, 0, 50, 255, 255, 0, 100 )
	system:setSizes( 0.3, 1.8, 0.3 )
	system:setSpeed( 200, 700  )
	system:setDirection( math.rad(0) )
	system:setSpread( math.rad(3) )
	system:setRotation( math.rad(0), math.rad(0) )
	system:setSpin( math.rad(0.5), math.rad(1), 1 )
	system:setRadialAcceleration( 0 )
	system:setTangentialAcceleration( 0 )
	system:stop()
	
	self._psystem_boost = system
	
	system = love.graphics.newParticleSystem( resource.getImage(FOLDER.ASSETS.."spark.png"), 130 )
	system:setOffset( 0, 0 )
	system:setBufferSize( 1000 )
	system:setEmissionRate( 0 )
	system:setEmitterLifetime( -1 )
	system:setParticleLifetime( 1 )
	system:setColors( 255, 255, 130, 255, 255, 255, 170, 30 )
	system:setSizes( 0.05, 0.15, 0.05 )
	system:setSpeed( 100, 500  )
	system:setDirection( math.rad(0) )
	system:setSpread( math.rad(170) )
	system:setLinearAcceleration( 0, 670, 0, 930 )
	system:setRotation( math.rad(0), math.rad(0) )
	system:setSpin( math.rad(0.5), math.rad(1), 1 )
	system:setRadialAcceleration( 0 )
	system:setTangentialAcceleration( 0 )
	system:stop()
	
	self._psystem_sparks = system

	system = love.graphics.newParticleSystem( resource.getImage(FOLDER.ASSETS.."smoke.png"), 20 )
	system:setOffset( 0, 0 )
	system:setBufferSize( 1000 )
	system:setEmissionRate( 0 )
	system:setEmitterLifetime( -1 )
	system:setParticleLifetime( 5 )
	system:setColors( 45, 45, 45, 180, 95, 95, 95, 3 )
	system:setSizes( 0.5, 3, 1 )
	system:setSpeed( 30, 80  )
	system:setDirection( math.rad(230) )
	system:setSpread( math.rad(60) )
	system:setLinearAcceleration( 0, 0, 0, 0 )
	system:setRotation( math.rad(0.2), math.rad(0.8) )
	system:setSpin( math.rad(0.5), math.rad(2), 1 )
	system:setRadialAcceleration( 0 )
	system:setTangentialAcceleration( 0 )
	system:start()
	
	self._psystem_smoke = system
	
end

function Motorcycle:initializeBody( world )
	
	self._body = love.physics.newBody(world, 0, 0, "dynamic")
	self._body:setMass(30)
	self._body:setGravityScale( 0.5 )
	
	self._shape = love.physics.newPolygonShape(-20, 10, 50, 10, 80, -20, 45, -28, -45, -20)
	self._fixture = love.physics.newFixture(self._body, self._shape)
	self._fixture:setUserData(self)
	
	self._wheelbody = love.physics.newBody(world, wheel_x, wheel_y, "dynamic")
	self._wheelbody:setMass(10)
	
	self._wheelshape = love.physics.newCircleShape( 30 )
	self._wheelfixture = love.physics.newFixture(self._wheelbody, self._wheelshape)
	self._wheelfixture:setFriction( 20 )
	--self._wheelfixture:setUserData(self)
	
	self._joint = love.physics.newRevoluteJoint( self._body, self._wheelbody, wheel_x, wheel_y, false )

end

function Motorcycle:reset()
	
	self._body:setLinearVelocity( 0, 0 )
	self._body:setAngularVelocity( 0 )
	self._body:setAngle( 0 )
	
	self._wheelbody:setLinearVelocity( 0, 0 )
	self._wheelbody:setAngularVelocity( 10 )
	
end

function Motorcycle:setPos( x, y )

	mixin.PhysicsActor.setPos( self, x, y )
	self._wheelbody:setPosition( x + wheel_x, y + wheel_y )
	
end

function Motorcycle:update( dt )
	
	self._wheelbody:applyTorque( wheelTorque * dt )
	
	if (input:keyIsDown("left")) then
		self._body:applyAngularImpulse( -1 * controlAngularImpulse * dt )
	end
	
	if (input:keyIsDown("right")) then
		self._body:applyAngularImpulse( controlAngularImpulse * dt )
	end
	
	local body_ang = self._body:getAngle()
	local bx, by = self._body:getPosition()
		
	if (input:keyIsDown(" ") and self.charge > 0) then
	
		-- Boost!
		local vec = angle.forward( body_ang - math.pi / 8 ) * (boostImpulse * dt)
		self._body:applyLinearImpulse( vec.x, vec.y )
		
		self.charge = math.max(0, self.charge - chargeDrainPSec * dt)
		
		self.chargeRegenStart = engine.currentTime() + chargeRecoveryDelay
		
		local ppos = Vector(-30, -10):rotate(body_ang)
		self._psystem_boost:setDirection( self._body:getAngle() + math.pi )
		self._psystem_boost:setPosition( bx + ppos.x, by + ppos.y )
		self._psystem_boost:start()
		
	else
		
		self._psystem_boost:pause()
		
		if (self.chargeRegenStart < engine.currentTime()) then
		
			-- Recharge
			self.charge = math.min(self.maxCharge, self.charge + chargeRegenPSec * dt)
		end
		
	end
	
	if (self._lastGroundContact < engine.currentTime() - 0.1) then
		
		self._psystem_sparks:pause()
		
	end
	
	local spos = Vector(20, 17):rotate(body_ang)
	self._psystem_smoke:setPosition( bx + spos.x, by + spos.y )
	
	self._psystem_boost:update(dt)
	self._psystem_sparks:update(dt)
	self._psystem_smoke:update(dt)
	
end

function Motorcycle:draw()
	
	local px, py = self:getPos()
	local wx, wy = self._wheelbody:getPosition()
	
	love.graphics.draw(self._psystem_boost, 0, 0)
	
	self._img_wheel:draw(wx, wy, self._wheelbody:getAngle())
	
	love.graphics.push()
	
	love.graphics.translate(px, py)
	love.graphics.rotate(self._body:getAngle())
	
	self._img_engine:draw(54 + math.random() * 2,  41+math.random() * 2)
	self._img_frame:draw(0, 0)
	self._img_suspension:draw(10, 45)
	
	love.graphics.pop()
	
	love.graphics.draw(self._psystem_smoke, 0, 0)
	love.graphics.draw(self._psystem_sparks, 0, 0)
	
	--love.graphics.circle("line", wx, wy, self._wheelshape:getRadius(), 32)
	--love.graphics.line(self._body:getWorldPoints(self._shape:getPoints()))
	
end

function Motorcycle:postSolveWith( other, contact, selfIsFirst )
	
	--print("Resolving collision with "..tostring(other))
	
	if (instanceOf( Wall, other )) then
		
		local nx, ny = contact:getNormal()
		local p1x, p1y, p2x, p2y = contact:getPositions()
		
		if (selfIsFirst) then nx, ny = nx * -1, ny * -1 end
		
		self._psystem_sparks:setDirection( Vector(nx, ny):angle() )
		self._psystem_sparks:setPosition( p1x, p1y )
		self._psystem_sparks:start()
		
		-- determine how many sparks to show
		local nsparks = math.floor(Vector(self._body:getLinearVelocity()):length() / 50)
		if (nsparks > 0) then
			self._psystem_sparks:emit( nsparks )
			self.health = math.max(0, self.health - (nsparks / 10))
			self._psystem_smoke:setEmissionRate( math.floor(math.max(0, (self.maxHealth * 2/3) - self.health) / 30) )
		end
		
		self._lastGroundContact = engine.currentTime()
		
	end
	
end
