Gamestate = require 'vendor/hump/gamestate'

pause = require 'scenes/pause'
menu = require 'scenes/menu'
game = require 'scenes/game'

function love.load()
  love.window.setMode(1280, 720)
  
  Gamestate.registerEvents()
  Gamestate.switch(menu)
end

function love.keypressed(key)
  if key == "escape" then
    love.event.push("quit")
  end

  if Gamestate.current() == game and Gamestate.current() ~= pause and key == 'p' then
    Gamestate.push(pause)
  end

  if Gamestate.current() == menu and key == 'return' then
    Gamestate.push(game)
  end

  if Gamestate.current() == game and key == 'q' then
    Gamestate.pop()
  end

  if Gamestate.current() == game and key == 'r' then
    Gamestate.pop()
    Gamestate.push(game)
  end
end

