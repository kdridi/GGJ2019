local scene = newScene()

map = {}

--sti = require "STI/sti"
loader = require "../loader"
data = require "../map"
Pig = require "../Pig"
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
          Pig.del(a:getUserData()) end
      elseif b:getUserData().type == "Pig" and a:getUserData().type == "Home" then
        if b:getUserData().panic == true then
          Pig.del(b:getUserData()) end
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
    elseif obj.properties.Player == true then
      player = Player.newPlayer(world, obj)
    elseif obj.properties.Weed == true then
      if obj.properties.state then
        print("IS OK!!!")
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
      print(obj)
      b = Bonus.newBonus(obj, medecineImg)
      b.type = "Medecine"
      b.fix:setSensor(true)
    elseif obj.properties.Medecine == true then
      obj.width = 64
      obj.height = 64
      print(obj)
      b = Bonus.newBonus(obj, maisImg)
      b.type = "Mais"
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

  fUp = love.graphics.newImage("asset/haut.png")
  fDown = love.graphics.newImage("asset/bas.png")
  fLeft = love.graphics.newImage("asset/gauche.png")
  fRight = love.graphics.newImage("asset/droite.png")

  Pig.setImgSheet(sheet, shadow)
  Weed.setImgSheet(sheet, shadow)
  Player.setImgSheet(sheet, shadow)
  map:initObj(world)
  --end

  Pig.deploy(5)
  --camera
  context.camera = Camera.newCamera(200, 200, player, MAPS, MAPS, true)
  camera = context.camera
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
  Pig.foreach(function(p) p:update(dt) end)

  for _, body in pairs(world:getBodies()) do
    vx, vy = body:getLinearVelocity()
    r = body:getAngularVelocity()

    vx = vx * (0.95)
    vy = vy * (0.95)
    r = r * 0.95
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
    map:draw(3)--mid

    --Player.foreach(function(pig) pig:draw() end)
    player:draw()
    -- love.graphics.setColor(0.76, 0.18, 0.05)
    -- love.graphics.rectangle("fill", ball.body:getX() - 16, ball.body:getY() - 16, 32, 32)

    love.graphics.setColor(255, 255, 255)
    Pig.foreach(function(pig) pig:draw() end)
    Weed.foreach(function(w) w:draw() end)
    Bonus.foreach(function(b) b:draw() end)

    love.graphics.setColor(255, 255, 255)
    map:draw(4)--top
    love.graphics.setColor(255, 255, 255)
    map:draw(5)--top2
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
