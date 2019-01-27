PIG = {}
PIGS = {}

local foodD = 64 -- food distance
local foodAlert = 0.99
local density = 2

function  PIG:new(world, pig)
  obj = {}
  setmetatable(obj, self)
  self.__index = self

  pig.width = 32*2-9
  pig.height = 32*2-10

  obj.body = love.physics.newBody(world, pig.x + pig.width / 2, pig.y + pig.height / 2, "dynamic")
  --obj.body = love.physics.newBody(world, pig.x , pig.y , "dynamic")
  obj.shape = love.physics.newRectangleShape(pig.width, pig.height)
  --obj.shape = love.physics.newCircleShape(pig.width / 2)
  obj.fix = love.physics.newFixture(obj.body, obj.shape, 2)

  obj.id = 0
  obj:setId(obj.id)

  obj.time = 0.5
  obj.type = "Pig"

  obj.checkTime = -1
  obj.weed = nil
  obj.weedD = 0


  obj.live = 1
  obj.panic = false

  obj.z = 1
  obj.zv = -1

  obj.root = false
  obj.fix:setUserData(obj)
  return (obj)
end

function  PIG:enter(time)

  local vx = home.body:getX() - self.body:getX()
  local vy = home.body:getY() - self.body:getY()
  local n = math.sqrt(vx * vx + vy * vy)

  vx = vx / n
  vy = vy / n

  self.vx = vx
  self.vy = vy
  --self.body:getLinearVelocity(vx * 10, vy * 10)
  self.time = time
  self.live = 1.
  self.state = 42
  self.fix:setSensor(true)
  self.body:setLinearVelocity(self.vx * 500, self.vy * 500)
  self:setId(42)
end

function  PIG:setRoot(r)
  self.root = r
  if self.root == true then
    self.fix:setDensity(density * 10000)
  else
    self.fix:setDensity(density)
  end
  self.body:resetMassData()
end

function  PIG:distanceFrom(x, y)
  local vx = x - self.body:getX()
  local vy = y - self.body:getY()

  local d = math.sqrt((vx * vx) + (vy * vy))
  return d
end

function  PIG:setId(id)
  w, h = self.imgSheet:getDimensions()
  local idx = 0
  local idy = 0

  if id == 0 or id == 1 then
    idx = 64*2*3 + 32 + (64*2 * id)
    idy = 0 + 32
  elseif id == 2 or id == 3 then
    idx = 64*2*4 + 32 + (64*2 * (id - 2))
    idy = 0 + 32
  elseif id == 4 then
    idx = 128*5 + 32
    idy = 128 + 32
  elseif id == 42  then
    idx = 64*2*3 + 32
    idy = 0 + 32
  end
  -- idx = 32*4*3 + 32
  -- idy = 0 + 32
  self.id = id
  self.squade = love.graphics.newQuad(idx, idy+3, 64*2-32, 64*2-32, self.imgSheet:getDimensions())
end

function PIG:draw()

  local x, y = self.body:getWorldPoints(self.shape:getPoints())
  local r = self.body:getAngle()


  if self.root == true then
    love.graphics.setColor(1, 0.2, math.cos(self.z*2), self.live)
  else
    love.graphics.setColor(self.live, self.live, self.live)
  end

  if self.state ~= 42 then
    love.graphics.draw(self.imgSheet, self.squade, x, y - 4 * self.z, r)

    self:drawEtat()
  end
end

function PIG:drawFinal()
  if self.state == 42 then

    local x, y = self.body:getWorldPoints(self.shape:getPoints())
    local r = self.body:getAngle()
    local r = self.body:getAngle()

    effect:send("time", (1 - self.live))
    effect:send("tt", noiseImg)
    love.graphics.setColor(1, self.live, self.live, 1)
    love.graphics.setShader(effect)
    love.graphics.draw(self.imgSheet, self.squade, x, y - 4 * self.z, r)
    love.graphics.setShader()
  end
end

function PIG:drawEtat()

  if self.live < foodAlert or self.panic == true or self.root == true then
    local tx = camera.x - love.graphics.getWidth() / 2
    local ty = camera.y - love.graphics.getHeight() / 2
    local x = self.body:getX()
    local y = self.body:getY()
    local img = fDown

    rx = x - tx
    ry = y - ty

    local z = math.sin(self.z*2)*15

    if self.panic then
      love.graphics.setColor(0.5 * math.sin(self.z*2), math.cos(self.z*2), math.sin(self.z*7), 1)
    elseif self.root == true then
      love.graphics.setColor(0.2, 1, math.cos(self.z), 1)
    elseif self.live < foodAlert then
      love.graphics.setColor(1, math.cos(self.z), 0.2, 1) end
    if rx < 0 or rx > love.graphics.getWidth() or
       ry < 0 or ry > love.graphics.getHeight() then
        if (rx <= 0) then rx = 0 img = fLeft end
        if (ry <= 0) then ry = 0 img = fUp end
        if (ry >= love.graphics.getHeight()) then ry = love.graphics.getHeight() - 80 img = fDown end
        if (rx >= love.graphics.getWidth()) then rx = love.graphics.getWidth() - 80 img = fRight end
        love.graphics.draw(img, rx + tx, ry + ty, 0, 1, 1)
       else
         love.graphics.draw(img, x - 37, y - (70 + z), 0, 1, 1)
    end

  end
end

function PIG:setPanic(panic)
  self.panic = panic
  if self.panic then
    self:setId(4)
  end
end

function PIG:drawShadow()

  if self.state ~= 42 then
    local x, y = self.body:getWorldPoints(self.shape:getPoints())
    local r = self.body:getAngle()

    local v = 0.10 + 0.20 * (1 - self.z)
    love.graphics.setColor(v, v, v, v)

    love.graphics.draw(self.shadowSheet, self.squade, self.body:getX()-32/2, self.body:getY() - 20)
  end
end

function  PIG:findCloser(list)
  closer = nil
  dmin = 0

  list.foreach(function(v)
    if not closer and v.state == 2 then
      closer = v
      dmin = v:distanceFrom(self.body:getX(), self.body:getY())
    elseif v.state == 2 then
      d = v:distanceFrom(self.body:getX(), self.body:getY())
      if d < dmin then
        dmin = d
        closer = v
      end
    end --closer
  end)

  return closer, dmin
end


function PIG:update(dt)
  self.time = self.time - dt

  if self.panic == false and self.root == false and self.state ~= 42 then
    self.checkTime = self.checkTime - dt
    self.live = self.live - dt * 0.025

    --NEED TO FIND CLOSER
    if self.checkTime < 0 then
      self.weed, self.weedD = self:findCloser(Weed)
      self.checkTime = 0.5
    end
    --END

    --GO TO CLOSER
    if self.weed and self.weedD > foodD then
      local vx = self.weed.body:getX() - self.body:getX() + (32 - math.random(64))
      local vy = self.weed.body:getY() - self.body:getY() + (32 - math.random(64))
      local n = math.sqrt(vx * vx + vy * vy)

      vx = vx / n
      vy = vy / n

      self.body:applyLinearImpulse(vx*4, vy*4)
    elseif self.weed then
      self.weed.live = self.weed.live - dt * 0.05
      self.live = self.live + dt * 0.3
      if self.live > 1 then self.live = 1 end
    end
    --END

    if self.time < 0 then
      self.id = (self.id + 1) % 2
      self.time = 0.2 + math.rad(1)
      if self.weed and self.weedD > foodD then
        self:setId(self.id)
      elseif self.weed then
        self:setId(self.id + 2)
      else
        self:setId(self.id)
      end
    end
  elseif self.time < 0 and self.root == false and self.state ~= 42 then

    self.time = 0.1
    local vx = 32 - math.random(64)
    local vy = 32 - math.random(64)
    local n = math.sqrt(vx * vx + vy * vy)
    vx = vx / n
    vy = vy / n

    self.body:applyLinearImpulse(vx*100, vy*100)
  end -- PANIC

  self.z = self.z + dt * self.zv * 1.2

  --check
  if self.z < 0 then
    self.zv = self.zv * -1
    self.z = 0
  elseif self.z > 1 then
    self.zv = self.zv * -1
    self.z = 1
  end

  if self.root == true then --IF ROOT
    self.live = self.live - dt * 0.020
  end

  if self.state == 42 then -- IF ENTER THE HOUSE
    self.live = self.live - dt * 0.4
    if self.time < 0 then
      self.time = 0.1
      self.body:setLinearVelocity(self.vx * 500, self.vy * 500)
    end
  end
  --DEATH
  if self.live < 0 then
    for idx, value in pairs(PIGS) do
      if value == self then
        value.fix:destroy()
        table.remove(PIGS, idx)
        return
      end
    end--FOR
  end--IF

end

--RETURN
return {
  setImgSheet = function(img, shadow)
    PIG.imgSheet = img
    PIG.shadowSheet = shadow
  end,

  newPig = function(world, x, y)
    obj = PIG:new(world, x,y)
    table.insert(PIGS, obj)
    return obj
  end,

  foreach = function(f)
    t_c = {}
    for i, v in pairs(PIGS) do
      table.insert(t_c, v)
    end
    for i, v in pairs(t_c) do
      f(v)
    end
  end,

  count = function()
    return #PIGS
    -- local n = 0
    -- for idx, value in pairs(PIGS) do
    --   n = n + 1
    -- end
    -- return n
  end,

  del = function(v)
    for idx, value in pairs(PIGS) do
      if value == v then
        table.remove(PIGS, idx)
        v.fix:destroy()
        return
      end
    end
  end,

  all = function()
    return ipair(PIGS)
  end,

  clear = function()
    while #PIGS >= 1 do
      PIGS[1].fix:destroy()
      table.remove(PIGS, 1)
    end
  end,

  deploy = function(nb)
    tab = {}

    Weed.foreach(function(v)
      if v.state >= 2 then
        d = v:distanceFrom(home.body:getX(), home.body:getY())
        table.insert(tab, {obj=v, d=d})
      end
    end)

    if #tab <= 0 then return false end

    table.sort(tab, function (k1, k2) return k1.d < k2.d end)

    local a = 1
    for i=1,nb do
      Pig.newPig(world, {x=tab[a].obj.body:getX() + math.random(-5, 5),
                         y=tab[a].obj.body:getY() + math.random(-5, 5), id=0})
      a = a + 1
      if a > #tab then a = 1 end
    end
    return true
  end
}
