PIG = {}
PIGS = {}

function  PIG:new(world, pig)
  obj = {}
  setmetatable(obj, self)
  self.__index = self

  obj.body = love.physics.newBody(world, pig.x + pig.width / 2, pig.y + pig.height / 2, "dynamic")
  obj.shape = love.physics.newRectangleShape(pig.width, pig.height)
  obj.fix = love.physics.newFixture(obj.body, obj.shape, 20)

  print("OBJ : "..pig.gid)
  obj:setId(pig.gid)

  obj.type = "Pig"
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
  self.id = id - 1
  local idx = (self.id * 32) % w
  local idy = math.floor((self.id * 32) / w) * 32

  self.id = id
  self.squade = love.graphics.newQuad(idx, idy, 32, 32, self.imgSheet:getDimensions())
end

function PIG:draw()
  local x, y = self.body:getWorldPoints(self.shape:getPoints())
  local r = self.body:getAngle()
  love.graphics.draw(self.imgSheet, self.squade, x, y, r)
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
  end
}
