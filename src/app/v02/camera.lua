moonshine = require 'vendor/moonshine'

local daynight = require('shaders/daynight')

CAMERA = {}
CAMERAS = {}


function CAMERA:new(cw, ch, target, w, h, debug)
  camera = {}
  setmetatable(camera, self)
  self.__index = self

  camera.debug = debug
  camera.target = target
  camera.dimension = {}
  camera.dimension.w = w
  camera.dimension.h = h
  camera.x = target.body:getX()
  camera.y = target.body:getY()
  camera.w = cw
  camera.h = ch
  
  camera.effect = moonshine(daynight)
  camera.effect.daynight.resolution = { love.graphics.getWidth(), love.graphics.getHeight() }
  camera.effect.daynight.time = 0.1
  camera.effect.daynight.delay = 5.0
  camera.effect.daynight.speed = 3.0
  camera.time = 0.0
  
  return (camera)
end

function CAMERA:draw(world, f)
  self.effect(function()
    love.graphics.translate(love.graphics.getWidth() / 2 - self.x, love.graphics.getHeight() / 2 - self.y)
    f()
    if (self.debug) then
      --love.graphics.rectangle("line", self.x - self.w / 2, self.y - self.h / 2, self.w, self.h)

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

    love.graphics.translate(self.x - love.graphics.getWidth() / 2, self.y - love.graphics.getHeight() / 2)
  end)
end

function CAMERA:update(dt)
  if true then
    local dir = 0 - 1
    local dx = dir * (self.x - self.target.body:getX()) - (self.w - self.dimension.w) / 2
    if (dx > 0) then
      self.x = self.x - dir * dx
    end
  end
  if true then
    local dir = 0 + 1
    local dx = dir * (self.x - self.target.body:getX()) - (self.w - self.dimension.w) / 2
    if (dx > 0) then
      self.x = self.x - dir * dx
    end
  end
  if true then
    dir = 0 - 1
    dy = dir * (self.y - self.target.body:getY()) - (self.h - self.dimension.h) / 2
    if (dy > 0) then
      self.y = self.y - dir * dy
    end
  end
  if true then
    dir = 0 + 1
    dy = dir * (self.y - self.target.body:getY()) - (self.h - self.dimension.h) / 2
    if (dy > 0) then
      self.y = self.y - dir * dy
    end
  end
  
  camera.time = camera.time + dt
  camera.effect.daynight.time = camera.time
  camera.effect.daynight.position = {
    love.graphics.getWidth()  / 2 + self.target.body:getX() - self.x,
    love.graphics.getHeight() / 2 + self.target.body:getY() - self.y
  }

end

return {
  newCamera = function(cw, ch, target, w, h, debug)
    obj = CAMERA:new(cw, ch, target, w, h, debug)
    table.insert(CAMERAS, obj)
    return obj
  end
}
