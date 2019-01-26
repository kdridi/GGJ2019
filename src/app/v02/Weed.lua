WEED = {}
WEEDS = {}

function  WEED:new(p)
  obj = {}
  setmetatable(obj, self)
  self.__index = self

  p.height = 120
  p.width = 120
  p.id = 0

  obj.body = love.physics.newBody(world, p.x + p.width / 2, p.y + p.height / 2, "dynamic")
  obj.body:setFixedRotation(true)
  obj.shape = love.physics.newRectangleShape(p.width, p.height)
  obj.fix = love.physics.newFixture(obj.body, obj.shape, 0.10)

  obj:setId(p.id)

  obj.type = "Player"
  obj.fix:setUserData(obj)
  return (obj)
end

function  WEED:setId(id)
  w, h = self.imgSheet:getDimensions()
  self.id = id - 1
  -- local idx = (self.id * 32) % w
  -- local idy = math.floor((self.id * 32) / w) * 32
  local idx = 0
  local idy = 0

  self.id = id
  self.squade = love.graphics.newQuad(idx, idy, 120, 120, self.imgSheet:getDimensions())
end

function  WEED:draw()
  local x, y = self.body:getWorldPoints(self.shape:getPoints())
  local r = self.body:getAngle()
  love.graphics.draw(self.imgSheet, self.squade, x, y, r)
end

--RETURN

return {
  setImgSheet = function(img)
    WEED.imgSheet = img
  end,

  newPlayer = function(x, y)
    obj = WEED:new(x,y)
    table.insert(WEEDS, obj)
    return obj
  end,

  foreach = function(f)
    t_c = {}
    for i, v in pairs(WEEDS) do
      table.insert(t_c, v)
    end
    for i, v in pairs(t_c) do
      f(v)
    end
  end,

  del = function(v)
    for idx, value in pairs(WEEDS) do
      if value == v then
        table.remove(WEEDS, idx)
        v.fix:destroy()
        return
      end
    end
  end,

  all = function()
    return ipair(WEEDS)
  end

}
