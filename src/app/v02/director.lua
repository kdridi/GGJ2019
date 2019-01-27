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
local failure = require 'scenes/failure'
local success = require 'scenes/success'

local audio = require('audio')

function playFX(name)
  audio.playFX(name)
end

local dayCount
local debug

function isDebug()
  return debug
end

function start(dc, replace)
  audio.dayEnter(dc, replace)
  dayCount = dc
  Gamestate.switch(day, dayCount)
end

return {
  initialize = function(d)
    debug = d
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
    elseif Gamestate.current() == success then
      audio.successLeave()
      audio.menuEnter()
      Gamestate.pop()
    elseif Gamestate.current() == failure then
      audio.failureLeave()
      audio.menuEnter()
      Gamestate.pop()
    end
  end,
  
  leaveGame = function(status)
    if Gamestate.current() == game then
      audio.gameLeave()
      if status == false then
        audio.failureEnter()
        Gamestate.switch(failure)
      elseif status == true then
        audio.successEnter()
        Gamestate.switch(success)
      end
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
      if dayCount == 7 then
        Director.leaveGame(true)
      else
        audio.gameLeave()
        start(dayCount + 1)
      end
    end
  end
}
