---@type rideable_api
local rideable_api = require("rideable_api:mount")

function math.sign(x)
	if x > 0 then
		return 1
	elseif x < 0 then
		return -1
	else
		return 0
	end
end

local water_id = block.index("base:water")

-- TODO:
-- fix player trembling on boats
-- foam texture
-- foam particles generation under boats

local GRAVITY = ARGS.gravity or 1
local MAX_SPEED = ARGS.max_speed or 7
local ROTATION_ACCELERATION = ARGS.rotation_acceleration or 0.02
local ROTATION_DECELERATION = ARGS.rotation_deceleration or 0.003
local MAX_ROTATION_SPEED = ARGS.max_rotation_speed or 1
local MAX_GROUND_ROTATION_SPEED = ARGS.max_ground_rotation_speed or 0.2
local TURN_VELOCITY_DEPENDENCY = ARGS.turn_velocity_dependency or 0 -- 0 means zero dependency on velocity to rotate.
local ROLL_SPEED = ARGS.roll_speed or 0.1
local MAX_ROLL = ARGS.max_roll or 0
local ROLL_LIFT = ARGS.roll_lift or 0 -- in blocks
local BOTTOM_Y_SHIFT = ARGS.bottom_y_shift or 0
local ACCELERATION = ARGS.acceleration or 0.04
local WATER_SPLASHES_NUMBER = ARGS.water_splashes_number or 3
local WATER_SPLASHES_WIDTH = ARGS.water_splashes_width or 1
local INVENTORY_SIZE = ARGS.inventory_size or 0
---@type string|nil
local LAYOUT_ID = ARGS.layout_id or nil
local PLAYER_POS_SHIFT = ARGS.player_pos_shift or { 0, 0.8, 0 }

local tsf = entity.transform
local body = entity.rigidbody
local rig = entity.skeleton

local function update_rot_matrix()
	local rot = mat4.rotate({ 0, 1, 0 }, -SAVED_DATA.rotation)
	rot = mat4.rotate(rot, { 1, 0, 0 }, SAVED_DATA.roll)
	tsf:set_rot(rot)
end

local function update_rig_transform()
	if MAX_ROLL == 0 then
		return
	end
	local roll_k = math.abs(SAVED_DATA.roll) / MAX_ROLL
	local mat = SAVED_DATA.initial_rig_matrix
	mat = mat4.translate(mat, { 0, ROLL_LIFT * roll_k, 0 })
	rig:set_matrix(0, mat)
end

SAVED_DATA.roll = SAVED_DATA.roll or 0
SAVED_DATA.initial_rig_matrix = rig:get_matrix(0)
SAVED_DATA.rotation_speed = SAVED_DATA.rotation_speed or 0
if not SAVED_DATA.rotation then
	local rot_mat4 = ARGS.rotation_mat4
	if rot_mat4 then
		local m00 = rot_mat4[1]
		local m02 = rot_mat4[3]

		local yaw = math.deg(math.atan2(m02, m00))
		SAVED_DATA.rotation = yaw
		update_rot_matrix()
		update_rig_transform()
	else
		SAVED_DATA.rotation = 0
	end
end

---@param invid integer
local function get_full_inventory_data(invid)
	local d = {}
	for slot_id = 0, INVENTORY_SIZE - 1 do
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

do
	local invid = inventory.create(INVENTORY_SIZE)
	SAVED_DATA.inventory_id = invid
	if SAVED_DATA.inventory_data then
		set_full_inventory_data(invid, SAVED_DATA.inventory_data)
	end
end

function on_save()
	SAVED_DATA.inventory_data = get_full_inventory_data(SAVED_DATA.inventory_id)
end

function on_despawn()
	local invid = SAVED_DATA.inventory_id
	SAVED_DATA.inventory_id = nil
	inventory.remove(invid)
	rideable_api.unmount(SAVED_DATA.rider_id)
end

function on_attacked(_, pid)
	if SAVED_DATA.rider_id ~= nil then
		return
	end

	local pos = tsf:get_pos()
	local x, y, z = math.floor(pos[1]), math.floor(pos[2]), math.floor(pos[3])

	if not player.is_infinite_items(pid) then
		entities.spawn(
			"base:drop",
			{ x + 0.5, y + 0.5, z + 0.5 },
			{ base__drop = { id = item.index(entity:def_name() .. ".item"), count = 1 } }
		)
	end

	entity:despawn()
end

local function player_unmount()
	local x, y, z = player.get_pos(SAVED_DATA.rider_id)
	player.set_pos(SAVED_DATA.rider_id, x, y + 0.5, z)
	player.set_noclip(SAVED_DATA.rider_id, SAVED_DATA.player_had_noclip_before_mount)
	SAVED_DATA.player_had_noclip_before_mount = nil
	SAVED_DATA.rider_id = nil
end

local function player_mount(pid)
	if SAVED_DATA.rider_id == pid then
		return
	end
	rideable_api.unmount(pid)
	rideable_api.mount(pid, entity:get_uid(), nil, player_unmount)
	SAVED_DATA.player_had_noclip_before_mount = player.is_noclip(pid)
	player.set_noclip(pid, true)
	SAVED_DATA.rider_id = pid
end

do
	local pid = SAVED_DATA.rider_id
	if pid then
		SAVED_DATA.rider_id = nil
		player_mount(pid)
	end
end

local function open_inventory()
	if INVENTORY_SIZE == 0 or LAYOUT_ID == nil then
		return
	end
	hud.open(LAYOUT_ID, false, SAVED_DATA.inventory_id)
end

function on_used(pid)
	if input.is_active("movement.crouch") then
		open_inventory()
	else
		player_mount(pid)
	end
end

local function check_unmount()
	if not SAVED_DATA.rider_id then
		return
	end
	if input.is_active("movement.crouch") then
		player_unmount()
		return
	end
end

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

local function calc_effective_acceleration(rotation_acceleration_modifier, speed)
	return ROTATION_ACCELERATION
		* rotation_acceleration_modifier
		* (1 - TURN_VELOCITY_DEPENDENCY * (1 - math.abs(speed) / MAX_SPEED))
end

local function tp_player()
	if SAVED_DATA.rider_id == nil then
		return
	end
	local pos = tsf:get_pos()
	local s = PLAYER_POS_SHIFT
	player.set_vel(SAVED_DATA.rider_id, 0, 0, 0)
	player.set_pos(SAVED_DATA.rider_id, pos[1] + s[1], pos[2] + s[2], pos[3] + s[3])
end

local function move()
	local S = SAVED_DATA
	local full_vel = body:get_vel()
	local y_vel = full_vel[2]
	local vel = vec3tovec2(full_vel)
	local speed = vec2.length(vel)

	local moving = false
	local rotation_acceleration_modifier = 1
	local rotation_deceleration_modifier = 1
	local max_rotation_speed = MAX_ROTATION_SPEED
	if S.reversed then
		speed = -speed
		rotation_acceleration_modifier = -1
	end

	if SAVED_DATA.rider_id then
		if input.is_active("movement.forward") then
			speed = speed + ACCELERATION
			moving = true
			rotation_acceleration_modifier = 1
		end
		if input.is_active("movement.back") then
			speed = speed - ACCELERATION
			moving = true
			rotation_acceleration_modifier = -1
		end
	end

	if body:is_grounded() then
		max_rotation_speed = MAX_GROUND_ROTATION_SPEED
		rotation_deceleration_modifier = 5
	end

	if SAVED_DATA.rider_id then
		if input.is_active("movement.left") then
			S.rotation_speed = S.rotation_speed - calc_effective_acceleration(rotation_acceleration_modifier, speed)
		end
		if input.is_active("movement.right") then
			S.rotation_speed = S.rotation_speed + calc_effective_acceleration(rotation_acceleration_modifier, speed)
		end
	end

	if S.rotation_speed ~= 0 then
		if math.abs(S.rotation_speed) > max_rotation_speed then
			S.rotation_speed = math.sign(S.rotation_speed) * max_rotation_speed
		end
		S.rotation = S.rotation + S.rotation_speed
		local rotation_deceleration = ROTATION_DECELERATION * rotation_deceleration_modifier
		if math.abs(S.rotation_speed) < rotation_deceleration then
			S.rotation_speed = 0
		else
			S.rotation_speed = S.rotation_speed - math.sign(S.rotation_speed) * rotation_deceleration
		end

		local roll_k = 1
		if SAVED_DATA.reversed then
			roll_k = -1
		end
		local target_roll = MAX_ROLL * SAVED_DATA.rotation_speed / MAX_ROTATION_SPEED * roll_k
		local roll = SAVED_DATA.roll
		if math.abs(target_roll - roll) < ROLL_SPEED then
			roll = target_roll
		else
			roll = roll + math.sign(target_roll - roll) * ROLL_SPEED
		end
		SAVED_DATA.roll = roll

		update_rot_matrix()
		update_rig_transform()

		moving = true
	end

	if moving then
		if speed < 0 then
			S.reversed = true
		else
			S.reversed = false
		end

		if math.abs(speed) > MAX_SPEED then
			speed = speed / math.abs(speed) * MAX_SPEED
		end

		vel = vec2.rotate({ speed, 0 }, S.rotation)

		if vel[1] ~= vel[1] or vel[2] ~= vel[2] then
			vel = { 0, 0 }
		end

		full_vel = vec2tovec3(vel)
		full_vel[2] = y_vel
		body:set_vel(full_vel)
	end
end

local function spawn_move_water_splashes()
	if not SAVED_DATA.is_in_water or SAVED_DATA.is_under_water then
		return
	end
	local pos = tsf:get_pos()
	local vel = vec3tovec2(body:get_vel())

	local THRESHOLD_MIN = MAX_SPEED / 4
	local THRESHOLD_MAX = MAX_SPEED
	local speed = vec2.length(vel)
	if speed <= THRESHOLD_MIN then
		return
	end

	local probability = (speed - THRESHOLD_MIN) / (THRESHOLD_MAX - THRESHOLD_MIN)

	vel = vec2.normalize(vel)
	local vel_ortho = vec2.rotate(vel, 90)

	for i = 1, WATER_SPLASHES_NUMBER do
		if random.random() < probability then
			local p = vec3.sub(
				pos,
				vec3.mul({
					vel[1],
					0,
					vel[2],
				}, 1.1)
			)
			local m = -0.5 + (i - 1) / WATER_SPLASHES_NUMBER * WATER_SPLASHES_WIDTH
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

local function spawn_fall_water_splashes()
	if SAVED_DATA.is_in_water then
		return
	end

	local vel = body:get_vel()
	if vel[2] < 0 and vel[2] > -4 then
		return
	end

	local pos = tsf:get_pos()

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

local function set_gravity_dir_positive(is_positive)
	local gravity = body:get_gravity_scale()
	if is_positive and gravity < 0 or not is_positive and gravity > 0 then
		gravity = -gravity
		body:set_gravity_scale(gravity)
	end
end

local function set_gravity_scale_abs(scale)
	local gravity = body:get_gravity_scale()
	if gravity >= 0 then
		body:set_gravity_scale(scale)
	else
		body:set_gravity_scale(-scale)
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

local function handle_water_behaviour()
	local pos = tsf:get_pos()
	local x, y, z = pos[1], pos[2], pos[3]
	local bottom_y = y + BOTTOM_Y_SHIFT
	local vel = body:get_vel()

	local water_pos = overlap_any_block(x, bottom_y, z, water_id)
	if water_pos then
		spawn_fall_water_splashes()
		SAVED_DATA.is_in_water = true
		local water_surface_y = get_water_surface_y_near(water_pos)
		local archimede_force_k = calculate_archimede_force_k(water_surface_y, bottom_y)

		set_gravity_scale_abs(GRAVITY * archimede_force_k)
		local vdamping = math.abs(vel[2]) * ((1 - archimede_force_k) * 5 + 1.5)
		body:set_vdamping(vdamping)

		if archimede_force_k == 1 then
			SAVED_DATA.is_under_water = true
		else
			SAVED_DATA.is_under_water = false
		end

		set_gravity_dir_positive(false)
	else
		SAVED_DATA.is_in_water = false
		set_gravity_dir_positive(true)

		if overlap_any_block(x, bottom_y - 0.1, z, water_id) then
			set_gravity_scale_abs(GRAVITY * 0.01)
			body:set_vdamping(20)
		else
			set_gravity_scale_abs(GRAVITY)
			body:set_vdamping(3)
		end
	end
end

function on_update(_)
	handle_water_behaviour()
	spawn_move_water_splashes()
	check_unmount()
end

function on_render(_)
	tp_player()
	move()
end
