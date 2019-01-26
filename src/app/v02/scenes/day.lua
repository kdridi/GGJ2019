day = Gamestate.new()

local time
local dayCount
local font

function day:enter(previous, dc)
  dayCount = dc
  time = 0
  font = love.graphics.newFont("Quite Magical - TTF.ttf", 154)
end

function day:update(dt)
  time = time + dt
  
  if time > 1 then
    Gamestate.switch(game, dayCount)
  end
end

function day:draw()
  local w, h = love.graphics.getWidth(), love.graphics.getHeight()
  
  love.graphics.setColor(0,0,0,1)
  love.graphics.rectangle('fill', 0,0, w, h)
  love.graphics.setColor(1,1,1,1)
  love.graphics.setFont(font)
  love.graphics.printf(string.format("Day %02d", dayCount), 0, 2*h/4, w, 'center')
end

return day
