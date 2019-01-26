PIG = {}
PIGS = {}

function  PIG:new(pig)
  obj = {}
  setmetatable(obj, self)
  self.__index = self

  pig.width = 32
  pig.height = 32

  obj.body = love.physics.newBody(world, pig.x + pig.width / 2, pig.y + pig.height / 2, "dynamic")
  obj.shape = love.physics.newRectangleShape(pig.width, pig.height)
  obj.fix = love.physics.newFixture(obj.body, obj.shape, 2)

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
  -- local idx = (self.id * 32) % w
  -- local idy = math.floor((self.id * 32) / w) * 32
  local idx = 64 + 32/2
  local idy = 0 + 32/2

  self.id = id
  self.squade = love.graphics.newQuad(idx, idy, 32, 32, self.imgSheet:getDimensions())
end

function  PIG:draw()
  local x, y = self.body:getWorldPoints(self.shape:getPoints())
  local r = self.body:getAngle()
  love.graphics.draw(self.imgSheet, self.squade, x, y, r)
end

--RETURN
return {
  setImgSheet = function(img)
    PIG.imgSheet = img
  end,

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
      d = v:distanceFrom(home.body:getX(), home.body:getY())
      table.insert(tab, {obj=pig, d=d})
    end)

    table.sort(tab, function (k1, k2) return k1.d < k2.d end)

    print(#tab)
    print("BEGIN")
    for i=1,#tab do
      print(tab[i].d)
    end
    print("END")

    -- for i=1,nb do
    --   Pig.newPig({x=tab.obj.body:getX(), y=tab.obj.body:getY()})
    -- end
  end
}
