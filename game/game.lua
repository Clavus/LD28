
function game.load()
	
	local ldata = TiledLevelData(FOLDER.ASSETS.."level1")
	ldata.physics.pixels_per_meter = 100
	
	gui = GUI()
	level = Level(ldata, true)
	level:setCollisionCallbacks(game.collisionBeginContact, game.collisionEndContact, game.collisionPreSolve, game.collisionPostSolve)

	if (player) then
		level:getCamera():track( player, love.graphics.getWidth() / 5, -(love.graphics.getHeight() / 5) )
	end
	
	world = level:getPhysicsWorld()
	world:setGravity(0, 300)
	
	print("Game initialized")
	
end

function game.update( dt )

	gui:update( dt )
	level:update( dt )
	
	if (input:keyIsPressed("r")) then love.load() return end
	if (input:keyIsPressed("escape")) then love.event.quit() return end
	
end

function game.draw()
	
	--[[love.graphics.setColor(255,0,0,255)
	love.graphics.line(0,0,100,0)
	love.graphics.line(0,0,0,100)]]--
	love.graphics.setColor(255,255,255,255)
	level:draw( dt )
	gui:draw()
	
end

-- is called by map trigger entities
function game.handleTrigger( other, contact, trigger_type, ...)
	
end

-- called upon map load, handle Tiled objects
function game.createLevelEntity( level, entData )
	
	local ent
	if entData.type == "Wall" or entData.type == "Trigger" then
	
		ent = level:createEntity(entData.type, level:getPhysicsWorld(), entData.properties)
		if entData.w == nil then
			ent:buildFromPolygon(entData.polygon)
		else
			ent:buildFromSquare(entData.w,entData.h)
		end
		
		ent:setPos(entData.x, entData.y)
		
	elseif entData.type == "PlayerStart" then
		
		ent = level:createEntity("Motorcycle", level:getPhysicsWorld())
		ent:setPos(entData.x, entData.y)
		
		player = ent
		
		ent = level:createEntity("LostWheel", level:getPhysicsWorld())
		ent:setPos(entData.x - 200, entData.y - 200)
		
	end
	
end

function game.collisionBeginContact(a, b, contact)
	
	--print("begin contact "..tostring(a:getUserData()).." -> "..tostring(a:getUserData()))
	local ao, bo = a:getUserData(), b:getUserData()
	
	if (not ao or not bo) then return end
	
	--print("coll "..tostring(ao).." - "..tostring(bo))
	--print("ao: "..tostring(ao.class)..", incl: "..tostring(includes(mixin.CollisionResolver, ao.class)))
	--print("bo: "..tostring(bo.class)..", incl: "..tostring(includes(mixin.CollisionResolver, bo.class)))
	
	if (ao and includes(mixin.CollisionResolver, ao.class)) then
		ao:beginContactWith(bo, contact, true)
	end

	if (bo and includes(mixin.CollisionResolver, bo.class)) then
		bo:beginContactWith(ao, contact, false)
	end
	
end

function game.collisionEndContact(a, b, contact)

	local ao, bo = a:getUserData(), b:getUserData()
	
	if (not ao or not bo) then return end
	
	if (ao and includes(mixin.CollisionResolver, ao.class)) then
		ao:endContactWith(bo, contact, true)
	end

	if (bo and includes(mixin.CollisionResolver, bo.class)) then
		bo:endContactWith(ao, contact, false)
	end
	
end

function game.collisionPreSolve(a, b, contact)

	local ao, bo = a:getUserData(), b:getUserData()
	
	if (not ao or not bo) then return end
	
	if (ao and includes(mixin.CollisionResolver, ao.class)) then
		ao:preSolveWith(bo, contact, true)
	end

	if (bo and includes(mixin.CollisionResolver, bo.class)) then
		bo:preSolveWith(ao, contact, false)
	end
	
end

function game.collisionPostSolve(a, b, contact)

	local ao, bo = a:getUserData(), b:getUserData()
	
	if (not ao or not bo) then return end
	
	if (ao and includes(mixin.CollisionResolver, ao.class)) then
		ao:postSolveWith(bo, contact, true)
	end

	if (bo and includes(mixin.CollisionResolver, bo.class)) then
		bo:postSolveWith(ao, contact, false)
	end
	
end
