BONUS = {}
BONUSS = {}

function  BONUS:new(p, img)
  obj = {}
  setmetatable(obj, self)
  self.__index = self

  obj.img = img
  obj.body = love.physics.newBody(world, p.x + p.width / 2, p.y + p.height / 2, "dynamic")
  obj.body:setFixedRotation(true)
  obj.shape = love.physics.newRectangleShape(p.width, p.height)
  obj.fix = love.physics.newFixture(obj.body, obj.shape)

  obj.fix:setUserData(obj)

  return (obj)
end

function  BONUS:draw()
  local x, y = self.body:getWorldPoints(self.shape:getPoints())

  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.img, x, y)
end


--RETURN
return {
  newBonus = function(obj,img)
    bonus = BONUS:new(obj, img)
    table.insert(BONUSS, bonus)
    return bonus
  end,

  foreach = function(f)
    t_c = {}
    for i, v in pairs(BONUSS) do
      table.insert(t_c, v)
    end
    for i, v in pairs(t_c) do
      f(v)
    end
  end,

  del = function(v)
    for idx, value in pairs(BONUSS) do
      if value == v then
        table.remove(BONUSS, idx)
        v.fix:destroy()
        return
      end
    end
  end,

  clear = function()
    while #BONUSS >= 1 do
      BONUSS[1].fix:destroy()
      table.remove(BONUSS, 1)
    end
  end,

  all = function()
    return ipair(BONUSS)
  end
}
