WOLF = {}
WOLFS = {}

local waitT = 0.5

function  WOLF:new(world, p)
  obj = {}
  setmetatable(obj, self)
  self.__index = self


  p.width = 64*2
  p.height = 64

  obj.width = p.width
  obj.height = p.height
  obj.body = love.physics.newBody(world, p.x + p.width / 2, p.y + p.height / 2, "dynamic")
  obj.shape = love.physics.newRectangleShape(p.width, p.height)
  obj.fix = love.physics.newFixture(obj.body, obj.shape, 2)

  obj.type = "Wolf"
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

function  WOLF:setId(id)
  w, h = self.imgSheet:getDimensions()

  local idx = 0
  local idy = 32

  self.id = id
  self.squade = love.graphics.newQuad(idx, idy, self.width, self.height, self.imgSheet:getDimensions())
end

function  WOLF:draw()
  local x, y = self.body:getWorldPoints(self.shape:getPoints())
  local r = self.body:getAngle()

  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.imgSheet, self.squade, x, y, r)
end


function  WOLF:findCloser(list)
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

function  WOLF:attack(pig)
  if self.state == 0 then
    local vx = pig.body:getX() - self.body:getX()
    local vy = pig.body:getY() - self.body:getY()
    local n = math.sqrt(vx * vx + vy * vy)

    if not power then power = 3000 end
    vx = vx / n
    vy = vy / n
    pig.body:applyLinearImpulse(vx * power, vy * power)
    pig.live = pig.live - 0.33

    self.state = 1
    self.atk = waitT
    screen:setShake(20)
    playFX('punch')
  end
end

function  WOLF:update(dt)
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
    self.time = 0.5

    r = math.random(0, 10)

    if r > 3 and self.closer then
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
    WOLF.imgSheet = img
    WOLF.shadowSheet = shadow
  end,

  newWolf = function(world, obj)
    obj = WOLF:new(world, obj)
    table.insert(WOLFS, obj)
    return obj
  end,

  foreach = function(f)
    t_c = {}
    for i, v in pairs(WOLFS) do
      table.insert(t_c, v)
    end
    for i, v in pairs(t_c) do
      f(v)
    end
  end,

  del = function(v)
    for idx, value in pairs(WOLFS) do
      if value == v then
        table.remove(WOLFS, idx)
        v.fix:destroy()
        return
      end
    end
  end,

  clear = function()
    while #WOLFS >= 1 do
      WOLFS[1].fix:destroy()
      table.remove(WOLFS, 1)
    end
  end,

  all = function()
    return ipair(WOLFS)
  end
}
