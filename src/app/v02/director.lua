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
local intro = require 'scenes/intro'

local audio = require('audio')

function playFX(name)
  audio.playFX(name)
end

local dayCount

function start(dc, replace)
  audio.dayEnter(dc, replace)
  dayCount = dc
  Gamestate.switch(day, dayCount)
end

return {
  initialize = function()
    love.window.setMode(1280, 720)
    --love.window.setMode(1920, 1080)
    --love.window.setFullscreen(true)

    Gamestate.registerEvents()
    --audio.menuEnter()
    --Gamestate.switch(menu)
    Gamestate.switch(game)
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
      audio.introEnter()
      Gamestate.push(intro)
    elseif Gamestate.current() == intro then
      Director.enterNextDay()
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
    if Gamestate.current() == intro then
      audio.introLeave()
      start(1)
    elseif Gamestate.current() == game then
      audio.gameLeave()
      start(dayCount + 1)
    end
  end
}
