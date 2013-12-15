
function game.load()
	
	local ldata = TiledLevelData(FOLDER.ASSETS.."level1")
	ldata.physics.pixels_per_meter = 100
	
	gui = GUI()
	level = Level(ldata, true)
	level:setCollisionCallbacks(game.collisionBeginContact, game.collisionEndContact, game.collisionPreSolve, game.collisionPostSolve)
	
	level:getCamera():setClampArea( 0, 0,  ldata.level_width * ldata.level_tilewidth, ldata.level_height * ldata.level_tileheight)
	
	local start_explo = resource.getSound( FOLDER.ASSETS.."start_explosion.wav", "static" )
	
	game.last_checkpoint = nil
	
	game.font_title = love.graphics.newFont( FOLDER.ASSETS.."loaded.ttf", 108)
	game.font_score = love.graphics.newFont( FOLDER.ASSETS.."loaded.ttf", 32)
	game.score = 0
	game.nextScoreX = 100000 -- temp value
	
	game.font_text = love.graphics.newFont( FOLDER.ASSETS.."loaded.ttf", 24)
	game.font_stext = love.graphics.newFont( FOLDER.ASSETS.."loaded.ttf", 12)
	
	game.background_img = resource.getImage( FOLDER.ASSETS.."background.png" )
	
	world = level:getPhysicsWorld()
	world:setGravity(0, 300)
	
	game.sound_explosion = resource.getSound( FOLDER.ASSETS.."explosion.wav", "static" )
	game.sound_trick = resource.getSound( FOLDER.ASSETS.."trickbonus.wav", "static" )
	
	gui:addDynamicElement(0, Vector(0,0), function()
		love.graphics.setFont( game.font_score )
		love.graphics.setColor( 255, 255, 255, 255 )
		love.graphics.print( tostring(game.score), 10, 50 )
	end, "score")
	
	gui:addDynamicElement(0, Vector(0,0), function()
		love.graphics.setFont( game.font_stext )
		love.graphics.setColor( 255, 255, 255, 255 )
		love.graphics.printf( "Press r to retry", 0, 0, love.graphics.getWidth(), "right" )
	end, "r_to_restart")
	
	-- intro sequence
	game.paused = false
	game.level_started = false
	game.level_ended = false
	
	timer.simple( 0.5, function()
		start_explo:play()
	end)
	
	timer.simple( 2.5, function()
		game.paused = true
		
		gui:addDynamicElement(0, Vector(0,0), function()
			local win_w, win_h = love.graphics.getWidth(), love.graphics.getHeight()
		
			love.graphics.setColor( 0, 0, 0, 150 )
			love.graphics.rectangle( "fill", 0, win_h / 2 - 100, win_w, 200 )
		
			love.graphics.setFont( game.font_title )
			love.graphics.setColor( 255, 255, 255, 255 )
			love.graphics.printf( "WHEELIE", 0, win_h / 2 - 75, 1000, "center" )
			
			love.graphics.setFont( game.font_text )
			love.graphics.printf( "Left and right arrow keys to balance. Spacebar to boost.", 0, win_h / 2 + 20, 1000, "center" )
			
			love.graphics.printf( "Press space to start", 0, win_h / 2 + 60, 1000, "center" )
		end, "game_start")
		
		level:getCamera():track( player, love.graphics.getWidth() / 5, 0 )
		
		player:balance()
		
		local px, py = player:getPos()
		game.nextScoreX =  px + 10
	end)
	
	print("Game initialized")
	
end

function game.update( dt )

	if (input:keyIsPressed("r") and game.level_started and not game.level_ended) then
		game.resetPlayer()
	end
	
	if (input:keyIsPressed("escape")) then love.event.quit() return end
	
	if (input:keyIsPressed(" ") and game.paused) then
		
		if not game.level_started then
			game.level_started = true
			gui:removeElement("game_start")
		end
		
		if game.level_ended then
		
			game.level_ended = false
			gui:removeElement("game_end")
			
			love.event.quit()
			
			-- TODO: next level?
		end
		
		input:clear()
		game.paused = false
		
	end
	
	gui:update( dt )
	
	if not game.paused then
		level:update( dt )
	end
	
	-- update score as player progresses
	local px, py = player:getPos()
	
	while (px > game.nextScoreX) do
		game.addScore( 1 )
		game.nextScoreX = game.nextScoreX + 10
	end
	
end

function game.draw()
	
	--[[love.graphics.setColor(255,0,0,255)
	love.graphics.line(0,0,100,0)
	love.graphics.line(0,0,0,100)]]--
	love.graphics.setColor(255,255,255,255)
	
	local cx, cy = level:getCamera():getPos()
	love.graphics.setDefaultFilter( "nearest", "nearest" )
	love.graphics.draw( game.background_img, -cx * 0.1, -cy * 0.05, 0, 2.5, 2.5 )
	
	level:draw( dt )
	gui:draw()
	
end

-- is called by map trigger entities
function game.handleTrigger( trigger, other, contact, trigger_type, ...)
	
	if (other == player) then
		if (trigger_type == "checkpoint") then
		
			game.last_checkpoint = trigger
			return true
			
		elseif (trigger_type == "reset") then
		
			timer.simple(0, function() -- can't reset player in beginContact callback of trigger, so we do it next frame
				game.playerExplode()
			end)
			return true
			
		elseif (trigger_type == "finish") then
			
			player:turnEngineOff()
			player.health = 10000
			
			timer.simple(1, function()
				
				game.level_ended = true
				game.paused = true
				
				gui:addDynamicElement(0, Vector(0,0), function()
					local win_w, win_h = love.graphics.getWidth(), love.graphics.getHeight()
				
					love.graphics.setColor( 0, 0, 0, 150 )
					love.graphics.rectangle( "fill", 0, win_h / 2 - 100, win_w, 200 )
				
					love.graphics.setFont( game.font_title )
					love.graphics.setColor( 255, 255, 255, 255 )
					love.graphics.printf( "FINISH!", 0, win_h / 2 - 75, 1000, "center" )
					
					love.graphics.setFont( game.font_text )
					love.graphics.printf( "You completed the course with "..game.score.." points!", 0, win_h / 2 + 20, 1000, "center" )
					
					love.graphics.printf( "Press space to exit", 0, win_h / 2 + 60, 1000, "center" )
				end, "game_end")
				
			end)
			
			return true
			
		end
		
	end
	
end

function game.addScore( score )
	
	if (game.level_ended) then return end
	
	game.score = game.score + math.floor(score)
	
end

function game.trickCompleted( scoreToAdd, textToDisplay )
	
	if (game.level_ended) then return end
	
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
	
	for k, v in pairs(level:getEntitiesByClass(Coin)) do
		
		v:reset()
		
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
	
	elseif entData.type == "Checkpoint" or entData.type == "Reset" or entData.type == "Finish" then
	
		ent = level:createEntity("Trigger", level:getPhysicsWorld(), { type = string.lower(entData.type) })
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
		ent:setPos(entData.x + entData.w / 2, entData.y + entData.h / 2)
		
	elseif entData.type == "Pickup" then
		
		ent = level:createEntity("Coin", level:getPhysicsWorld(), entData.properties)
		ent:setPos(entData.x, entData.y)
		
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
