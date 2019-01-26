map = {}

--sti = require "STI/sti"
loader = require "loader"
data = require "map"
Pig = require "Pig"

ball = {}
world = {}
map = {}

function objCreation(obj)
  if obj.properties.Pig == true then
    pig = Pig.newPig(obj)
    pig.fix:setUserData(pig)
  elseif obj.properties.collidable == true then
    body = love.physics.newBody(world, obj.x + obj.width / 2, obj.y + obj.height / 2)
    shape = love.physics.newRectangleShape(obj.width, obj.height)
    fix = love.physics.newFixture(body, shape, 20)
  end

  if obj.properties.Home then
    --fix:setSensor(true)
    fix:setUserData({type="Home"})
  end
end

function love.load()
  love.window.setMode(50*32,40*32)
  -- Grab window size
  windowWidth  = love.graphics.getWidth()
  windowHeight = love.graphics.getHeight()

  map = loader.loadFromLua(data)
  map.objCreateF = objCreation

  love.physics.setMeter(32)
  world = love.physics.newWorld(0, 0, true)
  world:setCallbacks(beginContact, nil, nil, nil)


  map:initPhx(world)

  --player
  ball.body = love.physics.newBody(world, 20*32/2, 30*32/2, "dynamic") --place the body in the center of the world and make it dynamic, so it can move around
  ball.body:setFixedRotation(true)
  ball.shape = love.physics.newRectangleShape(32, 32)
  ball.fixture = love.physics.newFixture(ball.body, ball.shape, 1) -- Attach fixture to body and give it a density of 1.
  ball.fixture:setUserData({type="Player"})
  --end

  --PART

end

function love.update(dt)
  world:update(dt)

  print(dt)
  if love.keyboard.isDown("right") then --press the right arrow key to push the ball to the right
    ball.body:applyLinearImpulse(10, 0)
  end
  if love.keyboard.isDown("left") then --press the left arrow key to push the ball to the left
    ball.body:applyLinearImpulse(-10, 0)
  end
  if love.keyboard.isDown("up") then
    ball.body:applyLinearImpulse(0, -10)
  end
  if love.keyboard.isDown("down") then
    ball.body:applyLinearImpulse(0, 10)
  end


  if love.keyboard.isDown("x") then --PUSH
    closer = nil
    dmin = 0

    Pig.foreach(function(pig)
      if not closer then
        closer = pig
        dmin = pig:distanceFrom(ball.body:getX(), ball.body:getY())
      else
        d = pig:distanceFrom(ball.body:getX(), ball.body:getY())
        if d < dmin then
          dmin = d
          closer = pig
        end
      end --closer
    end)

    if dmin < 42 and closer then
      local vx = closer.body:getX() - ball.body:getX()
      local vy = closer.body:getY() - ball.body:getY()
      closer.body:applyLinearImpulse(vx * 100, vy * 100)
    end
  end --END

  for _, body in pairs(world:getBodies()) do
    vx, vy = body:getLinearVelocity()

    vx = vx * (0.95)
    vy = vy * (0.95)
    body:setLinearVelocity(vx, vy)
  end

end

function love.draw()
  love.graphics.setColor(255, 255, 255)
  love.graphics.print(data.orientation, 250, 250)
  map:draw(1)
  map:draw(2)

  love.graphics.setColor(0.76, 0.18, 0.05)
  love.graphics.rectangle("fill", ball.body:getX() - 16, ball.body:getY() - 16, 32, 32)

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
    print("a : "..a:getUserData().type)
    print("b : "..b:getUserData().type)

    if a:getUserData().type == "Pig" and b:getUserData().type == "Home" then
      Pig.del(a:getUserData())
      print("DELETE")
    end
  end

end

--END
