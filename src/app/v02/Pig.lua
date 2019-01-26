PIG = {}
PIGS = {}

function  PIG:new(pig)
  obj = {}
  setmetatable(obj, self)
  self.__index = self

  obj.body = love.physics.newBody(world, pig.x + pig.width / 2, pig.y + pig.height / 2, "dynamic")
  obj.shape = love.physics.newRectangleShape(pig.width, pig.height)
  obj.fix = love.physics.newFixture(obj.body, obj.shape, 20)

  obj.type = "Pig"
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
--RETURN
return {
  newPig = function(x, y)
    obj = PIG:new(x,y)
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
  end
}
