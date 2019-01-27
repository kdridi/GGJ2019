Director = require('director')

function love.load()
  math.randomseed(os.time())
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
  elseif isDebug() == true and key == '1' then
    Director.leaveGame(true)
  elseif isDebug() == true and key == '2' then
    Director.leaveGame(false)
  end
end

