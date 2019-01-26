menu = Gamestate.new()

function menu:draw()
  local w, h = love.graphics.getWidth(), love.graphics.getHeight()

  -- overlay with menu message
  love.graphics.setColor(0,0,0, 100)
  love.graphics.rectangle('fill', 0,0, w, h)
  love.graphics.setColor(255,255,255)
  love.graphics.printf('House Of Pigs', 0, 1*h/4, w, 'center')
  love.graphics.printf('[PRESS ENTER]', 0, 3*h/4, w, 'center')
end

return menu
