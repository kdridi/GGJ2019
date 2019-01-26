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

  return (camera)
end

function  CAMERA:draw()
  love.graphics.translate(love.graphics.getWidth() / 2 - self.x, love.graphics.getHeight() / 2 - self.y)
  if (self.debug) then
    love.graphics.rectangle("line", self.x - self.w / 2, self.y - self.h / 2, self.w, self.h)
  end
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
end

return {
  newCamera = function(cw, ch, target, w, h, debug)
    obj = CAMERA:new(cw, ch, target, w, h, debug)
    table.insert(CAMERAS, obj)
    return obj
  end
}
