local Gamestate = require 'vendor/hump/gamestate'

function newScene()
    return Gamestate.new()
end
  
function setFontSize(size)
  love.graphics.setFont(love.graphics.newFont("asset/fonts/gastoon.ttf", size))
end

local pause = require 'scenes/pause'
local menu = require 'scenes/menu'
local game = require 'scenes/game'
local day = require 'scenes/day'

local audio = require('audio')

function playFX(name)
  audio.playFX(name)
end

local dayCount

function start(dc, replace)
  audio.dayEnter(dc, replace)
  dayCount = dc
  if (replace) then
    Gamestate.switch(day, dayCount)
  else
    Gamestate.push(day, dayCount)
  end
end

return {
  initialize = function()
    love.window.setMode(1280, 720)
    --love.window.setFullscreen(true)
  
    Gamestate.registerEvents()
    audio.menuEnter()
    Gamestate.switch(menu)
  end,
  
  pause = function()
    if Gamestate.current() == game and Gamestate.current() ~= pause then
      audio.pauseEnter()
      Gamestate.push(pause)
    end
  end,

  startJourney = function()
    if Gamestate.current() == menu then
      audio.menuLeave()
      start(1, false)
    end
  end,

  leaveJourney = function()
    if Gamestate.current() == pause then
      audio.pauseLeave()
      Gamestate.pop()
    elseif Gamestate.current() == game then
      audio.gameLeave()
      audio.menuEnter()
      Gamestate.pop()
    elseif Gamestate.current() == menu then
      audio.menuLeave()
      love.event.push("quit")
    end
  end,
    
  enterGame = function()
    audio.dayLeave()
    audio.gameEnter()
    Gamestate.switch(game, dayCount)
  end,
  
  enterNextDay = function()
    audio.gameLeave()
    start(dayCount + 1, true)
  end
}