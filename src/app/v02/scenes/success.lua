local scene = newScene()
local suit = require('../vendor/suit')
local context = {}

function scene:enter(from)
  context.time = 0
end

function scene:update(dt)
  if true then
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()
    local bw, bh = w, 60

    setFontSize(96)
    suit.Label(string.format("You Win!", context.dayCount), 0, 2 * (h - bh) / 4, w, bh)
  end

  context.time = context.time + dt

  if context.time > 20 then
    Director.leaveJourney()
  end
end

function scene:draw()
  suit.draw()
end

return scene
