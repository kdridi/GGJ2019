PLAYER = {}
PLAYERS = {}

function  PLAYER:new(world, p)
  obj = {}
  setmetatable(obj, self)
  self.__index = self

  p.width = 32*4-42
  p.height = 32*4-50
  p.id = 0

  obj.body = love.physics.newBody(world, p.x + p.width / 2, p.y + p.height / 2, "dynamic")
  obj.body:setFixedRotation(true)
  obj.shape = love.physics.newRectangleShape(p.width, p.height)
  obj.fix = love.physics.newFixture(obj.body, obj.shape, 0.20)

  obj:setId(0)

  obj.type = "Player"
  obj.fix:setUserData(obj)

  obj.time = 0
  obj.state = 0

  obj.z = 1
  obj.zv = -1
  obj.rev = 1
  obj.pomme = 1
  obj.medecine = 1
  obj.mais = 1
  return (obj)
end

function  PLAYER:addPomme(nb)
  self.pomme = self.pomme + nb
end

function  PLAYER:addMedecine(nb)
  self.medecine = self.medecine + nb
end

function  PLAYER:addMais(nb)
  self.mais = self.mais + nb
end

function  PLAYER:findCloser(list)
  closer = nil
  dmin = 0

  list.foreach(function(v)
    if not closer then
      closer = v
      dmin = v:distanceFrom(player.body:getX(), player.body:getY())
    else
      d = v:distanceFrom(player.body:getX(), player.body:getY())
      if d < dmin then
        dmin = d
        closer = v
      end
    end --closer
  end)

  return closer, dmin
end

function  PLAYER:kick(pig, power)
  if self.state == 0 then
    local vx = pig.body:getX() - self.body:getX()
    local vy = pig.body:getY() - self.body:getY()
    local n = math.sqrt(vx * vx + vy * vy)

    if not power then power = 2000 end
    vx = vx / n
    vy = vy / n
    pig.body:applyLinearImpulse(vx * power, vy * power)

    self.state = 1
    self.time = 0.4
    self:setId(1)
    screen:setShake(20)
    playFX('punch')
  end
end

function  PLAYER:setId(id)
  local idx = 0
  local idy = 0
  self.id = id
  -- local idx = (self.id * 32) % w
  -- local idy = math.floor((self.id * 32) / w) * 32
  if id == 0 then idx = 64*0
  elseif id == 1 then idx = 64*4
  else idx = 64*2 end
  local idy = 32*8

  self.squade = love.graphics.newQuad(idx+18, idy+22, 32*4-22, 32*4-22, self.imgSheet:getDimensions())
end

function  PLAYER:draw()
  local x, y = self.body:getWorldPoints(self.shape:getPoints())
  local r = self.body:getAngle()

  love.graphics.setColor(1, 1, 1)

  if self.rev == 0 then
    love.graphics.draw(self.imgSheet, self.squade, x + (32*4-22), y - self.z * 8, 0, -1, 1)
  else
    love.graphics.draw(self.imgSheet, self.squade, x, y - self.z * 8)
  end

  if self.state == 1 then
    squadeH = love.graphics.newQuad(128*1, 128*3, 128, 128, self.imgSheet:getDimensions())
    squadeG = love.graphics.newQuad(128*2, 128*3, 128, 128, self.imgSheet:getDimensions())
    squadeB = love.graphics.newQuad(128*3, 128*3, 128, 128, self.imgSheet:getDimensions())
    squadeD = love.graphics.newQuad(128*4, 128*3, 128, 128, self.imgSheet:getDimensions())

    love.graphics.draw(self.imgSheet, squadeG, x - 80 - 20 * (self.time % 0.20) * (1 / 0.20), y - 20, r)
    love.graphics.draw(self.imgSheet, squadeD, x + 30 + 20 * (self.time % 0.20) * (1 / 0.20), y-20, r)
    love.graphics.draw(self.imgSheet, squadeH, x - 20, y - 80 - 20 * (self.time % 0.20) * (1 / 0.20), r)
    love.graphics.draw(self.imgSheet, squadeB, x - 20, y + 30 + 20 * (self.time % 0.20) * (1 / 0.20), r)

  end
end

function  PLAYER:drawShadow()
  local x, y = self.body:getWorldPoints(self.shape:getPoints())

  local v = 0.10 + 0.20 * (1 - self.z)
  love.graphics.setColor(v, v, v, v)
  love.graphics.draw(self.shadowSheet, self.squade, x, y)
end

function  PLAYER:update(dt)
  self.time = self.time - dt
  if self.state ~= 0 and self.time <= 0 then
    self.state = 0
    self:setId(0)
  else
    self.z = self.z + dt * self.zv

    --check
    if self.z < 0 then
      self.zv = self.zv * -1
      self.z = 0
    elseif self.z > 1 then
      self.zv = self.zv * -1
      self.z = 1
    end
  end

  local vx, vy = self.body:getLinearVelocity()
  if vx < 0 then
    self.rev = 1
  else
    self.rev = 0
  end
end

function PLAYER:plantedSeed()

  if self.state == 0 and self.pomme > 0 then
    weed = Weed.newWeed(world, {x=self.body:getX(), y=self.body:getY()})
    self.state = 2
    self.time = 0.3
    self:setId(2)
    self.pomme = self.pomme - 1
  end
end

--RETURN

return {
  setImgSheet = function(img, shadow)
    PLAYER.imgSheet = img
    PLAYER.shadowSheet = shadow
  end,

  newPlayer = function(world, x, y)
    obj = PLAYER:new(world, x,y)
    table.insert(PLAYERS, obj)
    return obj
  end,

  foreach = function(f)
    t_c = {}
    for i, v in pairs(PLAYERS) do
      table.insert(t_c, v)
    end
    for i, v in pairs(t_c) do
      f(v)
    end
  end,

  del = function(v)
    for idx, value in pairs(PLAYERS) do
      if value == v then
        table.remove(PLAYERS, idx)
        v.fix:destroy()
        return
      end
    end
  end,

  all = function()
    return ipair(PLAYERS)
  end

}
