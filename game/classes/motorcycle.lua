
Motorcycle = class("Motorcycle", Entity)

function Motorcycle:initialize()
	
	Entity.initialize(self)
	
	self._img_frame = resource.getImage(FOLDER.ASSETS.."m_frame.png")
	self._img_wheel = resource.getImage(FOLDER.ASSETS.."m_wheel.png")
	self._img_engine = resource.getImage(FOLDER.ASSETS.."m_engine.png")
	self._img_suspension = resource.getImage(FOLDER.ASSETS.."m_suspension.png")
	
	print("Created motorcycle")
	
end

function Motorcycle:update( dt )


end

function Motorcycle:draw()
	
	love.graphics.draw(self._img_frame, 0, 0)
	love.graphics.draw(self._img_wheel, 0, 0)
	love.graphics.draw(self._img_engine, 0, 0)
	love.graphics.draw(self._img_suspension, 0, 0)
	
end