game = Gamestate.new()


map = {}

--sti = require "STI/sti"
loader = require "../loader"
data = require "../map"
Pig = require "../Pig"
Player = require "../Player"
inspect = require "../vendor/inspect"
Camera = require "../camera"
local screen = require "../vendor/shack/shack"

local player = {}
local world = {}
local map = {}

local MAPW = 50
local MAPH = 40
local MAPS = 32

local camera = {}

function game:init()
  screen:setDimensions(love.graphics.getWidth(), love.graphics.getHeight())

  love.physics.setMeter(32)
  world = love.physics.newWorld(0, 0, true)
  world:setCallbacks(function(a, b, coll)
    if a:getUserData() and a:getUserData().type and
       b:getUserData() and b:getUserData().type then
      print("a : "..a:getUserData().type)
      print("b : "..b:getUserData().type)

      if a:getUserData().type == "Pig" and b:getUserData().type == "Home" then
        Pig.del(a:getUserData())
        print("DELETE")
      end
    end
  end, nil, nil, nil)
end

function game:enter(previous)
  Player.del(player)
  Pig.clear()

  --init map
  map = loader.loadFromLua(data)
  map.objCreateF = function(obj)
    if obj.properties.Pig == true then
      pig = Pig.newPig(world, obj)
    elseif obj.properties.Player == true then
      print("PLAYER")
      player = Player.newPlayer(world, obj)
    elseif obj.properties.collidable == true then --DEFAULT COLLIDER
      body = love.physics.newBody(world, obj.x + obj.width / 2, obj.y + obj.height / 2)
      shape = love.physics.newRectangleShape(obj.width, obj.height)
      fix = love.physics.newFixture(body, shape, 20)
    end

    if obj.properties.Home then
      --fix:setSensor(true)
      fix:setUserData({type="Home"})
    end
  end
  --end

  --init OBJ
  Pig.setImgSheet(map.imgSheet)
  Player.setImgSheet(map.imgSheet)
  map:initObj(world)
  --end

  --camera
  camera = Camera.newCamera(200, 200, player, MAPS, MAPS, false)
end

function game:update(dt)
  world:update(dt)

  print(dt)
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
  camera:update(dt)

  if love.keyboard.isDown("x") then --PUSH
    closer = nil
    dmin = 0

    Pig.foreach(function(pig)
      if not closer then
        closer = pig
        dmin = pig:distanceFrom(player.body:getX(), player.body:getY())
      else
        d = pig:distanceFrom(player.body:getX(), player.body:getY())
        if d < dmin then
          dmin = d
          closer = pig
        end
      end --closer
    end)

    if dmin < 50 and closer then
      local vx = closer.body:getX() - player.body:getX()
      local vy = closer.body:getY() - player.body:getY()
      closer.body:applyLinearImpulse(vx * 100, vy * 100)
      screen:setShake(20)
    end
    
  end --END

  screen:update(dt)

  for _, body in pairs(world:getBodies()) do
    vx, vy = body:getLinearVelocity()

    vx = vx * (0.95)
    vy = vy * (0.95)
    body:setLinearVelocity(vx, vy)
  end
end

function game:draw()
  -- DRAW CAMERA BOX
  camera:draw(world, function()
    screen:apply()

    love.graphics.setColor(255, 255, 255)
    map:draw(1)
    map:draw(2)

    --Player.foreach(function(pig) pig:draw() end)
    player:draw()
    -- love.graphics.setColor(0.76, 0.18, 0.05)
    -- love.graphics.rectangle("fill", ball.body:getX() - 16, ball.body:getY() - 16, 32, 32)

    love.graphics.setColor(255, 255, 255)
    Pig.foreach(function(pig) pig:draw() end)

    map:draw(3)
    love.graphics.setColor(255, 255, 255)
  end)
end





return game

