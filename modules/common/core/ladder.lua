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

function M.get_ladder_check_pos(pl_pos)
	return {
		math.floor(pl_pos[1]),
		math.floor(pl_pos[2] + M.LADDER_CHECK_Y_SHIFT),
		math.floor(pl_pos[3]),
	}
end

function M.is_in_ladder_range(pl_pos, block_id, check_pos, ladder_tag)
	if not block.has_tag(block_id, ladder_tag) then
		return false
	end
	check_pos = check_pos or M.get_ladder_check_pos(pl_pos)
	if block.get(check_pos[1], check_pos[2], check_pos[3]) == block_id then
		local rot = block.get_rotation(check_pos[1], check_pos[2], check_pos[3])
		local res = M.is_close_to_ladder(pl_pos[1], pl_pos[3], check_pos[1], check_pos[3], rot)
		return res
	end
	return false
end

local function get_double_sided_blocks_to_check(pl_pos, check_pos)
	---@type table<integer, {pos:vec3, rot:integer}>
	local blocks_to_check = {}
	if pl_pos[1] >= check_pos[1] + 0.5 then
		blocks_to_check[#blocks_to_check + 1] = {
			pos = vec3.add(check_pos, { 1, 0, 0 }),
			rot = 1,
		}
	else
		blocks_to_check[#blocks_to_check + 1] = {
			pos = vec3.add(check_pos, { -1, 0, 0 }),
			rot = 3,
		}
	end

	if pl_pos[3] >= check_pos[3] + 0.5 then
		blocks_to_check[#blocks_to_check + 1] = {
			pos = vec3.add(check_pos, { 0, 0, 1 }),
			rot = 0,
		}
	else
		blocks_to_check[#blocks_to_check + 1] = {
			pos = vec3.add(check_pos, { 0, 0, -1 }),
			rot = 2,
		}
	end
	return blocks_to_check
end

function M.is_in_double_sided_ladder_range(pl_pos, block_id, check_pos, ladder_tag)
	check_pos = check_pos or M.get_ladder_check_pos(pl_pos)
	local blocks_to_check = get_double_sided_blocks_to_check(pl_pos, check_pos)
	local cur_block_id, bx, by, bz
	for _, block_to_check in ipairs(blocks_to_check) do
		bx, by, bz = unpack(block_to_check.pos)
		cur_block_id = block.get(bx, by, bz)
		if
			(not block_id or block_id == cur_block_id)
			and block.has_tag(cur_block_id, "intcom:double_sided_ladder")
			and block.has_tag(cur_block_id, ladder_tag)
		then
			local rot = block.get_rotation(bx, by, bz)
			if rot == block_to_check.rot then
				if M.is_close_to_ladder(pl_pos[1], pl_pos[3], check_pos[1], check_pos[3], (rot + 2) % 4) then
					return block_to_check
				end
			end
		end
	end
	return nil
end

function M.check_ladder(pid, ladder_tag, entity_name, component_name)
	if player.is_noclip(pid) or player.is_flight(pid) then
		return false
	end

	local peid = player.get_entity(pid)
	if input.is_active("movement.crouch") and entities.get(peid).rigidbody:is_grounded() then
		return false
	end

	local px, py, pz = player.get_pos()
	local pl_pos = { px, py, pz }
	local check_pos = M.get_ladder_check_pos(pl_pos)
	local block_id = block.get(check_pos[1], check_pos[2], check_pos[3])
	local block_str_id = block.name(block_id)

	local is_in_ladder_range = M.is_in_ladder_range(pl_pos, block_id, check_pos, ladder_tag)
	local is_in_double_sided_ladder_range = M.is_in_double_sided_ladder_range(pl_pos, nil, check_pos, ladder_tag)

	local on_double_sided = false

	if not is_in_ladder_range then
		if is_in_double_sided_ladder_range then
			local d = is_in_double_sided_ladder_range
			block_id = block.get(unpack(d.pos))
			block_str_id = block.name(block_id)
			on_double_sided = true
		else
			return false
		end
	end

	local mount_entity = rideable_api.get_mount_entity(pid)
	if mount_entity then
		local ent = entities.get(mount_entity)
		local comp = ent:get_component(ladder_tag)
		if comp == nil or comp.SAVED_DATA.block_str_id == block_str_id then
			return false
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
			on_double_sided = on_double_sided,
		},
	})
	return true
end

return M
