TRAP = {}
TRAPS = {}

function  TRAP:new(world, trap)
  obj = {}
  setmetatable(obj, self)
  self.__index = self

 trap.width = 32
 trap.height = 32

  obj.body = love.physics.newBody(world, trap.x + trap.width / 2, trap.y + trap.height / 2, "dynamic")
  obj.shape = love.physics.newRectangleShape trap.width, trap.height)
  obj.fix = love.physics.newFixture(obj.body, obj.shape, 2)
  obj.fix.setSensor(true)

  obj.type = "Trap"
  obj.fix:setUserData(obj)
  return (obj)
end

function  TRAP:setId(id)
  w, h = self.imgSheet:getDimensions()
  local idx = 0
  local idy = 0

  idx = 32*8 + 32/2 + (64 * (id - 2))
  idy = 0 + 32/2

  self.id = id
  self.squade = love.graphics.newQuad(idx, idy, 32, 32, self.imgSheet:getDimensions())
end

function TRAP:draw()

  local x, y = self.body:getWorldPoints(self.shape:getPoints())
  local r = self.body:getAngle()

  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(self.imgSheet, self.squade, x, y, r)
end

--RETURN

return {
  setImgSheet = function(img)
    TRAP.imgSheet = img
  end,

  newTrap = function(world, x, y)
    obj = TRAP:new(world, x,y)
    table.insert(TRAPS, obj)
    return obj
  end,

  foreach = function(f)
    t_c = {}
    for i, v in pairs(TRAPS) do
      table.insert(t_c, v)
    end
    for i, v in pairs(t_c) do
      f(v)
    end
  end,

  del = function(v)
    for idx, value in pairs(TRAPS) do
      if value == v then
        table.remove(TRAPS, idx)
        v.fix:destroy()
        return
      end
    end
  end,

  clear = function()
    while #TRAPS >= 1 do
      TRAPS[1].fix:destroy()
      table.remove(WEEDS, 1)
    end
  end,

  all = function()
    return ipair(TRAPS)
  end
}
