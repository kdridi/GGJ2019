local scene = newScene()

local Timer = require('../vendor/hump/timer')

local context = {}
local background

function scene:enter(previous)
  context.slide = 1
  
  local slide = 2
  local iwait = function(wait, w)
    background = love.graphics.newImage("asset/cinematics/" .. string.format("cinematic_a%02d.jpg", slide))
    slide = slide + 1
    wait(w * 4.0)
    if slide == 19 then
      Director.enterNextDay()
    end
  end
  
  Timer.script(function(wait)
    iwait(wait, 0.70)
    iwait(wait, 0.40)
    iwait(wait, 0.70)
    playFX('kiss')
    iwait(wait, 0.40 - 0.01)
    iwait(wait, 0.01)
    iwait(wait, 0.70)
    iwait(wait, 0.70)
    iwait(wait, 0.30)
    iwait(wait, 0.10)
    iwait(wait, 0.10)
    iwait(wait, 0.10)
    iwait(wait, 0.10)
    iwait(wait, 0.10)
    iwait(wait, 0.70)
    iwait(wait, 0.70)
    iwait(wait, 0.70)
    iwait(wait, 0.70)
  end)
end

function scene:update(dt)  
  Timer.update(dt)
end

function scene:draw()
  if true then
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()
    local bw, bh = background:getWidth(), background:getHeight()
    love.graphics.draw(background, (w - bw) / 2, (h - bh) / 2)
  end
end

return scene
