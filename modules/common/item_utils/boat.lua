local M = {}

local WATER_ID = block.index("base:water")

local function delete_item(pid)
	local inv, slot = player.get_inventory(pid)

	local item_id, item_count = inventory.get(inv, slot)
	if item_count > 0 then
		inventory.set(inv, slot, item_id, item_count - 1)
	end
end

function M.try_delete_item(pid)
	if not player.is_infinite_items(pid) then
		delete_item(pid)
	end
end

M.placement_mutex = {
	locked_at = time.uptime(),
	lock_interval = 0.3,
}

--- It is used for preventing several boats spawning inside each other
---@return boolean success
function M.placement_mutex.try_lock()
	if time.uptime() - M.placement_mutex.locked_at < M.placement_mutex.lock_interval then
		return false
	end
	M.placement_mutex.locked_at = time.uptime()
	return true
end

--- Should be called when item used, to calculate boat position
---@param pid integer player id
---@param boat_entity_index integer
---@return boolean success, vec3|nil pos
function M.get_boat_placement_by_player(pid, boat_entity_index)
	local x, y, z = player.get_pos(pid)
	local dir = player.get_dir(pid)

	local max_spawn_distance = player.get_interaction_distance(pid)

	local res = block.raycast({ x, y + 0.7, z }, dir, max_spawn_distance, nil, {}, true)
	if res == nil or res.block ~= WATER_ID and false then
		return false, nil
	end

	local pos = res.iendpoint
	if block.is_solid_at(pos[1], pos[2], pos[3]) or block.get(pos[1], pos[2], pos[3]) == WATER_ID then
		pos[2] = pos[2] + 1
	end

	if block.is_solid_at(pos[1], pos[2], pos[3]) then
		return false, nil
	end

	pos[1] = pos[1] + 0.5
	pos[3] = pos[3] + 0.5

	local hitbox = entities.def_hitbox(boat_entity_index)
	hitbox = vec3.mul(hitbox, 2)
	local hitbox_pos = vec3.add(pos, { 0, hitbox[2] / 2, 0 })
	local hibox_left_corner = vec3.sub(hitbox_pos, vec3.div(hitbox, 2))
	-- local hibox_right_corner = vec3.add(hitbox_pos, vec3.div(hitbox, 2))
	-- spawn_particles_between(hibox_left_corner, hibox_right_corner)

	local all_ents = entities.get_all_in_box(hibox_left_corner, hitbox)
	if table.count_pairs(all_ents) ~= 0 then
		return false, nil
	end

	return true, pos
end

return M
