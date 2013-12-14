
function game.load()
	
	local ldata = TiledLevelData(FOLDER.ASSETS.."level1")
	ldata.physics.pixels_per_meter = 100
	
	gui = GUI()
	level = Level(ldata, true)
	
	--level:getCamera():setScale( 0.5, 0.5 )
	
	world = level:getPhysicsWorld()
	world:setGravity(0, 300)
	
	print("Game initialized")
	
end

function game.update( dt )
	
	if (player) then
		local px, py = player:getPos() 
		level:getCamera():setPos( px + love.graphics.getWidth() / 4, py )
	end
	
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
	--print("coll "..tostring(ao).." - "..tostring(bo))
	--print("ao: "..tostring(ao.class)..", incl: "..tostring(includes(CollisionResolver, ao.class)))
	
	if (includes(CollisionResolver, ao.class)) then
		ao:resolveCollisionWith(bo, contact)
	end

	if (includes(CollisionResolver, bo.class)) then
		bo:resolveCollisionWith(ao, contact)
	end
	
	--if (instanceOf(, ao) and instanceOf(RPGPlayer, bo)) then
	--	ao:attackPlayer(bo)
	--elseif (instanceOf(Zombie, bo) and instanceOf(RPGPlayer, ao)) then
	--	bo:attackPlayer(ao)
	--end
	
end

function game.collisionEndContact(a, b, contact)

end

function game.collisionPreSolve(a, b, contact)

end

function game.collisionPostSolve(a, b, contact)

end
