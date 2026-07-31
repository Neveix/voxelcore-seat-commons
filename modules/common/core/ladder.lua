---@type rideable_api
local rideable_api = require("rideable_api:api/v1/mount")

---@type ladder_core
---@diagnostic disable-next-line
local M = {}

local hitbox = entities.def_hitbox(entities.def_index("base:player"))
M.LADDER_CHECK_Y_SHIFT = -hitbox[2] / 2 + 0.01

function M.is_close_to_ladder(x, z, rx, rz, rot)
	if rot == 0 then
		return z < rz + 0.5
	elseif rot == 1 then
		return x < rx + 0.5
	elseif rot == 2 then
		return z > rz + 0.5
	else
		return x > rx + 0.5
	end
end

function M.is_in_ladder_range(pl_pos, block_id)
	local p = M.get_ladder_check_pos(pl_pos)
	if block.get(p[1], p[2], p[3]) == block_id then
		local rot = block.get_rotation(p[1], p[2], p[3])
		return M.is_close_to_ladder(pl_pos[1], pl_pos[3], p[1], p[3], rot)
	end
	return false
end

function M.get_ladder_check_pos(pl_pos)
	pl_pos[1] = math.floor(pl_pos[1])
	pl_pos[2] = math.floor(pl_pos[2] + M.LADDER_CHECK_Y_SHIFT)
	pl_pos[3] = math.floor(pl_pos[3])
	return pl_pos
end

function M.check_ladder(pid, ladder_tag, entity_name, component_name)
	if player.is_noclip(pid) or player.is_flight(pid) then
		return
	end

	local peid = player.get_entity(pid)
	if input.is_active("movement.crouch") and entities.get(peid).rigidbody:is_grounded() then
		return
	end

	local px, py, pz = player.get_pos()
	local pl_pos = { px, py, pz }
	local check_pos = M.get_ladder_check_pos(pl_pos)
	local block_id = block.get(check_pos[1], check_pos[2], check_pos[3])
	local block_str_id = block.name(block_id)
	if block.has_tag(block_id, ladder_tag) then
		local rot = block.get_rotation(check_pos[1], check_pos[2], check_pos[3])
		if not M.is_close_to_ladder(px, pz, check_pos[1], check_pos[3], rot) then
			return
		end
	else
		return
	end

	local mount_entity = rideable_api.get_mount_entity(pid)
	if mount_entity then
		local ent = entities.get(mount_entity)
		local comp = ent:get_component(ladder_tag)
		if comp == nil or comp.SAVED_DATA.block_str_id == block_str_id then
			return
		end
	end

	local sep_index = string.find(component_name, ":")
	local pack_id = string.sub(component_name, 1, sep_index - 1)
	local comp_id = string.sub(component_name, sep_index + 1)

	entities.spawn(entity_name, { 0, 10000, 0 }, {
		[pack_id .. "__" .. comp_id] = {
			rider_id = pid,
			block_str_id = block_str_id,
			block_tag = ladder_tag,
		},
	})
end

return M
