local scene = newScene()
local suit = require('../vendor/suit')

function scene:update(dt)
  if true then
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()
    local bw, bh = w, 60
    
    setFontSize(96)
    suit.Label("House Of Pigs", 0, 1 * (h - bh) / 4, w, bh)
  end
  
  if true then
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()
    local bw, bh = 300, 60
    
    setFontSize(36)
    if suit.Button("Play!", (w - bw) / 2, 3 * (h - bh) / 4, bw, bh).hit then
      Director.startJourney()
    end
  end
end

function scene:draw()
  suit.draw()
end

return scene
