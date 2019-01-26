map = {}

--sti = require "STI/sti"
loader = require "loader"
data = require "map"

ball = {}
world = {}
map = {}

function love.load()
  love.window.setMode(20*32,30*32)
  -- Grab window size
  windowWidth  = love.graphics.getWidth()
  windowHeight = love.graphics.getHeight()

  print(data.orientation)
  map = loader.loadFromLua(data)

  love.physics.setMeter(32)
  world = love.physics.newWorld(0, 9.81*32, true)


  map:initPhx(world)

  --player
  ball.body = love.physics.newBody(world, 20*32/2, 30*32/2, "dynamic") --place the body in the center of the world and make it dynamic, so it can move around
  ball.body:setFixedRotation(true)
  ball.shape = love.physics.newRectangleShape(32, 32)
  ball.fixture = love.physics.newFixture(ball.body, ball.shape, 1) -- Attach fixture to body and give it a density of 1.
  --end

  --PART

end

function love.update(dt)
  world:update(dt)

  if love.keyboard.isDown("right") then --press the right arrow key to push the ball to the right
    ball.body:applyLinearImpulse(10, 0)
  end
  if love.keyboard.isDown("left") then --press the left arrow key to push the ball to the left
    ball.body:applyLinearImpulse(-10, 0)
  end
  if love.keyboard.isDown("up") then
    ball.body:applyLinearImpulse(0, -50)
  end
  if love.keyboard.isDown("down") then
    ball.body:applyLinearImpulse(0, 100)
  end

  if ball.body:getX() < 0 then
    ball.body:setLinearVelocity(0, 0)
    ball.body:setX(0)
  end
  if ball.body:getY() < 0 then
    ball.body:setLinearVelocity(0, 0)
    ball.body:setY(0)
  end
  if ball.body:getX() >= 20*32 then
    ball.body:setLinearVelocity(0, 0)
    ball.body:setX(20*32 - 1)
  end
  if ball.body:getY() >= 30*32 then
    ball.body:setLinearVelocity(0, 0)
    ball.body:setY(30*32 - 1)
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
