
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

function Map:initObj(world)
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

    if layer[ia].type == 'tilelayer' then
      for ib = 1, #layer[ia].data do
        local id = layer[ia].data[ib] - 1

        if self:isCollidable(id) == true then
          body = love.physics.newBody(world, x + 16, y + 16)
          shape = love.physics.newRectangleShape(64, 64)
          table.insert(self.phx.fix, love.physics.newFixture(body, shape))
        end

        x = x + 64
        if x >= self.width then
          y = y + 64
          x = 0
        end
      end
    elseif layer[ia].type == 'objectgroup' then
      for ib = 1, #layer[ia].objects do
        local obj = layer[ia].objects[ib]

        if self.objCreateF then --IF CALLBACK
          self.objCreateF(obj)
        else --DEFAULT
          if obj.properties.Pig == true then
            body = love.physics.newBody(world, obj.x + obj.width / 2, obj.y + obj.height / 2, "dynamic")
          else
            body = love.physics.newBody(world, obj.x + obj.width / 2, obj.y + obj.height / 2)
          end
          shape = love.physics.newRectangleShape(obj.width, obj.height)
          table.insert(self.phx.fix, love.physics.newFixture(body, shape, 1))
        end -- IF callback
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

end


function Map:initGf()

  self.canvas = love.graphics.newCanvas(self.width, self.height)
  self.sheet = {}
  max = 0

  --GET IMAGE
  for i=1,#self.map.tilesets do
    print("IMAGE")
    self.sheet[i] = {}
    self.sheet[i].img = love.graphics.newImage(self.map.tilesets[i].image)
    local w, h = self.sheet[i].img:getDimensions()
    max = max + math.floor((w / 64) * (h / 64))
    self.sheet[i].idmax = max
  end
  --END

  self.canvas = {}
  self.canvas[0] = {}

  local c_i = 1
  --BEGIN DRAW
    love.graphics.setColor(1, 1, 1, 1)
    for ia = 1, #(self.map.layers) do
      local layer = (self.map.layers)
      local x = 0
      local y = 0

      if layer[ia].type == 'tilelayer' then
        self.canvas[c_i] = love.graphics.newCanvas(self.width, self.height)
        love.graphics.setCanvas(self.canvas[c_i])

        c_i = c_i + 1
        for ib = 1, #layer[ia].data do
          local id = layer[ia].data[ib]

          if id > 0 then
            id = id - 1

            local max = 0
            local i = 1
            while id > self.sheet[i].idmax do
              max = self.sheet[i].idmax
              i = i + 1
              print(i)
            end
            id = id - max
            local w, h = self.sheet[i].img:getDimensions()
            local idx = (id * 64) % w
            local idy = math.floor((id * 64) / w) * 64
            local squade = love.graphics.newQuad(idx, idy, 64, 64, self.sheet[i].img:getDimensions())

            love.graphics.draw(self.sheet[i].img, squade, x, y)
          end
          x = x + 64
          if x >= self.width then
            y = y + 64
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
  --obj:initGf()
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
