PIG = {}
PIGS = {}

function  PIG:new(world, pig)
  obj = {}
  setmetatable(obj, self)
  self.__index = self

  pig.width = 32
  pig.height = 32

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

  obj.panic = true

  obj.fix:setUserData(obj)
  return (obj)
end

function  PIG:Kick(v)

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
    idx = 32*6 + 32/2 + (64 * id)
    idy = 0 + 32/2
  else
    idx = 32*8 + 32/2 + (64 * (id - 2))
    idy = 0 + 32/2
  end

  self.id = id
  self.squade = love.graphics.newQuad(idx, idy, 32, 32, self.imgSheet:getDimensions())
end

function PIG:draw()

  -- local cx, cy = body:getWorldPoints(shape:getPoint())
  -- love.graphics.circle("line", cx, cy, shape:getRadius())

  local x, y = self.body:getWorldPoints(self.shape:getPoints())
  local r = self.body:getAngle()

  love.graphics.setColor(self.live, self.live, self.live)
  love.graphics.draw(self.imgSheet, self.squade, x, y, r)
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

  if self.panic == false then
    self.checkTime = self.checkTime - dt
    self.live = self.live - dt * 0.025

    --NEED TO FIND CLOSER
    if self.checkTime < 0 then
      self.weed, self.weedD = self:findCloser(Weed)
      self.checkTime = 0.5
    end
    --END

    --GO TO CLOSER
    if self.weed and self.weedD > 40 then
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
      if self.weed and self.weedD > 40 then
        self:setId(self.id)
      elseif self.weed then
        self:setId(self.id + 2)
      else
        self:setId(self.id)
      end
    end
  else
    local vx = 32 - math.random(64)
    local vy = 32 - math.random(64)
    local n = math.sqrt(vx * vx + vy * vy)
    vx = vx / n
    vy = vy / n

    self.body:applyLinearImpulse(vx*40, vy*40)
  end -- PANIC



  --DEATH
  if self.live < 0 then
    print("DEATH !!!")
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
  setImgSheet = function(img)
    PIG.imgSheet = img
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
