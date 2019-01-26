Director = require('director')

function love.load()
  Director.initialize()
end

function love.keypressed(key)
  if key == 'p' then
    Director.pause()
  elseif key == 'return' then
    Director.startJourney()
  elseif key == 'escape' then
    Director.leaveJourney()
  end
end

