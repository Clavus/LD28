
function game.load()
	
	local ldata = TiledLevelData(FOLDER.ASSETS.."level1")
	ldata.physics.pixels_per_meter = 100
	
	gui = GUI()
	level = Level(ldata, true)
	level:setCollisionCallbacks(game.collisionBeginContact, game.collisionEndContact, game.collisionPreSolve, game.collisionPostSolve)
	
	level:getCamera():setClampArea( 0, 0,  ldata.level_width * ldata.level_tilewidth, ldata.level_height * ldata.level_tileheight)
	
	local start_explo = resource.getSound( FOLDER.ASSETS.."start_explosion.wav", "static" )
	
	timer.simple( 0.5, function()
		start_explo:play()
	end)
	
	timer.simple( 3, function()
		level:getCamera():track( player, love.graphics.getWidth() / 5, 0 )
		
		local px, py = player:getPos()
		game.nextScoreX =  px + 10
	end)
	
	game.last_checkpoint = nil
	
	game.font_score = love.graphics.newFont( FOLDER.ASSETS.."loaded.ttf", 32)
	game.score = 0
	game.nextScoreX = nil
	
	game.font_text = love.graphics.newFont( FOLDER.ASSETS.."loaded.ttf", 24)
	game.font_stext = love.graphics.newFont( FOLDER.ASSETS.."loaded.ttf", 12)
	
	world = level:getPhysicsWorld()
	world:setGravity(0, 300)
	
	game.sound_explosion = resource.getSound( FOLDER.ASSETS.."explosion.wav", "static" )
	game.sound_trick = resource.getSound( FOLDER.ASSETS.."trickbonus.wav", "static" )
	
	gui:addDynamicElement(0, Vector(0,0), function()
		love.graphics.setFont( game.font_score )
		love.graphics.setColor( 255, 255, 255, 255 )
		love.graphics.print( tostring(game.score), 10, 80 )
	end, "score")
	
	print("Game initialized")
	
end

function game.update( dt )

	if (input:keyIsPressed("r")) then
		game.resetPlayer()
	end
	
	if (input:keyIsPressed("escape")) then love.event.quit() return end
	
	gui:update( dt )
	level:update( dt )
	
	-- update score as player progresses
	if (game.nextScoreX) then
		
		local px, py = player:getPos()
		
		while (px > game.nextScoreX) do
			game.addScore( 1 )
			game.nextScoreX = game.nextScoreX + 10
		end
		
	end
	
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
	
	if (other == player) then
		if (trigger_type == "checkpoint") then
			print("Reached checkpoint")
			game.last_checkpoint = trigger
			return true
		elseif (trigger_type == "reset") then
			timer.simple(0, function() -- can't reset player in beginContact callback of trigger, so we do it next frame
				game.resetPlayer()
			end)
			return true
		end
	end
	
end

function game.addScore( score )
	
	game.score = game.score + math.floor(score)
	
end

function game.trickCompleted( scoreToAdd, textToDisplay )
	
	game.sound_trick:play()
	game.addScore( scoreToAdd )
	
	local elId = "trick"..engine.currentTime()
	local trick = {
		text = textToDisplay, 
		small_text = "+"..scoreToAdd.." points"
		}
	
	gui:addDynamicElement( -10, { x = -(love.graphics.getWidth() / 4) - 150 + math.random()*300, y = (love.graphics.getHeight() / 2) - 150 + math.random()*300 }, function( pos )
			love.graphics.setColor(255, 255, 255, 255)
			love.graphics.setFont(game.font_text)
			love.graphics.printf( trick.text, pos.x, pos.y, 1000, "center" )
			love.graphics.setFont(game.font_stext)
			love.graphics.printf( trick.small_text, pos.x, pos.y + 24, 1000, "center" )
	end, elId)
	
	timer.simple( 3, function()
		gui:removeElement(elId)
	end)
	
end

function game.playerExplode()
	
	game.sound_explosion:play()
	game.resetPlayer()
	
end

function game.resetPlayer()
	
	if (game.last_checkpoint == nil) then return end
	
	local cx, cy = game.last_checkpoint:getPos()
	player:setPos(cx+32, cy+64)
	player:reset()
	
	game.score = 0
	game.nextScoreX =  cx + 32 + 10
		
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
	
	elseif entData.type == "Reset" then
	
		ent = level:createEntity("Trigger", level:getPhysicsWorld(), { type = "reset" })
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
		
	elseif entData.type == "Box" then
		
		ent = level:createEntity(entData.type, level:getPhysicsWorld(), entData.properties)
		ent:setPos(entData.x - entData.w / 2, entData.y - entData.h / 2)
		
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
		ao:beginContactWith(bo, contact, a, b, true)
	end

	if (bo and includes(mixin.CollisionResolver, bo.class)) then
		bo:beginContactWith(ao, contact, b, a, false)
	end
	
end

function game.collisionEndContact(a, b, contact)

	local ao, bo = a:getUserData(), b:getUserData()
	
	if (not ao or not bo) then return end
	
	if (ao and includes(mixin.CollisionResolver, ao.class)) then
		ao:endContactWith(bo, contact, a, b, true)
	end

	if (bo and includes(mixin.CollisionResolver, bo.class)) then
		bo:endContactWith(ao, contact, b, a, false)
	end
	
end

function game.collisionPreSolve(a, b, contact)

	local ao, bo = a:getUserData(), b:getUserData()
	
	if (not ao or not bo) then return end
	
	if (ao and includes(mixin.CollisionResolver, ao.class)) then
		ao:preSolveWith(bo, contact, a, b, true)
	end

	if (bo and includes(mixin.CollisionResolver, bo.class)) then
		bo:preSolveWith(ao, contact, b, a, false)
	end
	
end

function game.collisionPostSolve(a, b, contact)

	local ao, bo = a:getUserData(), b:getUserData()
	
	if (not ao or not bo) then return end
	
	if (ao and includes(mixin.CollisionResolver, ao.class)) then
		ao:postSolveWith(bo, contact, a, b, true)
	end

	if (bo and includes(mixin.CollisionResolver, bo.class)) then
		bo:postSolveWith(ao, contact, b, a, false)
	end
	
end
