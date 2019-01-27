local scene = newScene()

map = {}

--sti = require "STI/sti"
loader = require "../loader"
data = require "../map"
Pig = require "../Pig"
Wolf = require "../Wolf"
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

local MAPW = 50
local MAPH = 40
local MAPS = 32

local panicTIme = 42
local startTime = 60

local context = {}

function scene:init()
  screen:setDimensions(love.graphics.getWidth(), love.graphics.getHeight())

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
      elseif a:getUserData().type == "Root" and (b:getUserData().type == "Player" or b:getUserData().type == "Pig") then
        b:getUserData():setRoot(true)
        Bonus.del(a:getUserData())
      elseif b:getUserData().type == "Root" and (a:getUserData().type == "Player" or a:getUserData().type == "Pig") then
        a:getUserData():setRoot(true)
        Bonus.del(b:getUserData())
      end
    end
  end, nil, nil, nil)
end

function scene:enter(previous, dayCount)
  context.dayCount = dayCount
  context.time = 0

  self.time = startTime
  self.panic = false

  Player.del(player)
  Pig.clear()
  Weed.clear()
  Bonus.clear()

  --init map
  map = loader.loadFromLua(data)
  map.objCreateF = function(obj)
    if obj.properties.Pig == true then
      --pig = Pig.newPig(world, obj)
    elseif obj.properties.Wolf == true then
        wolf = Wolf.newWolf(world, obj)
    elseif obj.properties.Player == true then
      player = Player.newPlayer(world, obj)
    elseif obj.properties.Weed == true then
      if obj.properties.state then
        obj.state = obj.properties.state
      end
      weed = Weed.newWeed(world, obj)
    elseif obj.properties.Pomme == true then
      obj.width = 64
      obj.height = 64
      print(obj)
      b = Bonus.newBonus(obj, pommeImg)
      b.type = "Pomme"
      b.fix:setSensor(true)
    elseif obj.properties.Medecine == true then
      obj.width = 64
      obj.height = 64
      b = Bonus.newBonus(obj, medecineImg)
      b.type = "Medecine"
      b.fix:setSensor(true)
    elseif obj.properties.Mais == true then
      obj.width = 64
      obj.height = 64
      b = Bonus.newBonus(obj, maisImg)
      b.type = "Mais"
      b.fix:setSensor(true)
    elseif obj.properties.Root == true then
      obj.width = 64
      obj.height = 64
      b = Bonus.newBonus(obj, rootImg)
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

  --init OBJ
  local sheet = love.graphics.newImage("asset/test.png")
  local shadow = love.graphics.newImage("asset/ombres.png")
  pommeImg = love.graphics.newImage("asset/pomme.png")
  medecineImg = love.graphics.newImage("asset/medecine.png")
  maisImg = love.graphics.newImage("asset/mais.png")
  cochonImg = love.graphics.newImage("asset/cochon.png")
  rootImg = love.graphics.newImage("asset/root.png")
  noiseImg = love.graphics.newImage("asset/noise.png")

  fUp = love.graphics.newImage("asset/haut.png")
  fDown = love.graphics.newImage("asset/bas.png")
  fLeft = love.graphics.newImage("asset/gauche.png")
  fRight = love.graphics.newImage("asset/droite.png")
  parImg = love.graphics.newImage("asset/part.png")
  psystem = love.graphics.newParticleSystem(parImg, 400)
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
  Wolf.setImgSheet(sheet, shadow)
  map:initObj(world)
  --end

  Pig.deploy(5)
  --camera
  context.camera = Camera.newCamera(200, 200, player, MAPS, MAPS, isDebug())
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
  if self.time < 20 and self.panic == false then
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
    local pig, d = player:findCloser(Pig)
    if pig and d < 120 then
      local vx = pig.body:getX() - player.body:getX()
      local vy = pig.body:getY() - player.body:getY()
      local n = math.sqrt(vx * vx + vy * vy)
      vx = vx / n
      vy = vy / n

      vx1, vy1 = rot(vx, vy, -0.5)
      vx2, vy2 = rot(vx, vy, 0.5)
      psystem:setLinearAcceleration(vx1 * 5000, vy1 * 5000, vx2 * 8000, vy2 * 8000)
      -- psystem:setPosition(pig.body:getX() - (camera.x - love.graphics.getWidth() / 2),
      --                     pig.body:getY() - (camera.y - love.graphics.getHeight() / 2))
      psystem:setPosition(pig.body:getX(), pig.body:getY())
      psystem:emit(16)
      player:kick(pig)
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
    Weed.clear()
  elseif love.keyboard.isDown("s") then
    player:plantedSeed()
  elseif love.keyboard.isDown("o") then
    Pig.foreach(function(p) p:setPanic(true) end)
  end
  screen:update(dt)

  Player.foreach(function(p) p:update(dt) end)
  Weed.foreach(function(w) w:update(dt) end)
  Wolf.foreach(function(w) w:update(dt) end)
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

  if Pig.count() == 0 then
    return Director.enterNextDay()
  end

  psystem:update(dt)
end

function scene:draw()
  -- DRAW CAMERA BOX
  camera:draw(world, function()
    screen:apply()

    love.graphics.setColor(255, 255, 255)
    map:draw(1)--sol
    love.graphics.setColor(1, 1, 1, 0.33)
    map:draw(2)--ombre
    love.graphics.setColor(255, 255, 255)
    player:drawShadow()
    Pig.foreach(function(pig) pig:drawShadow() end)
    love.graphics.setColor(1, 1, 1, 0.5)
    Weed.foreach(function(w) w:drawShadow() end)
    --love.graphics.setColor(1, 1, 1, 0.5)
    --Wolf.foreach(function(w) w:drawShadow() end)
    map:draw(3)--mid

    Player.foreach(function(p) p:draw() end)
    --player:draw()
    -- love.graphics.setColor(0.76, 0.18, 0.05)
    -- love.graphics.rectangle("fill", ball.body:getX() - 16, ball.body:getY() - 16, 32, 32)

    love.graphics.setColor(255, 255, 255)

    Pig.foreach(function(pig) pig:draw() end)
    Wolf.foreach(function(w) w:draw() end)
    love.graphics.setShader()
    Weed.foreach(function(w) w:draw() end)
    Bonus.foreach(function(b) b:draw() end)

    love.graphics.setColor(255, 255, 255)
    map:draw(4)--top
    love.graphics.setColor(255, 255, 255)
    map:draw(5)--top2

    Pig.foreach(function(pig) pig:drawFinal() end)

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
  if self.time < 42 then
    v = self.time / 42 end
  love.graphics.setColor(v, v, v, 1)
  setFontSize(30)
  love.graphics.print(math.floor(self.time), love.graphics.getWidth() / 2 - 20, 10)

  suit.draw()
end

return scene
