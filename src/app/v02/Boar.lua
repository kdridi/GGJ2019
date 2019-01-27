BOAR = {}
BOARS = {}

local waitT = 1

function  BOAR:new(world, p)
  obj = {}
  setmetatable(obj, self)
  self.__index = self


  p.width = 128-32
  p.height = 64

  obj.width = p.width
  obj.height = p.height
  obj.body = love.physics.newBody(world, p.x + p.width / 2, p.y + p.height / 2, "dynamic")
  obj.shape = love.physics.newRectangleShape(p.width, p.height)
  obj.fix = love.physics.newFixture(obj.body, obj.shape, 2)

  obj.type = "Boar"
  obj.fix:setUserData(obj)

  obj.id = 0
  obj.time = 0
  obj.atk = 0
  obj:setId(0)

  obj.closer = nil
  obj.state = 0
  obj.d = 0

  return (obj)
end

function  BOAR:setId(id)
  w, h = self.imgSheet:getDimensions()

  local idx = 16
  local idy = 32

  self.id = id
  self.squade = love.graphics.newQuad(idx, idy, self.width, self.height, self.imgSheet:getDimensions())
end

function  BOAR:draw()
  local x, y = self.body:getWorldPoints(self.shape:getPoints())
  local r = self.body:getAngle()

  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.imgSheet, self.squade, x, y, r)
end


function  BOAR:findCloser(list)
  closer = nil
  dmin = 0

  list.foreach(function(v)
    if not closer then
      closer = v
      dmin = v:distanceFrom(self.body:getX(), self.body:getY())
    else
      d = v:distanceFrom(self.body:getX(), self.body:getY())
      if d < dmin then
        dmin = d
        closer = v
      end
    end --closer
  end)

  return closer, dmin
end

function  BOAR:attack(pig)
  if self.state == 0 then
    local vx = pig.body:getX() - self.body:getX()
    local vy = pig.body:getY() - self.body:getY()
    local n = math.sqrt(vx * vx + vy * vy)

    if not power then power = 1234 end
    vx = vx / n
    vy = vy / n
    pig.body:applyLinearImpulse(vx * power, vy * power)

    self.state = 1
    self.atk = waitT
    screen:setShake(20)
    playFX('punch')
  end
end

function  BOAR:update(dt)
  self.time = self.time - dt
  self.atk = self.atk - dt
  self.closer = nil

  if self.atk < 0 then
    self.closer, self.d = self:findCloser(Pig)
    self.state = 0
    if self.closer and self.d < 160 then
      self:attack(self.closer)
    end
    self.atk = waitT
  end

  if self.time < 0 then
    self.time = 0.75

    r = math.random(0, 10)

    if r > 2 and self.closer then
      local vx = self.closer.body:getX() - self.body:getX()
      local vy = self.closer.body:getY() - self.body:getY()
      local n = math.sqrt(vx * vx + vy * vy)

      if not power then power = 3000 end
      vx = vx / n
      vy = vy / n
      self.body:applyLinearImpulse(vx * 1000, vy * 3000)
    else
      self.body:applyLinearImpulse(math.random(2000), math.random(2000))
    end
  end
end

--RETURN

return {
  setImgSheet = function(img, shadow)
    BOAR.imgSheet = img
    BOAR.shadowSheet = shadow
  end,

  newBoar = function(world, obj)
    obj = BOAR:new(world, obj)
    table.insert(BOARS, obj)
    return obj
  end,

  foreach = function(f)
    t_c = {}
    for i, v in pairs(BOARS) do
      table.insert(t_c, v)
    end
    for i, v in pairs(t_c) do
      f(v)
    end
  end,

  del = function(v)
    for idx, value in pairs(BOARS) do
      if value == v then
        table.remove(BOARS, idx)
        v.fix:destroy()
        return
      end
    end
  end,

  clear = function()
    while #BOARS >= 1 do
      BOARS[1].fix:destroy()
      table.remove(BOARS, 1)
    end
  end,

  all = function()
    return ipair(BOARS)
  end
}
