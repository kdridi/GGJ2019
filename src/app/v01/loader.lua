
Map = {}
Loader = {}

------------------------
---       NEW      -----
------------------------
function  Map:new(data)
  obj = {}
  setmetatable(obj, self)
  self.__index = self
  obj.map = data
  obj.width = obj.map.tilewidth * obj.map.width
  obj.height = obj.map.height * obj.map.tileheight
  return (obj)
end


function Map:isCollidable(id)
  for k, v in ipairs(self.phx.idB) do
    if id == v then
      return true
    end
  end
  return false
end

------------------------
---     PHISIC     -----
------------------------

function Map:initPhx(world)
  self.phx = {}
  self.phx.world = world
  self.phx.fix = {}
  self.phx.idB = {}

  for i = 1, #(self.map.tilesets[1]).tiles do
    local v = (self.map.tilesets[1]).tiles[i]

    if v.properties.collidable == true then
      table.insert(self.phx.idB, v.id)
    end
  end


  for ia = 1, #(self.map.layers) do
    local layer = (self.map.layers)
    local x = 0
    local y = 0
    print(layer[ia].name)

    if layer[ia].type == 'tilelayer' then
      for ib = 1, #layer[ia].data do
        local id = layer[ia].data[ib] - 1

        if self:isCollidable(id) == true then
          body = love.physics.newBody(world, x + 16, y + 16)
          shape = love.physics.newRectangleShape(32, 32)
          table.insert(self.phx.fix, love.physics.newFixture(body, shape))
        end

        x = x + 32
        if x >= self.width then
          y = y + 32
          x = 0
        end
      end
    elseif layer[ia].type == 'objectgroup' then
      for ib = 1, #layer[ia].objects do
        local obj = layer[ia].objects[ib]

        body = love.physics.newBody(world, obj.x + obj.width / 2, obj.y + obj.height / 2)
        shape = love.physics.newRectangleShape(obj.width, obj.height)
        table.insert(self.phx.fix, love.physics.newFixture(body, shape))
        print(obj.x)
      end
    end -- IF
  end
end


------------------------
---     GRAPH      -----
------------------------


function  Map:draw(idx)
  if not idx then
    idx = 1
  end
  love.graphics.setColor(255, 255, 255, 255)
  --love.graphics.setBlendMode("alpha", "premultiplied")
  love.graphics.draw(self.canvas[idx])
  --  love.graphics.draw(self.imgSheet)

  love.graphics.print("toto", 250, 250)
end


function Map:initGf()

  self.canvas = love.graphics.newCanvas(self.width, self.height)
  self.imgSheet = love.graphics.newImage(self.map.tilesets[1].image)

  self.canvas = {}
  self.canvas[0] = {}

  local c_i = 1
  --love.graphics.setCanvas(self.canvas[0])
  --BEGIN DRAW
    love.graphics.setColor(1, 1, 1, 1)
    for ia = 1, #(self.map.layers) do
      local layer = (self.map.layers)
      local x = 0
      local y = 0
      local w = self.map.tilesets[1].imagewidth

      if layer[ia].type == 'tilelayer' then
        self.canvas[c_i] = love.graphics.newCanvas(self.width, self.height)
        love.graphics.setCanvas(self.canvas[c_i])

        c_i = c_i + 1
        for ib = 1, #layer[ia].data do
          local id = layer[ia].data[ib]

          if id > 0 then
            id = id - 1
            local idx = (id * 32) % w
            local idy = math.floor((id * 32) / w) * 32
            local squade = love.graphics.newQuad(idx, idy, 32, 32, self.imgSheet:getDimensions())

            love.graphics.draw(self.imgSheet, squade, x, y)
          end
          x = x + 32
          if x >= self.width then
            y = y + 32
            x = 0
          end
        end
      end --IF
    end
  --END DRAW
  love.graphics.setCanvas()

end

function Map:updateGraph()

end

function Loader:loadFromLua(data)

  obj = Map:new(data)
  obj:initGf()
  --obj:updateGraph()
  --obj.map = map

  return obj
end

return {
  loadFromLua = function(data)
    obj = Map:new(data)
    obj:initGf()

    return obj
  end
}
