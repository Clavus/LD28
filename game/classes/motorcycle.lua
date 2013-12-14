
Motorcycle = class("Motorcycle", Entity)
Motorcycle:include(mixin.PhysicsActor)
Motorcycle:include(mixin.CollisionResolver)

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
	
	print("Created motorcycle")
	
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
	
	local av = Vector(-5, 52):getNormal()
	
	self._joint = love.physics.newRevoluteJoint( self._body, self._wheelbody, wx, wy, false )
	--self._joint1 = love.physics.newDistanceJoint( self._body, self._wheelbody, 0, 0, 0, 0, false )
	--self._joint2 = love.physics.newPrismaticJoint( self._body, self._wheelbody, 0, 0, av.x, av.y, false )
	--self._joint2 = love.physics.newWeldJoint( self._body, self._wheelbody, 0, 0, false )
	
end

function Motorcycle:update( dt )
	
	self._wheelbody:applyTorque( 1000000 * dt )
	
	if (input:keyIsDown("left")) then
		self._body:applyAngularImpulse( -10000 * dt )
	end
	
	if (input:keyIsDown("right")) then
		self._body:applyAngularImpulse( 10000 * dt )
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
