local scene = newScene()

map = {}

--sti = require "STI/sti"
loader = require "../loader"
data = require "../map"
Pig = require "../Pig"
Wolf = require "../Wolf"
Boar = require "../Boar"
Bonus = require "../Bonus"
Player = require "../Player"
Weed = require "../Weed"
inspect = require "../vendor/inspect"
Camera = require "../camera"
screen = require "../vendor/shack/shack"

local suit = require('../vendor/suit')

player = {}
world = {}
local map = {}
home = {}

local objStart = {}

local MAPW = 50
local MAPH = 40
local MAPS = 32

local amTL = 80
local pmTL = 50

local context = {}

function scene:init()
  screen:setDimensions(love.graphics.getWidth(), love.graphics.getHeight())

  math.randomseed(os.time())
  print("init")
  self.pig = 1
  self.isInit = false
  love.physics.setMeter(64)
  world = love.physics.newWorld(0, 0, true)
  world:setCallbacks(function(a, b, coll)
    if a:getUserData() and a:getUserData().type and
       b:getUserData() and b:getUserData().type then
      if a:getUserData().type == "Pig" and b:getUserData().type == "Home" then
        if a:getUserData().panic == true then
          a:getUserData():enter(1) end
      elseif b:getUserData().type == "Pig" and a:getUserData().type == "Home" then
        if b:getUserData().panic == true then
          b:getUserData():enter(1) end
      elseif a:getUserData().type == "Pomme" and b:getUserData().type == "Player" then
        b:getUserData():addPomme(1)
        Bonus.del(a:getUserData())
      elseif b:getUserData().type == "Pomme" and a:getUserData().type == "Player" then
        a:getUserData():addPomme(1)
        Bonus.del(b:getUserData())
      elseif a:getUserData().type == "Medecine" and b:getUserData().type == "Player" then
        b:getUserData():addMedecine(1)
        Bonus.del(a:getUserData())
      elseif b:getUserData().type == "Medecine" and a:getUserData().type == "Player" then
        a:getUserData():addMedecine(1)
        Bonus.del(b:getUserData())
      elseif a:getUserData().type == "Root" and b:getUserData().type == "Pig" then
        b:getUserData():setRoot(true)
        Bonus.del(a:getUserData())
      elseif b:getUserData().type == "Root" and a:getUserData().type == "Pig" then
        a:getUserData():setRoot(true)
        Bonus.del(b:getUserData())
      end
    end
  end, nil, nil, nil)
end

function scene:enter(previous, dayCount)
  context.dayCount = dayCount
  context.time = 0

  self.time = amTL + pmTL
  self.panic = false
  self.pig = self.pig + 2

  Player.del(player)
  Wolf.clear()
  Boar.clear()
  Pig.clear()
  if self.isInit == false then
    Player.del(player)
    Weed.clear()
    Bonus.clear()
    Pig.clear()
    Wolf.clear()

    --init map
    map = loader.loadFromLua(data)

    --init OBJ
     sheet = love.graphics.newImage("asset/assets.png")
     shadow = love.graphics.newImage("asset/ombres.png")
     sheet2 = love.graphics.newImage("asset/assets2.png")
     shadow2 = love.graphics.newImage("asset/ombres2.png")
    pommeImg = love.graphics.newImage("asset/pomme.png")
    medecineImg = love.graphics.newImage("asset/medecine.png")
    maisImg = love.graphics.newImage("asset/mais.png")
    cochonImg = love.graphics.newImage("asset/cochon.png")
    rootImg = love.graphics.newImage("asset/root.png")
    noiseImg = love.graphics.newImage("asset/noise.png")
    boarImg = love.graphics.newImage("asset/bb.png")

    fUp = love.graphics.newImage("asset/haut.png")
    fDown = love.graphics.newImage("asset/bas.png")
    fLeft = love.graphics.newImage("asset/gauche.png")
    fRight = love.graphics.newImage("asset/droite.png")
    parImg = love.graphics.newImage("asset/part.png")
    psystem = love.graphics.newParticleSystem(parImg, 400)

    map.objCreateF = function(obj)
      if obj.properties.Pig == true then
        --pig = Pig.newPig(world, obj)
      elseif obj.properties.Wolf == true then
          wolf = Wolf.newWolf(world, obj)
      elseif obj.properties.Boar == true then
          boar = Boar.newBoar(world, obj)
      elseif obj.properties.Player == true then
        objStart = obj
      elseif obj.properties.Weed == true then
        if obj.properties.state then
          obj.state = obj.properties.state
        end
        weed = Weed.newWeed(world, obj)
      elseif obj.properties.Pomme == true then
        obj.width = 64
        obj.height = 64
        b = Bonus.newBonus(obj, pommeImg)
        b.type = "Pomme"
        b.fix:setSensor(true)
      elseif obj.properties.Medecine == true then
        obj.width = 128-32
        obj.height = 64
        obj.idx = 128+16
        obj.idy = 128*2+32
        b = Bonus.newBonus(obj, sheet2)
        b.type = "Medecine"
        b.fix:setSensor(true)
      elseif obj.properties.Mais == true then
        obj.width = 64
        obj.height = 64
        b = Bonus.newBonus(obj, maisImg)
        b.type = "Mais"
        b.fix:setSensor(true)
      elseif obj.properties.Root == true then
        obj.width = 128-64
        obj.height = 64
        obj.idx = 128*2+32
        obj.idy = 32+16
        b = Bonus.newBonus(obj, sheet2)
        b.type = "Root"
        b.fix:setSensor(true)
      elseif obj.properties.collidable == true then --DEFAULT COLLIDER
        body = love.physics.newBody(world, obj.x + obj.width / 2, obj.y + obj.height / 2)
        shape = love.physics.newRectangleShape(obj.width, obj.height)
        fix = love.physics.newFixture(body, shape, 20)
      end

      if obj.properties.bounce then
        fix:setRestitution(0.9)
      end
      if obj.properties.Home then
        home.body = body
        home.shape = shape
        home.fix = fix
        --fix:setSensor(true)
        fix:setUserData({type="Home"})
        fix:setRestitution(0.0)
      end
    end
    --end

    --effect  = love.graphics.newShader("toto.frag")
    effect  = love.graphics.newShader("des.frag")

  	psystem:setParticleLifetime(0.25, 0.7) -- Particles live at least 2s and at most 5s.
  	psystem:setSizeVariation(0, 1)
    --psystem:setEmissionRate(5)
  	--psystem:setLinearAcceleration(-20, -20, 20, 20) -- Random movement in all directions.
  	psystem:setColors(0, 0, 0, 1, 1, 1, 1, 0) -- Fade to transparency.
    --psystem:pause()

    Pig.setImgSheet(sheet, shadow)
    Weed.setImgSheet(sheet, shadow)
    Player.setImgSheet(sheet, shadow)
    Wolf.setImgSheet(sheet2, shadow2)
    Boar.setImgSheet(boarImg, shadow2)
    map:initObj(world)
    --end
    self.isInit = true
  end

  player = Player.newPlayer(world, objStart)

  print("pig: "..self.pig)
  Pig.deploy(scene, self.pig)

  for p=1,3+dayCount do
    obj.width = 64
    obj.height = 64
    obj.x = 64 + math.random(0, 64*62)
    obj.y = 64 + math.random(0, 64*62)
    b = Bonus.newBonus(obj, pommeImg)
    b.type = "Pomme"
    b.fix:setSensor(true)
  end
  for p=1,1+dayCount do
    obj.width = 128-64
    obj.height = 64
    obj.x = 64 + math.random(0, 64*62)
    obj.y = 64 + math.random(0, 64*62)
    obj.idx = 128*2+32
    obj.idy = 32+16
    b = Bonus.newBonus(obj, sheet2)
    b.type = "Root"
    b.fix:setSensor(true)
  end


  for p=1,1+dayCount/2 do
    obj.width = 128-32
    obj.height = 64
    obj.x = 64 + math.random(0, 64*62)
    obj.y = 64 + math.random(0, 64*62)
    obj.idx = 128+16
    obj.idy = 128*2+32
    b = Bonus.newBonus(obj, sheet2)
    b.type = "Medecine"
    b.fix:setSensor(true)
  end

  for i=1,dayCount,2 do --CREATION DE BOAR
    local dx = 64 + math.random(0, 64*62)
    local dy = 64 + math.random(0, 64*62)

    if i >= 2 then
      boar = Boar.newBoar(world, {x=dx, y=dy})
      print("boar")
    end
  end

  for i=1,dayCount,5 do --CREATION WOLF
    local dx = 64 + math.random(0, 64*62)
    local dy = 64 + math.random(0, 64*62)

    if i >= 4 then
      wolf = Wolf.newWolf(world, {x=dx, y=dy})
      print("Wolf")
    end
  end
  self.pig = 0
  --camera
  context.camera = Camera.newCamera(200, 200, player, MAPS, MAPS, amTL, pmTL, isDebug())
  camera = context.camera
end

rot = function(vx, vy, a)
  rx = vx * math.cos(a) - vy * math.sin(a)
  ry = vx * math.sin(a) + vy * math.cos(a)
  return rx, ry
end

function scene:update(dt)
  world:update(dt)

  self.time = self.time - dt
  if self.time < pmTL and self.panic == false then
    self.panic = true
    Pig.foreach(function(p) p:setPanic(true) end)
  end

  if love.keyboard.isDown("right") then --press the right arrow key to push the ball to the right
    player.body:applyLinearImpulse(10, 0)
  end
  if love.keyboard.isDown("left") then --press the left arrow key to push the ball to the left
    player.body:applyLinearImpulse(-10, 0)
  end
  if love.keyboard.isDown("up") then
    player.body:applyLinearImpulse(0, -10)
  end
  if love.keyboard.isDown("down") then
    player.body:applyLinearImpulse(0, 10)
  end

  -- UPDATE CAMERA BOX POSITION
  context.camera:update(dt)

  if love.keyboard.isDown("x") then --PUSH
    local pig, dp = player:findCloser(Pig)
    local wolf, dw = player:findCloser(Wolf)
    local boar, db = player:findCloser(Boar)
    local obj = nil
    local d = 0

    if not obj and pig then obj = pig d = dp end
    if not obj and wolf then obj = wolf d = dw end
    if not obj and boar then obj = boar d = db end

    if wolf and d > dw then obj = wolf d = dw end
    if boar and d > db then obj = boar d = db end

    if obj and d < 120 then
      local vx = obj.body:getX() - player.body:getX()
      local vy = obj.body:getY() - player.body:getY()
      local n = math.sqrt(vx * vx + vy * vy)
      vx = vx / n
      vy = vy / n

      vx1, vy1 = rot(vx, vy, -0.5)
      vx2, vy2 = rot(vx, vy, 0.5)
      psystem:setLinearAcceleration(vx1 * 5000, vy1 * 5000, vx2 * 8000, vy2 * 8000)
      -- psystem:setPosition(pig.body:getX() - (camera.x - love.graphics.getWidth() / 2),
      --                     pig.body:getY() - (camera.y - love.graphics.getHeight() / 2))
      psystem:setPosition(obj.body:getX(), obj.body:getY())
      psystem:emit(16)
      player:kick(obj)
    end
  end --END

  if love.keyboard.isDown("c") then --GET MAIS
    local weed, d = player:findCloser(Weed)
    if weed and d < 80 and weed.state == 2 then
      print(weed.live)
      player:addMais(weed.live)
      weed.live = -1
    end
  end --END

  if love.keyboard.isDown("n") and player.mais >= 1 then --NOURRIR
    local pig, d = player:findCloser(Pig)
    if pig and d < 120 then
      pig.live = 1
      player.mais = player.mais - 1
    end
  end --END

  if love.keyboard.isDown("a") then
    Pig.clear()
  elseif love.keyboard.isDown("s") then
    player:plantedSeed()
  elseif love.keyboard.isDown("o") then
    Pig.foreach(function(p) p:setPanic(true) end)
  end
  screen:update(dt)

  Player.foreach(function(p) p:update(dt) end)
  Weed.foreach(function(w) w:update(dt) end)
  Wolf.foreach(function(w) w:update(dt) end)
  Boar.foreach(function(b) b:update(dt) end)
  Pig.foreach(function(p) p:update(dt) end)

  for _, body in pairs(world:getBodies()) do
    vx, vy = body:getLinearVelocity()
    r = body:getAngularVelocity()

    vx = vx * (0.95)
    vy = vy * (0.95)
    r = r * 0.90
    body:setLinearVelocity(vx, vy)
    body:setAngularVelocity(r)
  end

  if true then
    local bw, bh, g, w, h = 60, 60, 10, love.graphics.getWidth(), love.graphics.getHeight()
    setFontSize(12)
    if suit.Button("pause", 1 * w - bw - g, 0 * h + g, bw, bh).hit then
      Director.pause()
    end
  end

  if Pig.count() == 0 or self.time < 0 then
    if self.pig == 0 then
      return Director.leaveGame(false)
    else
      return Director.enterNextDay()
    end
  end

  psystem:update(dt)
end

function scene:draw()
  -- DRAW CAMERA BOX
  camera:draw(world, function()
    screen:apply()

    love.graphics.setColor(255, 255, 255)
    map:draw(1)--sol
    love.graphics.setColor(1, 1, 1, 0.66)
    map:draw(2)--ombre
    love.graphics.setColor(255, 255, 255)
    player:drawShadow()
    Pig.foreach(function(pig) pig:drawShadow() end)
    love.graphics.setColor(1, 1, 1, 0.5)
    Weed.foreach(function(w) w:drawShadow() end)
    --love.graphics.setColor(1, 1, 1, 0.5)
    --Wolf.foreach(function(w) w:drawShadow() end)
    map:draw(3)--mid

    --player:draw()
    -- love.graphics.setColor(0.76, 0.18, 0.05)
    -- love.graphics.rectangle("fill", ball.body:getX() - 16, ball.body:getY() - 16, 32, 32)

    love.graphics.setColor(255, 255, 255)

    Bonus.foreach(function(b) b:draw() end)
    Pig.foreach(function(pig) pig:draw() end)
    Wolf.foreach(function(w) w:draw() end)
    Boar.foreach(function(w) w:draw() end)
    love.graphics.setShader()
    Weed.foreach(function(w) w:draw() end)

    Player.foreach(function(p) p:draw() end)

    love.graphics.setColor(255, 255, 255)
    map:draw(4)--top
    love.graphics.setColor(255, 255, 255)
    map:draw(5)--top2

    Pig.foreach(function(pig) pig:drawFinal() end)
    Pig.foreach(function(pig) pig:drawEtat() end)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(psystem)

  end)


  setFontSize(12)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(pommeImg, 0, 10, 0, 0.5, 0.5)
  love.graphics.setColor(1, 0.2, 0.1, 1)
  love.graphics.print("X "..player.pomme, 42, 15)

  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(medecineImg, 0, 10+45, 0, 0.5, 0.5)
  love.graphics.setColor(1, 0.2, 0.1, 1)
  love.graphics.print("X "..player.medecine, 42, 15+45)

  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(maisImg, 0, 10+45*2, 0, 0.5, 0.5)
  love.graphics.setColor(1, 0.2, 0.1, 1)
  love.graphics.print("X "..math.floor(player.mais).."  "..math.floor((player.mais-math.floor(player.mais))*100).." %", 42, 15+45*2)

  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(cochonImg, 0, 10+45*3, 0, 0.5, 0.5)
  love.graphics.setColor(1, 0.2, 0.1, 1)
  love.graphics.print("X "..Pig.count(), 42, 15+45*3)

  local v = 1
  love.graphics.setColor(v, v, v, 1)
  setFontSize(30)
  love.graphics.print(math.floor(self.time), love.graphics.getWidth() / 2 - 20, 10)

  suit.draw()
end

return scene
