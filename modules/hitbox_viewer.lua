local M = {}

local RUST_ID = block.index("base:rust")

---@param pos vec3
function M.spawn_particle(pos)
	gfx.particles.emit(pos, 1, {
		texture = "blocks:" .. block.get_textures(RUST_ID)[1],
		spawn_interval = 0,
		lifetime = 1,
		acceleration = { 0, 0, 0 },
		explosion = { 0, 0, 0 },
		size = { 0.03, 0.03, 0.03 },
		spawn_spread = { 0, 0, 0 },
	})
end

---@param pos1 vec3
---@param pos2 vec3
function M.spawn_particles_between(pos1, pos2)
	local step = 0.1
	for x = pos1[1], pos2[1], step do
		M.spawn_particle({ x, pos1[2], pos1[3] })
		M.spawn_particle({ x, pos2[2], pos1[3] })
		M.spawn_particle({ x, pos1[2], pos2[3] })
		M.spawn_particle({ x, pos2[2], pos2[3] })
	end
	for y = pos1[2], pos2[2], step do
		M.spawn_particle({ pos1[1], y, pos1[3] })
		M.spawn_particle({ pos2[1], y, pos1[3] })
		M.spawn_particle({ pos1[1], y, pos2[3] })
		M.spawn_particle({ pos2[1], y, pos2[3] })
	end
	for z = pos1[3], pos2[3], step do
		M.spawn_particle({ pos1[1], pos1[2], z })
		M.spawn_particle({ pos2[1], pos1[2], z })
		M.spawn_particle({ pos1[1], pos2[2], z })
		M.spawn_particle({ pos2[1], pos2[2], z })
	end
end

return M
