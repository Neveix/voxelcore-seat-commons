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

function M.get_ladder_block_str_id(x, y, z)
	local rx = math.floor(x)
	local ry = math.floor(y + M.LADDER_CHECK_Y_SHIFT)
	local rz = math.floor(z)
	local block_id = block.get(rx, ry, rz)
	return block.name(block_id)
end

function M.check_ladder(pid, ladder_tag, entity_name, component_name)
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

	local block_str_id = M.get_ladder_block_str_id(x, y, z)
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
