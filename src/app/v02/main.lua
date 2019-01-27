Director = require('director')

function love.load()
  if arg[#arg] == "-debug" then
    --require("mobdebug").start()
    Director.initialize(true)
  else
    Director.initialize(false)
  end
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

