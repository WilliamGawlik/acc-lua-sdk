__source 'extensions/chaser_camera/ac_ext_chaser_camera.cpp'

require './common/internal_import'
require './common/ac_audio'

-- automatically generated entries go here:
__definitions()

-- extra additions:

---Gets chase camera settings.
---@return { distance: number, height: number, pitch: number }
function ac.getCameraParameters(index)
  local parameters = ffi.C.lj_get_camera_params_as_vec3(index)
  return { distance = parameters.x, height = parameters.y, pitch = parameters.z }
end

---@return vec2
function ac.getJoystickLook()
  local parameters = ffi.C.lj_get_joystick_look()
  return parameters.x ~= 0 and vec2(parameters.y, parameters.z) or nil
end

-- script format:
---@class ScriptData
---@single-instance
script = {}

--[[? if (ctx.ldoc) out(]]

---Called each frame.
---@param dt number @Time passed since last `update()` call, in seconds.
function script.update(dt) end

--[[) ?]]
