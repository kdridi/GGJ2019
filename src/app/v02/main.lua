map = {}

--sti = require "STI/sti"
loader = require "loader"
data = require "map"
Pig = require "Pig"
Player = require "Player"
inspect = require "vendor/inspect"
Camera = require "camera"
screen = require "vendor/shack/shack"

player = {}
world = {}
map = {}

local MAPW = 50
local MAPH = 40
local MAPS = 32

local camera = {}

--OBJ CREATION

function objCreation(obj)
  if obj.properties.Pig == true then
    pig = Pig.newPig(obj)
  elseif obj.properties.Player == true then
    player = Player.newPlayer(obj)
  elseif obj.properties.collidable == true then --DEFAULT COLLIDER
    body = love.physics.newBody(world, obj.x + obj.width / 2, obj.y + obj.height / 2)
    shape = love.physics.newRectangleShape(obj.width, obj.height)
    fix = love.physics.newFixture(body, shape, 20)
    fix:setRestitution(0.9)
  end

  if obj.properties.Home then
    --fix:setSensor(true)
    fix:setUserData({type="Home"})
    fix:setRestitution(0.0)
  end
end

function love.load()
  love.window.setMode(MAPW*MAPS,MAPH*MAPS)
  screen:setDimensions(love.graphics.getWidth(), love.graphics.getHeight())

  --init map
  map = loader.loadFromLua(data)
  map.objCreateF = objCreation
  --end

  --init physic
  love.physics.setMeter(32)
  world = love.physics.newWorld(0, 0, true)
  world:setCallbacks(beginContact, nil, nil, nil)
  --end

  --init OBJ
  local sheet = love.graphics.newImage("asset/sheet.png")
  Pig.setImgSheet(sheet)
  Player.setImgSheet(sheet)
  map:initObj(world)
  --end

  --camera
  camera = Camera.newCamera(200, 200, player, MAPS, MAPS, true)
end

function love.update(dt)
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

  screen:update(dt)

  for _, body in pairs(world:getBodies()) do
    vx, vy = body:getLinearVelocity()

    vx = vx * (0.95)
    vy = vy * (0.95)
    body:setLinearVelocity(vx, vy)
  end
end

function love.draw()
  -- DRAW CAMERA BOX
  camera:draw()
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


  --DRAW PHYSICS
  for _, body in pairs(world:getBodies()) do
    for _, fixture in pairs(body:getFixtures()) do
        local shape = fixture:getShape()

        if shape:typeOf("CircleShape") then
            local cx, cy = body:getWorldPoints(shape:getPoint())
            love.graphics.circle("line", cx, cy, shape:getRadius())
        elseif shape:typeOf("PolygonShape") then
            love.graphics.polygon("line", body:getWorldPoints(shape:getPoints()))
        else
            love.graphics.line(body:getWorldPoints(shape:getPoints()))
        end
    end
  end
  --END
end



--COLIDER

function beginContact(a, b, coll)

  if a:getUserData() and a:getUserData().type and
     b:getUserData() and b:getUserData().type then

    if a:getUserData().type == "Pig" and b:getUserData().type == "Home" then
      Pig.del(a:getUserData())
    end
  end

end

--END
