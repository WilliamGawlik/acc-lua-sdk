local vtmp1
local colors = {}

return {
  init = function()
    vtmp1 = rgbm()
    colors.transparent = rgbm(0, 0, 0, 0)
    colors.black = rgbm(0, 0, 0, 1)
    colors.silver = rgbm(0.75, 0.75, 0.75, 1)
    colors.gray = rgbm(0.5, 0.5, 0.5, 1)
    colors.white = rgbm(1, 1, 1, 1)
    colors.maroon = rgbm(0.5, 0, 0, 1)
    colors.red = rgbm(1, 0, 0, 1)
    colors.purple = rgbm(0.5, 0, 0.5, 1)
    colors.fuchsia = rgbm(1, 0, 1, 1)
    colors.green = rgbm(0, 0.5, 0, 1)
    colors.lime = rgbm(0, 1, 0, 1)
    colors.olive = rgbm(0.5, 0.5, 0, 1)
    colors.yellow = rgbm(1, 1, 0, 1)
    colors.orange = rgbm(1, 0.5, 0, 1)
    colors.navy = rgbm(0, 0, 0.5, 1)
    colors.blue = rgbm(0, 0, 1, 1)
    colors.teal = rgbm(0, 0.5, 0.5, 1)
    colors.cyan = rgbm(0, 0.5, 1, 1)
    colors.aqua = rgbm(0, 1, 1, 1)
  end,
  type = {
    __call = function(_, r, g, b, mult)
      return setmetatable({ r = r or 0, g = g or 0, b = b or 0, mult = mult or 0 }, rgbm)
    end,

    __tostring = function(v)
      return string.format('(rgb=(%f, %f, %f), mult=%f)', v.rgb.r, v.rgb.g, v.rgb.b, v.mult)
    end,

    __add = function(v, u) if type(v) == 'number' then return rgbm(v, v, v, v):add(u, rgbm()) end return v:add(u, rgbm()) end,
    __sub = function(v, u) if type(v) == 'number' then return rgbm(v, v, v, v):sub(u, rgbm()) end return v:sub(u, rgbm()) end,
    __mul = function(v, u)
      if type(v) == 'number' then return rgbm(v, v, v, v) * u end 
      if rgbm.isrgbm(u) then return v:mul(u, rgbm())
      elseif type(u) == 'number' then return v:scale(u, rgbm())
      else error('rgbms can only be multiplied by rgbms and numbers', 2) end
    end,
    __div = function(v, u)
      if type(v) == 'number' then return rgbm(v, v, v, v) / u end 
      if rgbm.isrgbm(u) then return v:div(u, rgbm())
      elseif type(u) == 'number' then return v:scale(1 / u, rgbm())
      else error('rgbms can only be divided by rgbms and numbers', 2) end
    end,
    __pow = function(v, u)
      if type(v) == 'number' then return rgbm(v, v, v) ^ u end 
      if rgbm.isrgbm(u) then return v:pow(u, rgbm())
      elseif type(u) == 'number' then return rgbm(v.r ^ u, v.g ^ u, v.b ^ u, v.mult ^ u)
      else error('rgbms can only be raised to power of rgbms and numbers', 2) end
    end,
    __unm = function(v) return v * -1 end,
    __len = function(v) return v:value() end,
    __eq = function(v, o) if rawequal(o, nil) or rawequal(v, nil) then return rawequal(v, o) end return ffi.istype('rgbm', v) and ffi.istype('rgbm', o) and v.rgb == o.rgb and v.mult == o.mult end,
    __lt = function(v, o) return v:value() < o:value() end,
    __le = function(v, o) return v:value() <= o:value() end,
    __index = {
      new = function(r, g, b, m) 
        if rgbm.isrgbm(r) then return r:clone() end
        if rgb.isrgb(r) then return rgbm(r.r, r.g, r.b, g or 1) end
        if hsv.ishsv(r) then return rgbm(r:rgb(), 1) end
        if vec4.isvec4(r) then return rgbm(r.x, r.y, r.z, r.w) end
        if vec3.isvec3(r) then return rgbm(r.x, r.y, r.z, 1) end
        if type(r) ~= 'number' then 
          if type(r) == 'table' then
            return rgbm(tonumber(r[1]) or 0, tonumber(r[2]) or 0, tonumber(r[3]) or 0, tonumber(r[4]) or 0)
          end
          if type(r) == 'string' then
            return ffi.C.lj_rgbm_from_string(r)
          end
          return rgbm(0, 0, 0, 1) 
        end
        if type(g) ~= 'number' then return rgbm(r, r, r, 1) end
        if type(b) ~= 'number' then return rgbm(r, r, r, g) end
        return rgbm(r, g, b, __util.num_or(m, 1))
      end,

      from0255 = function(r, g, b, a) 
        if type(r) ~= 'number' then r = 0 end
        if type(g) ~= 'number' then g = r end
        if type(b) ~= 'number' then b = g end
        return rgbm(r / 255, g / 255, b / 255, __util.num_or(a, 1))
      end,

      colors = colors,
      isrgbm = function(r) return ffi.istype('rgbm', r) end,
      tmp = function() return vtmp1 end,
      type = function(x) return rgbm end,
      clone = function(v) return rgbm(v.r, v.g, v.b, v.mult) end,
      unpack = function(v) return v.rgb, v.mult end,
      table = function(v) return {v.rgb.r, v.rgb.g, v.rgb.b, v.mult} end,

      set = function(v, rgb, mult)
        if rgbm.isrgbm(rgb) then rgb, mult = rgb.rgb, rgb.mult end
        v.rgb = rgb
        v.mult = mult
        return v
      end,

      setLerp = function(v, a, b, k)
        v.r = math.lerp(a.r, b.r, k)
        v.g = math.lerp(a.g, b.g, k)
        v.b = math.lerp(a.b, b.b, k)
        v.mult = math.lerp(a.mult, b.mult, k)
        return v
      end,

      add = function(v, u, out)
        out = out or v
        if rgbm.isrgbm(u) then 
          out.rgb = v.rgb + u.rgb
          out.mult = v.mult + u.mult
        else
          out.rgb = v.rgb + u
          out.mult = v.mult + u
        end
        return out
      end,

      addScaled = function(v, u, s, out)
        out = out or v
        out.rgb:addScaled(u.rgb, s)
        out.mult = v.mult + u.mult * s
        return out
      end,

      sub = function(v, u, out)
        out = out or v
        if rgbm.isrgbm(u) then 
          out.rgb = v.rgb - u.rgb
          out.mult = v.mult - u.mult
        else
          out.rgb = v.rgb - u
          out.mult = v.mult - u
        end
        return out
      end,

      mul = function(v, u, out)
        out = out or v
        out.rgb = v.rgb * u.rgb
        out.mult = v.mult * u.mult
        return out
      end,

      div = function(v, u, out)
        out = out or v
        out.rgb = v.rgb / u.rgb
        out.mult = v.mult / u.mult
        return out
      end,

      pow = function(v, u, out)
        out = out or v
        if type(u) == 'number' then
          out.r = v.r ^ u
          out.g = v.g ^ u
          out.b = v.b ^ u
          out.mult = v.mult ^ u
        else
          out.r = v.r ^ u.r
          out.g = v.g ^ u.g
          out.b = v.b ^ u.b
          out.mult = v.mult ^ u.mult
        end
        return out
      end,

      scale = function(v, s, out)
        out = out or v
        out.rgb = v.rgb * s
        out.mult = v.mult * s
        return out
      end,

      min = function(v, s, out)
        out = out or v
        local sv = rgbm.isrgbm(s)
        out.r = math.min(v.r, sv and s.r or s)
        out.g = math.min(v.g, sv and s.g or s)
        out.b = math.min(v.b, sv and s.b or s)
        out.mult = math.min(v.mult, sv and s.mult or s)
        return out
      end,

      max = function(v, s, out)
        out = out or v
        local sv = rgbm.isrgbm(s)
        out.r = math.max(v.r, sv and s.r or s)
        out.g = math.max(v.g, sv and s.g or s)
        out.b = math.max(v.b, sv and s.b or s)
        out.mult = math.max(v.mult, sv and s.mult or s)
        return out
      end,

      saturate = function(v, out)
        out = out or v
        out.r = math.saturateN(v.r)
        out.g = math.saturateN(v.g)
        out.b = math.saturateN(v.b)
        out.mult = math.saturateN(v.mult)
        return out
      end,

      clamp = function(v, min, max, out)
        out = out or v
        out.r = math.clampN(v.r, min.r, max.r)
        out.g = math.clampN(v.g, min.g, max.g)
        out.b = math.clampN(v.b, min.b, max.b)
        out.mult = math.clampN(v.mult, min.mult, max.mult)
        return out
      end,

      normalize = function(v)
        local m = v:value()
        if m > 1 then return v / m end
        return v
      end,

      value = function (v) return v.rgb:value() * v.mult end,
      getValue = function (v) return v.rgb:value() * v.mult end,
      luminance = function (v) return v.rgb:luminance() * v.mult end,
      getLuminance = function (v) return v.rgb:luminance() * v.mult end,

      color = function(v) return v.rgb * v.mult end,
      toRgb = function(v) return v.rgb * v.mult end,
      hsv = function(v) return v:color():hsv() end,
      toHsv = function(v) return v:color():hsv() end,
      vec3 = function(v) return v:color():vec() end,
      toVec3 = function(v) return v:color():vec() end,
      vec4 = function(v) return vec4(v.rgb.r, v.rgb.g, v.rgb.b, v.mult) end,
      toVec4 = function(v) return vec4(v.rgb.r, v.rgb.g, v.rgb.b, v.mult) end,
    }
  }
}