---@type ladder_block_utils
---@diagnostic disable-next-line
local M = {}

function M.update_leaning_ladder(x, y, z, pid)
	local rot = block.get_rotation(x, y, z)
	local sx, sy, sz

	if rot == 0 then
		sx, sy, sz = 0, 0, -1
	elseif rot == 1 then
		sx, sy, sz = -1, 0, 0
	elseif rot == 2 then
		sx, sy, sz = 0, 0, 1
	elseif rot == 3 then
		sx, sy, sz = 1, 0, 0
	end
	local lower_block = block.get(x, y - 1, z)
	local lean_ok = block.is_solid_at(x + sx, y + sy, z + sz)
	local lower_ok = block.is_solid_at(x, y - 1, z) or block.has_tag(lower_block, "intcom:ladder")
	if not lean_ok or not lower_ok then
		block.destruct(x, y, z, pid)
	end
end

return M
