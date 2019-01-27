WEED = {}
WEEDS = {}

local waitT = 2

function  WEED:new(world, p)
  obj = {}
  setmetatable(obj, self)
  self.__index = self

  p.width = 42
  p.height = 15*2
  if not p.state then
    p.state = 0
  end

  obj.state = p.state
  obj.body = love.physics.newBody(world, p.x + p.width / 2, p.y + p.height / 2, "static")
  obj.shape = love.physics.newRectangleShape(p.width, p.height)
  obj.fix = love.physics.newFixture(obj.body, obj.shape, 0.10)

  obj:setId(p.state)

  obj.type = "Weed"
  obj.fix:setUserData(obj)

  obj.time = waitT
  obj.live = 1
  return (obj)
end

function  WEED:setId(id)
  w, h = self.imgSheet:getDimensions()
  self.id = id - 1
  local idx = 42 + 64*2*id
  local idy = 0

  self.id = id
  self.squade = love.graphics.newQuad(idx, idy, 64, 64*2, self.imgSheet:getDimensions())
end

function  WEED:draw()

  local x, y = self.body:getWorldPoints(self.shape:getPoints())
  local r = self.body:getAngle()

  love.graphics.setColor(self.live, self.live, self.live)

  local t = 1 - self.live
  --print(t)
  effect:send("time", t-0.2)
  effect:send("tt", noiseImg)
  love.graphics.setShader(effect)
  love.graphics.draw(self.imgSheet, self.squade, x, y - 64*2+25*2, r)
  love.graphics.setShader()
end

function  WEED:drawShadow()

  local x, y = self.body:getWorldPoints(self.shape:getPoints())

  love.graphics.draw(self.shadowSheet, self.squade, x, y - 64*2+25*2)
end

function WEED:update(dt)

  if self.state < 2 then
    self.time = self.time - dt
    if self.time < 0 then
      self.state = self.state + 1
      self.time = waitT
      self:setId(self.state)
    end
  end

  --DEATH
  if self.live < 0 then
    for idx, value in pairs(WEEDS) do
      if value == self then
        value.fix:destroy()
        table.remove(WEEDS, idx)
        return
      end
    end--FOR
  end--IF

end

function  WEED:distanceFrom(x, y)
  local vx = x - self.body:getX()
  local vy = y - self.body:getY()

  local d = math.sqrt((vx * vx) + (vy * vy))
  return d
end

--RETURN

return {
  setImgSheet = function(img, shadow)
    WEED.imgSheet = img
    WEED.shadowSheet = shadow
  end,

  newWeed = function(world, x, y)
    obj = WEED:new(world, x,y)
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

  clear = function()
    while #WEEDS >= 1 do
      WEEDS[1].fix:destroy()
      table.remove(WEEDS, 1)
    end
  end,

  all = function()
    return ipair(WEEDS)
  end
}
