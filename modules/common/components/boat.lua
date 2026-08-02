---@type rideable_api
local rideable_api = require("rideable_api:api/v1/mount")
require("intcom:common/utils")
local common_comp = require("intcom:common/components/common")

local M = {}

---@diagnostic disable: missing-fields
---@type boat_comp
local comp = {}
---@diagnostic enable: missing-fields

M.comp = comp

comp.default_params = {
	gravity = 1,
	max_speed = 7,
	rotation_acceleration = 0.02,
	rotation_deceleration = 0.003,
	max_rotation_speed = 1,
	max_ground_rotation_speed = 0.2,
	turn_velocity_dependency = 0,
	roll_speed = 0.1,
	max_roll = 0,
	roll_lift = 0,
	bottom_y_shift = -0.11,
	acceleration = 0.04,
	water_splashes_number = 4,
	water_splashes_width = 1,
	inventory_size = 0,
	layout_id = nil,
	player_pos_shift = { 0, 0.8, 0 },
}

---@param entity voxelcore.class.entity
---@param SAVED_DATA table
---@param ARGS table
---@return boat_comp
function M.new(entity, SAVED_DATA, ARGS)
	local component_name = "boat"
	local new_comp = common_comp.new(entity, SAVED_DATA, ARGS, comp, component_name)
	local overridden_funcs, overriden_params = common_comp.get_entity_overriden(new_comp, component_name)
	common_comp.override_functions(new_comp, SAVED_DATA, ARGS, overridden_funcs)
	new_comp.p = common_comp.calc_params(SAVED_DATA, ARGS, overriden_params, comp.default_params)
	common_comp.create_dummies(new_comp)
	return new_comp
end

------------------------------ SAVE / SPAWN / DESPAWN -------------------------

---@param self boat_comp
local function update_rot_matrix(self)
	local rot = mat4.rotate({ 0, 1, 0 }, -self.saved_data.rotation)
	rot = mat4.rotate(rot, { 1, 0, 0 }, self.saved_data.roll)
	self.tsf:set_rot(rot)
end

---@param self boat_comp
local function update_rig_transform(self)
	if self.p.max_roll == 0 then
		return
	end
	local roll_k = math.abs(self.saved_data.roll) / self.p.max_roll
	local mat = self.saved_data.initial_rig_matrix
	mat = mat4.translate(mat, { 0, self.p.roll_lift * roll_k, 0 })
	self.rig:set_matrix(0, mat)
end

----------

---@param self boat_comp
local function get_full_inventory_data(self)
	local invid = self.saved_data.inventory_id
	local d = {}
	for slot_id = 0, self.p.inventory_size - 1 do
		local id, count = inventory.get(invid, slot_id)
		local all_data = inventory.get_all_data(invid, slot_id) or {}
		d[#d + 1] = {
			id = id,
			count = count,
			slot_id = slot_id,
			all_data = all_data,
		}
	end
	return d
end

---@param invid integer
---@param data table
local function set_full_inventory_data(invid, data)
	for i = 1, #data do
		local p = data[i]
		local slot_id = p.slot_id
		inventory.set(invid, slot_id, p.id, p.count)
		for dname, dvalue in pairs(p.all_data) do
			inventory.set_data(invid, slot_id, dname, dvalue)
		end
	end
end

---@param self boat_comp
local function on_spawn_handle_rot(self)
	self.saved_data.roll = self.saved_data.roll or 0
	self.saved_data.initial_rig_matrix = self.rig:get_matrix(0)
	self.saved_data.rotation_speed = self.saved_data.rotation_speed or 0
	if not self.saved_data.rotation then
		local rot_mat4 = self.args.rotation_mat4
		if rot_mat4 then
			local m00 = rot_mat4[1]
			local m02 = rot_mat4[3]

			local yaw = math.deg(math.atan2(m02, m00))
			self.saved_data.rotation = yaw
			update_rot_matrix(self)
			update_rig_transform(self)
		else
			self.saved_data.rotation = 0
		end
	end
end

---@param self boat_comp
local function on_spawn_handle_inventory(self)
	local invid = inventory.create(self.p.inventory_size)
	self.saved_data.inventory_id = invid
	if self.saved_data.inventory_data then
		set_full_inventory_data(invid, self.saved_data.inventory_data)
	end
end

---@param self boat_comp
local function on_spawn_handle_rider(self)
	local pid = self.saved_data.rider_id
	if pid then
		self.saved_data.rider_id = nil
		self:player_mount(pid)
	end
end

---------

function comp.on_spawn(self)
	on_spawn_handle_rot(self)
	on_spawn_handle_inventory(self)
	on_spawn_handle_rider(self)
end

function comp.on_save(self)
	self.saved_data.inventory_data = get_full_inventory_data(self)
end

function comp.on_despawn(self)
	local invid = self.saved_data.inventory_id
	self.saved_data.inventory_id = nil
	inventory.remove(invid)
	rideable_api.unmount(self.saved_data.rider_id)
end

------------------------------ MOUSE EVENTS -----------------------------------

function comp.open_inventory(self)
	if self.p.inventory_size == 0 or self.p.layout_id == nil then
		return
	end
	hud.open(self.p.layout_id, false, self.saved_data.inventory_id)
end

--------

function comp.on_attacked(self, _, pid)
	if self.saved_data.rider_id ~= nil then
		return
	end

	local pos = self.tsf:get_pos()
	local x, y, z = math.floor(pos[1]), math.floor(pos[2]), math.floor(pos[3])

	if not player.is_infinite_items(pid) then
		entities.spawn(
			"base:drop",
			{ x + 0.5, y + 0.5, z + 0.5 },
			{ base__drop = { id = item.index(self.entity:def_name() .. ".item"), count = 1 } }
		)
	end

	self.entity:despawn()
end

function comp.on_used(self, pid)
	if input.is_active("movement.crouch") then
		self:open_inventory()
	else
		self:player_mount(pid)
	end
end

------------------------------ MOUNT / UNMOUNT --------------------------------

function comp.player_unmount(self)
	local x, y, z = player.get_pos(self.saved_data.rider_id)
	player.set_pos(self.saved_data.rider_id, x, y + 0.5, z)
	player.set_noclip(self.saved_data.rider_id, self.saved_data.player_had_noclip_before_mount)
	self.saved_data.player_had_noclip_before_mount = nil
	self.saved_data.rider_id = nil
end

function comp.player_mount(self, pid)
	if self.saved_data.rider_id == pid then
		return
	end
	rideable_api.mount(pid, self.entity:get_uid(), nil, function()
		self:player_unmount()
	end)
	self.saved_data.player_had_noclip_before_mount = player.is_noclip(pid)
	player.set_noclip(pid, true)
	self.saved_data.rider_id = pid
end

------------------------------ KEYBOARD EVENTS --------------------------------

function comp.check_unmount(self)
	if not self.saved_data.rider_id then
		return
	end
	if input.is_active("movement.crouch") then
		rideable_api.unmount(self.saved_data.rider_id)
		return
	end
end

------------------------------ PERIODICAL EVENTS ------------------------------

function comp.tp_player(self)
	if self.saved_data.rider_id == nil then
		return
	end
	local pos = self.tsf:get_pos()
	local s = self.p.player_pos_shift
	player.set_vel(self.saved_data.rider_id, 0, 0, 0)
	player.set_pos(self.saved_data.rider_id, pos[1] + s[1], pos[2] + s[2], pos[3] + s[3])
end

------------ MOVE -------------

---@param v2 vec2
---@return vec3
local function vec2tovec3(v2)
	return { v2[1], 0, v2[2] }
end
---
---@param v3 vec3
---@return vec2
local function vec3tovec2(v3)
	return { v3[1], v3[3] }
end

---@param self boat_comp
local function calc_effective_acceleration(self, rotation_acceleration_modifier, speed)
	return self.p.rotation_acceleration
		* rotation_acceleration_modifier
		* (1 - self.p.turn_velocity_dependency * (1 - math.abs(speed) / self.p.max_speed))
end

---@param self boat_comp
function comp.move(self)
	local S = self.saved_data
	local full_vel = self.body:get_vel()
	local y_vel = full_vel[2]
	local vel = vec3tovec2(full_vel)
	local speed = vec2.length(vel)

	local moving = false
	local rot_acc_mod = 1
	local rot_dec_mod = 1
	local max_rot_speed = self.p.max_rotation_speed
	if S.reversed then
		speed = -speed
		rot_acc_mod = -1
	end

	if S.rider_id then
		if input.is_active("movement.forward") then
			speed = speed + self.p.acceleration
			moving = true
			rot_acc_mod = 1
		end
		if input.is_active("movement.back") then
			speed = speed - self.p.acceleration
			moving = true
			rot_acc_mod = -1
		end
	end

	if self.body:is_grounded() then
		max_rot_speed = self.p.max_ground_rotation_speed
		rot_dec_mod = 5
	end

	if S.rider_id then
		if input.is_active("movement.left") then
			S.rotation_speed = S.rotation_speed - calc_effective_acceleration(self, rot_acc_mod, speed)
		end
		if input.is_active("movement.right") then
			S.rotation_speed = S.rotation_speed + calc_effective_acceleration(self, rot_acc_mod, speed)
		end
	end

	if S.rotation_speed ~= 0 then
		if math.abs(S.rotation_speed) > max_rot_speed then
			S.rotation_speed = math.sign(S.rotation_speed) * max_rot_speed
		end
		S.rotation = S.rotation + S.rotation_speed
		local rot_dec = self.p.rotation_deceleration * rot_dec_mod
		if math.abs(S.rotation_speed) < rot_dec then
			S.rotation_speed = 0
		else
			S.rotation_speed = S.rotation_speed - math.sign(S.rotation_speed) * rot_dec
		end

		local roll_k = 1
		if S.reversed then
			roll_k = -1
		end
		local target_roll = self.p.max_roll * S.rotation_speed / self.p.max_rotation_speed * roll_k
		local roll = S.roll
		if math.abs(target_roll - roll) < self.p.roll_speed then
			roll = target_roll
		else
			roll = roll + math.sign(target_roll - roll) * self.p.roll_speed
		end
		S.roll = roll

		update_rot_matrix(self)
		update_rig_transform(self)

		moving = true
	end

	if moving then
		if speed < 0 then
			S.reversed = true
		else
			S.reversed = false
		end

		if math.abs(speed) > self.p.max_speed then
			speed = speed / math.abs(speed) * self.p.max_speed
		end

		vel = vec2.rotate({ speed, 0 }, S.rotation)

		if vel[1] ~= vel[1] or vel[2] ~= vel[2] then
			vel = { 0, 0 }
		end

		full_vel = vec2tovec3(vel)
		full_vel[2] = y_vel
		self.body:set_vel(full_vel)
	end
end

------------ VISUAL -----------

local water_id = block.index("base:water")

---@param self boat_comp
function comp.spawn_move_water_splashes(self)
	if not self.saved_data.is_in_water or self.saved_data.is_under_water then
		return
	end
	local pos = self.tsf:get_pos()
	local vel = vec3tovec2(self.body:get_vel())

	local threshold_min = self.p.max_speed / 4
	local threshold_max = self.p.max_speed
	local speed = vec2.length(vel)
	if speed <= threshold_min then
		return
	end

	local probability = (speed - threshold_min) / (threshold_max - threshold_min)

	vel = vec2.normalize(vel)
	local vel_ortho = vec2.rotate(vel, 90)

	local w_spl = self.p.water_splashes_number
	-- local last_spawned = self.saved_data.move_water_splashes_last_spawned

	for i = 0, w_spl - 1 do
		if random.random() < probability then
			-- if true then
			local p = vec3.sub(
				pos,
				vec3.mul({
					vel[1],
					0,
					vel[2],
				}, 1)
			)
			local m = (-(w_spl - 1) / 2 + i) * self.p.water_splashes_width / w_spl
			p = vec3.add(p, {
				vel_ortho[1] * m,
				0,
				vel_ortho[2] * m,
			})
			gfx.particles.emit(p, 1, {
				texture = "blocks:" .. block.get_textures(water_id)[1],
				spawn_interval = 0,
				lifetime = 0.8,
				acceleration = { 0, -4, 0 },
				explosion = { 1, 1, 1 },
				size = { 0.1, 0.1, 0.1 },
				spawn_spread = { 0.2, 0.2, 0.2 },
			})
		else
		end
	end
end

---@param self boat_comp
function comp.spawn_fall_water_splashes(self)
	if self.saved_data.is_in_water then
		return
	end

	local vel = self.body:get_vel()
	if vel[2] < 0 and vel[2] > -4 then
		return
	end

	local pos = self.tsf:get_pos()

	gfx.particles.emit(pos, 40, {
		texture = "blocks:" .. block.get_textures(water_id)[1],
		spawn_interval = 0,
		lifetime = 3,
		acceleration = { 0, -7, 0 },
		explosion = { 3, 6, 3 },
		size = { 0.15, 0.15, 0.15 },
		spawn_spread = { 1, 0.2, 1 },
	})
end

------------ WATER BEHAVIOUR -----------

---@param self boat_comp
---@param is_positive boolean
local function set_gravity_dir_positive(self, is_positive)
	local gravity = self.body:get_gravity_scale()
	if is_positive and gravity < 0 or not is_positive and gravity > 0 then
		gravity = -gravity
		self.body:set_gravity_scale(gravity)
	end
end

---@param self boat_comp
---@param scale number
local function set_gravity_scale_abs(self, scale)
	local gravity = self.body:get_gravity_scale()
	if gravity >= 0 then
		self.body:set_gravity_scale(scale)
	else
		self.body:set_gravity_scale(-scale)
	end
end

local function overlap_any_block(x, y, z, block_id)
	x = math.round(x - 0.5)
	y = math.floor(y)
	z = math.round(z - 0.5)
	-- block.set(x, y + 2, z, block.index("base:leaves"))
	if block.get(x, y, z) == block_id then
		return {
			math.floor(x),
			math.floor(y),
			math.floor(z),
		}
	end
	return nil
end

---@param water_surface_y integer|nil
local function calculate_archimede_force_k(water_surface_y, bottom_y)
	if water_surface_y == nil then
		return 1
	end
	local top_y = bottom_y + 7 / 16
	if bottom_y > water_surface_y then
		return 0
	end

	if top_y < water_surface_y then
		return 1
	end

	return (water_surface_y - bottom_y) / (top_y - bottom_y)
end

--- Returns water surface y (number) up above given pos.
--- It checks only 2 blocks above.
--- Water surface is any replaceable block, but not water.
--- If water surface not found, returns nil
---@param water_pos vec3
local function get_water_surface_y_near(water_pos)
	local x, z = water_pos[1], water_pos[3]
	for y = water_pos[2] + 1, water_pos[2] + 2 do
		if block.is_replaceable_at(x, y, z) and block.get(x, y, z) ~= water_id then
			return y
		end
	end
	return nil
end

------

---@param self boat_comp
function comp.handle_water_behaviour(self)
	local pos = self.tsf:get_pos()
	local x, y, z = pos[1], pos[2], pos[3]
	local bottom_y = y + self.p.bottom_y_shift
	local vel = self.body:get_vel()

	local water_pos = overlap_any_block(x, bottom_y, z, water_id)
	if water_pos then
		self:spawn_fall_water_splashes()
		self.saved_data.is_in_water = true
		local water_surface_y = get_water_surface_y_near(water_pos)
		local archimede_force_k = calculate_archimede_force_k(water_surface_y, bottom_y)

		set_gravity_scale_abs(self, self.p.gravity * archimede_force_k)
		local vdamping = math.abs(vel[2]) * ((1 - archimede_force_k) * 5 + 1.5)
		self.body:set_vdamping(vdamping)

		if archimede_force_k == 1 then
			self.saved_data.is_under_water = true
		else
			self.saved_data.is_under_water = false
		end

		set_gravity_dir_positive(self, false)
	else
		self.saved_data.is_under_water = false
		set_gravity_dir_positive(self, true)

		if overlap_any_block(x, bottom_y - 0.1, z, water_id) then
			set_gravity_scale_abs(self, self.p.gravity * 0.01)
			self.saved_data.is_in_water = true
			self.body:set_vdamping(20)
		else
			set_gravity_scale_abs(self, self.p.gravity)
			self.saved_data.is_in_water = false
			self.body:set_vdamping(3)
		end
	end
end

------------ UPDATE / RENDER -----------

function comp.on_update(self, _)
	self:handle_water_behaviour()
	self:spawn_move_water_splashes()
	self:check_unmount()
end

function comp.on_render(self, _)
	self:tp_player()
	self:move()
end

return M
