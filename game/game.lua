
function game.load()
	
	level = Level(LevelData(), false)
	gui = GUI()

	print("Game initialized")
	
end

function game.update( dt )
	
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
