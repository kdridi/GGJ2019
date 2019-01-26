local scene = newScene()
local suit = require('../vendor/suit')

function scene:enter(from)
  self.from = from -- record previous state
end

function scene:update(dt)
  if true then
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()
    local bw, bh = w, 60
    
    setFontSize(96)
    suit.Label("Pause", 0, 2 * (h - bh) / 4, w, bh)
  end
end

function scene:draw()
  suit.draw()
end

return scene