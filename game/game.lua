
function game.load()
	
	local ldata = TiledLevelData(FOLDER.ASSETS.."level1")
	ldata.physics.pixels_per_meter = 100
	
	gui = GUI()
	level = Level(ldata, true)
	level:setCollisionCallbacks(game.collisionBeginContact, game.collisionEndContact, game.collisionPreSolve, game.collisionPostSolve)
	
	timer.simple( 3, function()
		level:getCamera():track( player, love.graphics.getWidth() / 5, -(love.graphics.getHeight() / 5) )
	end)
	
	game.last_checkpoint = nil
	
	world = level:getPhysicsWorld()
	world:setGravity(0, 300)
	
	print("Game initialized")
	
end

function game.update( dt )

	if (input:keyIsPressed("r") and game.last_checkpoint ~= nil) then
		local cx, cy = game.last_checkpoint:getPos()
		player:setPos(cx+32, cy+64)
		player:reset()
	end
	
	if (input:keyIsPressed("escape")) then love.event.quit() return end
	
	gui:update( dt )
	level:update( dt )
	
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
function game.handleTrigger( trigger, other, contact, trigger_type, ...)
	
	if (other == player and trigger_type == "checkpoint") then
		game.last_checkpoint = trigger
	end
	
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
	
	elseif entData.type == "Checkpoint" then
	
		ent = level:createEntity("Trigger", level:getPhysicsWorld(), { type = "checkpoint" })
		if entData.w == nil then
			ent:buildFromPolygon(entData.polygon)
		else
			ent:buildFromSquare(entData.w,entData.h)
		end
		
		ent:setPos(entData.x, entData.y)
		
	elseif entData.type == "PlayerStart" then
		
		ent = level:createEntity("Motorcycle", level:getPhysicsWorld())
		ent:setPos(entData.x - 200, entData.y)
		
		player = ent
		
		ent = level:createEntity("LostWheel", level:getPhysicsWorld())
		ent:setPos(entData.x - 100, entData.y - 100)
		
	elseif entData.type == "CameraStart" then
		
		local camera = level:getCamera()
		camera:moveTo( entData.x, entData.y, 0 )
		print("Setting camera pos")
		
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
