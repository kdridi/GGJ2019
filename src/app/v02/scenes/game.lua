game = Gamestate.new()

map = {}

--sti = require "STI/sti"
loader = require "../loader"
data = require "../map"
Pig = require "../Pig"
Player = require "../Player"
Weed = require "../Weed"
inspect = require "../vendor/inspect"
Camera = require "../camera"
screen = require "../vendor/shack/shack"

player = {}
world = {}
local map = {}
home = {}

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
      if a:getUserData().type == "Pig" and b:getUserData().type == "Home" then
        Pig.del(a:getUserData())
      elseif b:getUserData().type == "Pig" and a:getUserData().type == "Home" then
        Pig.del(b:getUserData())
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
      --pig = Pig.newPig(world, obj)
    elseif obj.properties.Player == true then
      player = Player.newPlayer(world, obj)
    elseif obj.properties.Weed == true then
      if obj.properties.State then
        print("IS OK!!!")
        obj.state = obj.properties.State
      end
      weed = Weed.newWeed(world, obj)
    elseif obj.properties.collidable == true then --DEFAULT COLLIDER
      body = love.physics.newBody(world, obj.x + obj.width / 2, obj.y + obj.height / 2)
      shape = love.physics.newRectangleShape(obj.width, obj.height)
      fix = love.physics.newFixture(body, shape, 20)
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
  local sheet = love.graphics.newImage("asset/houseofpigs.png")
  Pig.setImgSheet(sheet)
  Weed.setImgSheet(sheet)
  Player.setImgSheet(sheet)
  map:initObj(world)
  --end

  Pig.deploy(20)
  --camera
  camera = Camera.newCamera(200, 200, player, MAPS, MAPS, false)
end

function game:update(dt)
  world:update(dt)

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

    local pig, d = player:findCloser(Pig)
    if pig and d < 120 then
      player:kick(pig)
    end

  end --END

  if love.keyboard.isDown("a") then
    Pig.clear()
  end

  screen:update(dt)

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

    Weed.foreach(function(w) w:draw() end)
    map:draw(3)
    love.graphics.setColor(255, 255, 255)
  end)
end

return game
