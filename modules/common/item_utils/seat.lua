---@type seat_item_utils
---@diagnostic disable-next-line
local M = {}

function M.try_sit_player(x, y, z, pid)
	local px, py, pz = player.get_pos(pid)
	local sit_reach = player.get_interaction_distance(pid)
	if vec3.length({ px - (x + 0.5), py - (y + 0.5), pz - (z + 0.5) }) < sit_reach then
		M.sit_player(x, y, z, pid)
		return true
	end
	return false
end

function M.sit_player(x, y, z, pid)
	local rx, ry, rz = math.floor(x), math.floor(y), math.floor(z)
	entities.spawn("seat_commons:seat", { x + 0.5, y, z + 0.5 }, {
		["seat_commons__seat"] = {
			rider_id = pid,
			block_str_id = block.name(block.get(rx, ry, rz)),
		},
	})
end

return M
