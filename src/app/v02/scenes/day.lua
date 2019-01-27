local scene = newScene()
local suit = require('../vendor/suit')
local context = {}

function scene:enter(previous, dayCount)
  context.dayCount = dayCount
  context.time = 0
end

function scene:update(dt)
  if true then
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()
    local bw, bh = w, 60

    setFontSize(96)
    suit.Label(string.format("Day %02d", context.dayCount), 0, 2 * (h - bh) / 4, w, bh)
  end

  context.time = context.time + dt

  if context.time > 0 then
    Director.enterGame()
  end
end

function scene:draw()
  suit.draw()
end

return scene
