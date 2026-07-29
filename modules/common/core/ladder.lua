---@type rideable_api
local rideable_api = require("rideable_api:api/v1/mount")

---@type ladder_core
---@diagnostic disable-next-line
local M = {}

local hitbox = entities.def_hitbox(entities.def_index("base:player"))
M.LADDER_CHECK_Y_SHIFT = -hitbox[2] / 2 + 0.01

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
	local ry = math.floor(y + M.LADDER_CHECK_Y_SHIFT)
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
	if not M.is_in_ladder_range(x, y, z, ladder_tag) then
		return
	end
	entities.spawn("seat_commons:ladder_dummy", { 0, 10000, 0 }, {
		seat_commons__ladder_dummy = {
			rider_id = pid,
		},
	})
end

return M
