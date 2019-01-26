menu = Gamestate.new()

local suit = require('../vendor/suit')

function menu:update(dt)
  -- Put a button on the screen. If hit, show a message.
  if true then
    local bw, bh, w, h = 300, 60, love.graphics.getWidth(), love.graphics.getHeight()
    if suit.Button("Play!", (w - bw) / 2, 3 * (h - bh) / 4, bw, bh).hit then
      Gamestate.push(game)
    end
  end
end

function menu:draw()
  if false then
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()
    love.graphics.setColor(0,0,0, 100)
    love.graphics.rectangle('fill', 0,0, w, h)
    love.graphics.setColor(255,255,255)
    love.graphics.printf('House Of Pigs', 0, 1*h/4, w, 'center')
    love.graphics.printf('[PRESS ENTER]', 0, 3*h/4, w, 'center')
  end

  suit.draw()
end

return menu
