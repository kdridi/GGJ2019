PLAYER = {}
PLAYERS = {}

function  PLAYER:new(p)
  obj = {}
  setmetatable(obj, self)
  self.__index = self

  obj.body = love.physics.newBody(world, p.x + p.width / 2, p.y + p.height / 2, "dynamic")
  obj.body:setFixedRotation(true)
  obj.shape = love.physics.newRectangleShape(p.width, p.height)
  obj.fix = love.physics.newFixture(obj.body, obj.shape, 1)

  obj:setId(p.gid)

  obj.type = "Player"
  obj.fix:setUserData(obj)
  return (obj)
end

function  PLAYER:setId(id)
  w, h = self.imgSheet:getDimensions()
  self.id = id - 1
  local idx = (self.id * 32) % w
  local idy = math.floor((self.id * 32) / w) * 32

  self.id = id
  self.squade = love.graphics.newQuad(idx, idy, 32, 32, self.imgSheet:getDimensions())
end

function  PLAYER:draw()
  local x, y = self.body:getWorldPoints(self.shape:getPoints())
  local r = self.body:getAngle()
  love.graphics.draw(self.imgSheet, self.squade, x, y, r)
end

--RETURN

return {
  setImgSheet = function(img)
    PLAYER.imgSheet = img
  end,

  newPlayer = function(x, y)
    obj = PLAYER:new(x,y)
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
