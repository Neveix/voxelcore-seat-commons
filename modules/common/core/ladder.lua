---@type rideable_api
local rideable_api = require("rideable_api:api/v1/mount")

---@type ladder_core
---@diagnostic disable-next-line
local M = {}

local hitbox = entities.def_hitbox(entities.def_index("base:player"))
M.LADDER_CHECK_Y_SHIFT = -hitbox[2] / 2 + 0.01
M.LADDER_DUMMY_Y_SHIFT = 10000

function M.get_pos_for_ladder_entity(x, y, z)
	local rx = math.floor(x)
	local ry = math.floor(y)
	local rz = math.floor(z)
	local rot = block.get_rotation(rx, ry, rz)
	local final_y = y
	if rot == 0 then
		return { x, final_y, rz + 0.5 - 1 / 16 }
	elseif rot == 1 then
		return { rx + 0.5 - 1 / 16, final_y, z }
	elseif rot == 2 then
		return { x, final_y, rz + 0.5 + 1 / 16 }
	else
		return { rx + 0.5 + 1 / 16, final_y, z }
	end
end

local function is_close_to_ladder(x, z, rx, rz, rot)
	if rot == 0 then
		return z < rz + 0.5
	elseif rot == 1 then
		return x < rx + 0.5
	elseif rot == 2 then
		return z > rz + 0.5
	elseif rot == 3 then
		return x > rx + 0.5
	end
end

function M.is_in_ladder_range(x, y, z, ladder_tag)
	local rx = math.floor(x)
	local ry = math.floor(y + M.LADDER_CHECK_Y_SHIFT - M.LADDER_DUMMY_Y_SHIFT)
	local rz = math.floor(z)
	if block.has_tag(block.get(rx, ry, rz), ladder_tag) then
		local rot = block.get_rotation(rx, ry, rz)
		return is_close_to_ladder(x, z, rx, rz, rot)
	end
	return false
end

function M.check_ladder(pid, ladder_tag)
	if rideable_api.is_mounted(pid) then
		return
	end
	if player.is_noclip(pid) or player.is_flight(pid) then
		return
	end
	local peid = player.get_entity(pid)
	if input.is_active("movement.crouch") and entities.get(peid).rigidbody:is_grounded() then
		return
	end
	local x, y, z = player.get_pos()
	if not M.is_in_ladder_range(x, y + M.LADDER_DUMMY_Y_SHIFT, z, ladder_tag) then
		return
	end
	local entity_pos = {
		x,
		y + M.LADDER_DUMMY_Y_SHIFT,
		z,
	}
	entities.spawn("seat_commons:ladder_dummy", entity_pos, {
		seat_commons__ladder_dummy = {
			rider_id = pid,
		},
	})
end

return M
