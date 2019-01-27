local scene = newScene()
local suit = require('../vendor/suit')
local context = {}

local messages = {
  "Rentrez votre cochonaille à la maison avant que les loups s'en occupent...",
  "La nuit tombe vite, magnez vous !",
  "Le gros porc ? Il s'appelle Gaston !",
  "Le saviez-vous ? Le mot pause commence par la lettre P.",
  "Soyez un bon père ! Une bonne grosse semaine...",
}

function scene:enter(previous, dayCount)
  context.dayCount = dayCount
  context.time = 0
  context.slide = math.random(100 * #messages) % #messages + 1
end

function scene:update(dt)
  if true then
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()
    local bw, bh = w, 60

    setFontSize(96)
    suit.Label(string.format("Day %02d", context.dayCount), 0, 2 * (h - bh) / 4, w, bh)
    
    setFontSize(16)
    suit.Label(messages[context.slide], 0, 5 * (h - bh) / 6, w, bh)
  end

  context.time = context.time + dt

  local ttime = 2
  if isDebug() then
    ttime = 0
  end
  if context.time > ttime then
    Director.enterGame()
  end
end

function scene:draw()
  suit.draw()
end

return scene
