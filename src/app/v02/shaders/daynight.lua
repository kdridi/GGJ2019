local shader = love.graphics.newShader[[
    extern vec2 resolution;
    extern vec2 position;
    extern number delay;
    extern number speed;
    extern number time;
    
    vec4 effect(vec4 color, Image tex, vec2 tc, vec2 _)
    {
      vec2 uv = tc.xy * resolution.xy;
      float dis = length(uv - position);
      vec4 c = Texel(tex, tc);
      
      float radius = max(resolution.x, resolution.y) / 1.5;
      if (time > delay)
        radius -= (time - delay) * speed;
        
      if (radius < 32)
        radius = 32;
      
      float intensity = clamp(radius / dis, 0.0, 1.0);
      return color * c * vec4(vec3(intensity * intensity), 1.0);
    }
  ]]
  
  return moonshine.Effect{
  -- ---------------------------------------------------------------------------
  -- NAME
  -- ---------------------------------------------------------------------------
  name = "daynight",
  
  -- ---------------------------------------------------------------------------
  -- SHADER
  -- ---------------------------------------------------------------------------
  shader = shader,
  
  -- ---------------------------------------------------------------------------
  -- SETTERS
  -- ---------------------------------------------------------------------------
  setters = {
    resolution = function(v)
      if type(v) == "number" then v = {v,v} end
      assert(type(v) == "table" and #v == 2, "Invalid value for `resolution'")
      shader:send("resolution", v)
    end,
    
    position = function(v)
      if type(v) == "number" then v = {v,v} end
      assert(type(v) == "table" and #v == 2, "Invalid value for `position'")
      shader:send("position", v)
    end,
    
    time = function(v)
      shader:send("time", tonumber(v))
    end,
    
    delay = function(v)
      shader:send("delay", tonumber(v))
    end,
    
    speed = function(v)
      shader:send("speed", tonumber(v))
    end
  },
  
  -- ---------------------------------------------------------------------------
  -- DEFAULTS
  -- ---------------------------------------------------------------------------
  defaults = {
    resolution = { love.graphics.getWidth(), love.graphics.getHeight() },
    position = { 100, 100 },
    time = 0.0,
    delay = 40.0,
    speed = 10.0,
  }
}