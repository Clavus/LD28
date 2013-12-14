
Motorcycle = class("Motorcycle", Entity)
Motorcycle:include(mixin.PhysicsActor)
Motorcycle:include(mixin.CollisionResolver)

local wheelTorque = 1000000
local controlAngularImpulse = 13000
local boostImpulse = 400
local chargeDrainPSec = 66
local chargeRegenPSec = 20
local chargeRecoveryDelay = 2

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
	
	self.maxCharge = 100
	self.charge = 100
	self.chargeRegenStart = 0
	
	gui:addDynamicElement(0, Vector(0,0), function()
		love.graphics.setColor( 100, 100, 100 )
		love.graphics.rectangle( "fill", 0, 0, 200, 50 )
		love.graphics.setColor( 250, 50, 50 )
		love.graphics.rectangle( "fill", 0, 0, 200 * (self.charge / self.maxCharge), 50 )
	end, "charge")
	
	
end

function Motorcycle:initializeBody( world )
	
	local wx, wy = -38, 38
	
	self._body = love.physics.newBody(world, 0, 0, "dynamic")
	self._body:setMass(30)
	
	self._shape = love.physics.newPolygonShape(-20, 10, 50, 10, 80, -20, 45, -28, -45, -20)
	self._fixture = love.physics.newFixture(self._body, self._shape)
	self._fixture:setUserData(self)
	
	self._wheelbody = love.physics.newBody(world, wx, wy, "dynamic")
	self._wheelbody:setMass(10)
	
	self._wheelshape = love.physics.newCircleShape( 30 )
	self._wheelfixture = love.physics.newFixture(self._wheelbody, self._wheelshape)
	self._wheelfixture:setFriction( 20 )
	--self._wheelfixture:setUserData(self)
	
	self._joint = love.physics.newRevoluteJoint( self._body, self._wheelbody, wx, wy, false )

end

function Motorcycle:update( dt )
	
	self._wheelbody:applyTorque( wheelTorque * dt )
	
	if (input:keyIsDown("left")) then
		self._body:applyAngularImpulse( -1 * controlAngularImpulse * dt )
	end
	
	if (input:keyIsDown("right")) then
		self._body:applyAngularImpulse( controlAngularImpulse * dt )
	end
	
	if (input:keyIsDown(" ") and self.charge > 0) then
		local vec = angle.forward( self._body:getAngle() ) * (boostImpulse * dt)
		self._body:applyLinearImpulse( vec.x, vec.y )
		
		self.charge = math.max(0, self.charge - chargeDrainPSec * dt)
		
		self.chargeRegenStart = engine.currentTime() + chargeRecoveryDelay
		
	elseif (self.chargeRegenStart < engine.currentTime()) then
		
		self.charge = math.min(self.maxCharge, self.charge + chargeRegenPSec * dt)
		
	end	
	
	
end

function Motorcycle:draw()
	
	local px, py = self:getPos()
	local wx, wy = self._wheelbody:getPosition()
	
	self._img_wheel:draw(wx, wy, self._wheelbody:getAngle())
	
	love.graphics.push()
	
	love.graphics.translate(px, py)
	love.graphics.rotate(self._body:getAngle())
	
	self._img_engine:draw(54 + math.random() * 2,  41+math.random() * 2)
	self._img_frame:draw(0, 0)
	self._img_suspension:draw(10, 45)
	
	love.graphics.pop()
	
	--love.graphics.circle("line", wx, wy, self._wheelshape:getRadius(), 32)
	--love.graphics.line(self._body:getWorldPoints(self._shape:getPoints()))
	
	
end

function Motorcycle:resolveCollisionWith( other, contact )
	
	
	
end
