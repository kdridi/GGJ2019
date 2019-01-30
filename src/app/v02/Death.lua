DEATH = {}
DEATHS = {}

function  DEATH:new(world, p)
  obj = {}
  setmetatable(obj, self)
  self.__index = self


  p.width = 128
  p.height = 128


  obj.x = p.x
  obj.y = p.y
  obj.width = p.width
  obj.height = p.height

  --ID
    w, h = self.imgSheet:getDimensions()

    local idx = 128
    local idy = 32

    self.id = id
    self.squade = love.graphics.newQuad(idx, idy, obj.width, obj.height, self.imgSheet:getDimensions())
  --END

  return (obj)
end


function  DEATH:draw()
  local x, y = self.x, self.y

  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.imgSheet, self.squade, x, y)
end


--RETURN

return {
  setImgSheet = function(img, shadow)
    DEATH.imgSheet = img
    DEATH.shadowSheet = shadow
  end,

  newDeath = function(world, obj)
    obj = DEATH:new(world, obj)
    table.insert(DEATHS, obj)
    return obj
  end,

  foreach = function(f)
    t_c = {}
    for i, v in pairs(DEATHS) do
      table.insert(t_c, v)
    end
    for i, v in pairs(t_c) do
      f(v)
    end
  end,

  del = function(v)
    for idx, value in pairs(DEATHS) do
      if value == v then
        table.remove(DEATHS, idx)
        v.fix:destroy()
        return
      end
    end
  end,

  clear = function()
    while #DEATHS >= 1 do
      DEATHS[1].fix:destroy()
      table.remove(DEATHS, 1)
    end
  end,

  all = function()
    return ipair(DEATHS)
  end
}
