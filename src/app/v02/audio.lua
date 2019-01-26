local fx_pig_01 = love.audio.newSource("asset/sounds/fx_pig_01.wav", "static")
fx_pig_01:setLooping(false)
fx_pig_01:setPitch(0.5)

local fx_pig_02 = love.audio.newSource("asset/sounds/fx_pig_02.wav", "static")
fx_pig_02:setLooping(false)
fx_pig_02:setPitch(1.0)

local fx_pig_03 = love.audio.newSource("asset/sounds/fx_pig_03.wav", "static")
fx_pig_03:setLooping(false)
fx_pig_03:setPitch(2.0)

local fx_punch_01 = love.audio.newSource("asset/sounds/fx_punch_01.wav", "static")
fx_punch_01:setLooping(false)
fx_punch_01:setPitch(2.0)

local background_ambiance_01 = love.audio.newSource("asset/sounds/background_ambiance_01.mp3", "static")
background_ambiance_01:setLooping(true)
background_ambiance_01:setPitch(1.0)

return {
  menuEnter = function()
    print('menuEnter')
  end,

  menuLeave = function()
    print('menuLeave')
  end,

  dayEnter = function(dayCount, replace)
    print('dayEnter')
    fx_pig_02:setVolume(1.0)
    fx_pig_02:setLooping(true)
    fx_pig_02:play()
  end,

  dayLeave = function()
    fx_pig_02:stop()
    print('dayLeave')
  end,
  
  gameEnter = function()
    print('gameEnter')
    fx_pig_01:setVolume(1.0)
    fx_pig_01:setLooping(true)
    fx_pig_01:play()
    background_ambiance_01:setVolume(1.0)
    background_ambiance_01:setLooping(true)
    background_ambiance_01:play()
  end,
  
  gameLeave = function()
    background_ambiance_01:stop()
    fx_pig_01:stop()
    print('gameLeave')
  end,
  
  pauseEnter = function()
    print('pauseEnter')
    fx_pig_01:setVolume(0.2)
    background_ambiance_01:setVolume(0.2)
  end,
  
  pauseLeave = function()
    background_ambiance_01:setVolume(1.0)
    fx_pig_01:setVolume(1.0)
    print('pauseLeave')
  end,
  
  playFX = function(name)
    if name == 'punch' then
      fx_punch_01:play()
      fx_pig_03:setPitch(1 + love.math.random())
      fx_pig_03:play()
    end
  end,
}