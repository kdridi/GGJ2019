uniform float	time = 0;
uniform Image tt;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    vec2 pos = texture_coords;
    vec4 pixel = Texel(texture, texture_coords);
    vec4 p = Texel(tt, texture_coords);

    //return vec4(p.x, 0, 0, 1);

    float fto = p.y;

    if (time > fto)
      return vec4(pixel.xyz, 0);
    else
      return pixel*color;
}
