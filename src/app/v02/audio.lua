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

local background_ambiance_02 = love.audio.newSource("asset/sounds/background_ambiance_02.mp3", "static")
background_ambiance_02:setLooping(true)
background_ambiance_02:setPitch(1.0)

local background_ambiance_03 = love.audio.newSource("asset/sounds/background_ambiance_03.mp3", "static")
background_ambiance_03:setLooping(true)
background_ambiance_03:setPitch(1.0)

local background_ambiance_04 = love.audio.newSource("asset/sounds/background_ambiance_04.mp3", "static")
background_ambiance_04:setLooping(true)
background_ambiance_04:setPitch(1.0)

local background_music_01 = love.audio.newSource("asset/sounds/background_music_01.mp3", "static")
background_music_01:setLooping(true)
background_music_01:setPitch(1.0)

local background_music_02 = love.audio.newSource("asset/sounds/background_music_02.mp3", "static")
background_music_02:setLooping(true)
background_music_02:setPitch(1.0)

local background_music_03 = love.audio.newSource("asset/sounds/background_music_03.mp3", "static")
background_music_03:setLooping(true)
background_music_03:setPitch(1.0)

local fx_kiss_01 = love.audio.newSource("asset/sounds/fx_kiss_01.mp3", "static")
fx_kiss_01:setLooping(false)
fx_kiss_01:setPitch(1.0)

local fx_kiss_02 = love.audio.newSource("asset/sounds/fx_kiss_02.mp3", "static")
fx_kiss_02:setLooping(false)
fx_kiss_02:setPitch(1.0)

return {
  successEnter = function()
    print('successEnter')
    background_ambiance_03:play()
  end,
  
  successLeave = function()
    background_ambiance_03:stop()
    print('successLeave')
  end,
  
  failureEnter = function()
    print('failureEnter')
    background_ambiance_04:play()
  end,

  failureLeave = function()
    background_ambiance_04:stop()
    print('failureLeave')
  end,
  
  menuEnter = function()
    print('menuEnter')
  end,

  menuLeave = function()
    print('menuLeave')
  end,

  introEnter = function()
    print('introEnter')
    background_music_03:setVolume(0.5)
    background_music_03:setLooping(true)
    background_music_03:play()
  end,

  introLeave = function()
    background_music_03:stop()
    print('introLeave')
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
    background_ambiance_01:setVolume(4.0)
    background_ambiance_01:setLooping(true)
    background_ambiance_01:play()
    background_music_01:setVolume(0.5)
    background_music_01:setLooping(true)
    background_music_01:play()
  end,
  
  gameLeave = function()
    background_music_01:stop()
    background_ambiance_01:stop()
    fx_pig_01:stop()
    print('gameLeave')
  end,
  
  pauseEnter = function()
    print('pauseEnter')
    fx_pig_01:setVolume(0.2)
    background_ambiance_01:setVolume(4.0)
    background_music_01:setVolume(0.0)
  end,
  
  pauseLeave = function()
    background_music_01:setVolume(0.5)
    background_ambiance_01:setVolume(4.0)
    fx_pig_01:setVolume(1.0)
    print('pauseLeave')
  end,
  
  playFX = function(name)
    if name == 'punch' then
      fx_punch_01:play()
      fx_pig_03:setPitch(1 + love.math.random())
      fx_pig_03:play()
    elseif name == 'kiss' then
      fx_kiss_01:setPitch(1 + love.math.random())
      fx_kiss_01:play()
    end
  end,
}