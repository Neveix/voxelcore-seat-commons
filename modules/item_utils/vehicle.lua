local M = {}

function M.get_vehicle_rotation_mat4(pid)
	local rx, _, _ = player.get_rot(pid, false)
	rx = rx + 90
	rx = math.round(rx / 45) * 45
	local rot = mat4.rotate({ 0, 1, 0 }, rx)
	return rot
end

return M
