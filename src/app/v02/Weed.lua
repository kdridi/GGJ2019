WEED = {}
WEEDS = {}

function  WEED:new(p)
  obj = {}
  setmetatable(obj, self)
  self.__index = self

  p.width = 32
  p.height = 32
  p.id = 0

  obj.body = love.physics.newBody(world, p.x + p.width / 2, p.y + p.height / 2, "static")
  obj.shape = love.physics.newRectangleShape(p.width, p.height)
  obj.fix = love.physics.newFixture(obj.body, obj.shape, 0.10)

  obj:setId(p.id)

  obj.type = "Weed"
  obj.fix:setUserData(obj)

  obj.state = 0
  obj.time = 3
  return (obj)
end

function  WEED:setId(id)
  w, h = self.imgSheet:getDimensions()
  self.id = id - 1
  local idx = 140
  local idy = 32

  self.id = id
  self.squade = love.graphics.newQuad(idx, idy, 32, 32, self.imgSheet:getDimensions())
end

function  WEED:draw()

  local x, y = self.body:getWorldPoints(self.shape:getPoints())
  local r = self.body:getAngle()

  if self.state == 0 then
    love.graphics.setColor(255, 0, 0)
  elseif self.state == 1 then
    love.graphics.setColor(0, 255, 0)
  else
    love.graphics.setColor(0, 0, 255)
  end

  love.graphics.draw(self.imgSheet, self.squade, x, y, r)
end

function WEED:update(dt)

  if self.state < 3 then
    self.time = self.time - dt
    if self.time < 0 then
      self.state = self.state + 1
      self.time = 3
    end
  end
end

function  WEED:distanceFrom(x, y)
  local vx = x - self.body:getX()
  local vy = y - self.body:getY()

  local d = math.sqrt((vx * vx) + (vy * vy))
  return d
end

--RETURN

return {
  setImgSheet = function(img)
    WEED.imgSheet = img
  end,

  newWeed = function(x, y)
    obj = WEED:new(x,y)
    table.insert(WEEDS, obj)
    return obj
  end,

  foreach = function(f)
    t_c = {}
    for i, v in pairs(WEEDS) do
      table.insert(t_c, v)
    end
    for i, v in pairs(t_c) do
      f(v)
    end
  end,

  del = function(v)
    for idx, value in pairs(WEEDS) do
      if value == v then
        table.remove(WEEDS, idx)
        v.fix:destroy()
        return
      end
    end
  end,

  all = function()
    return ipair(WEEDS)
  end

}
