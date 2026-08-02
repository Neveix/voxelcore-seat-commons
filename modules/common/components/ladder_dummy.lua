---@type rideable_api
local rideable_api = require("rideable_api:api/v1/mount")
require("intcom:common/utils")
local common_comp = require("intcom:common/components/common")
---@type ladder_core
local ladder = require("intcom:common/core/ladder")

local M = {}

---@type ladder_comp
---@diagnostic disable-next-line: missing-fields
local comp = {}

M.comp = comp

comp.default_params = {
	max_speed_xz = 1.5,
	max_speed_xz_cheat = 50,
	max_speed_y = 2,
	max_speed_y_cheat = 80,
	linear_damping = 10,
	linear_damping_cheat = 2,
	vdamping = 0.5,
	vdamping_cheat = 0.2,
	vert_acceleration = 10,
	vert_acceleration_cheat = 100,
	gravity = 0,
}

---@param SAVED_DATA table
---@param ARGS table
---@param overriden_params table
function M.calc_params(SAVED_DATA, ARGS, overriden_params)
	local params = {}
	local piniter = common_comp.new_param_initializer(params, SAVED_DATA, ARGS, overriden_params, comp.default_params)
	piniter("max_speed_xz")
	piniter("max_speed_xz_cheat")

	piniter("max_speed_y")
	piniter("max_speed_y_cheat")

	piniter("linear_damping")
	piniter("linear_damping_cheat")

	piniter("vdamping")
	piniter("vdamping_cheat")

	piniter("vert_acceleration")
	piniter("vert_acceleration_cheat")

	piniter("gravity")
	return params
end

---@param entity voxelcore.class.entity
---@param SAVED_DATA table
---@param ARGS table
---@return ladder_comp
function M.new(entity, SAVED_DATA, ARGS)
	local component_name = "ladder"
	local new_comp = common_comp.new(entity, SAVED_DATA, ARGS, comp, component_name)
	local overridden_funcs, overriden_params = common_comp.get_block_overriden(new_comp, component_name)
	common_comp.override_functions(new_comp, SAVED_DATA, ARGS, overridden_funcs)
	new_comp.p = M.calc_params(SAVED_DATA, ARGS, overriden_params)
	common_comp.create_dummies(new_comp)
	return new_comp
end

------------------------------ SAVE / SPAWN / DESPAWN -------------------------

function comp.player_unmount(self)
	local vel = self.pbody:get_vel()
	local vel_mod = 1
	if vel[2] > 0.5 then
		vel[2] = vel[2] + math.clamp(4.5 - vel[2], 0, 4.5)
	end
	vel[1] = vel[1] * vel_mod
	vel[3] = vel[3] * vel_mod
	self.pbody:set_vel(vel)
	self.entity:despawn()
end

function comp.player_mount(self)
	rideable_api.mount(self.saved_data.rider_id, self.entity:get_uid(), nil, function()
		self:player_unmount()
	end)
end

------

function comp.save_player_body_settings(self)
	local pe = entities.get(player.get_entity(self.saved_data.rider_id))
	if pe == nil then
		return
	end
	local pbody = pe.rigidbody
	self.player_stored = {}
	self.player_stored.mass = pbody:get_mass()
	self.player_stored.gravity_scale = pbody:get_gravity_scale()
	self.player_stored.linear_damping = pbody:get_linear_damping()
	self.player_stored.vdamping = pbody:get_vdamping()
	self.player_stored.elasticity = pbody:get_elasticity()
end

function comp.load_player_body_settings(self)
	local pe = entities.get(player.get_entity(self.saved_data.rider_id))
	local pbody = pe.rigidbody
	if self.player_stored == nil then
		return
	end
	pbody:set_mass(self.player_stored.mass)
	pbody:set_gravity_scale(self.player_stored.gravity)
	pbody:set_linear_damping(self.player_stored.linear_damping)
	pbody:set_vdamping(self.player_stored.vdamping)
	pbody:set_elasticity(self.player_stored.elasticity)
end

function comp.on_spawn(self)
	if self.saved_data.block_str_id == nil or self.saved_data.already_initialized then
		self.entity:despawn()
		return
	end
	self.saved_data.already_initialized = true
	self.saved_data.block_id = block.index(self.saved_data.block_str_id)
	self.saved_data.rider_id = self.saved_data.rider_id or self.args.rider_id
	if self.saved_data.rider_id == nil then
		self.entity:despawn()
		return
	end
	self.body:set_gravity_scale(0)
	self.pbody = entities.get(player.get_entity(self.saved_data.rider_id)).rigidbody
	self:save_player_body_settings()
	self:init_step_sounds()
	self:player_mount()
end

function comp.on_despawn(self)
	self:load_player_body_settings()
	self.saved_data.rider_id = nil
end

--------------------------- PERIODICAL EVENTS ------------------------------

function comp.move(self, delta)
	local mov_vec = { 0.0, 0.0, 0.0 }
	local v_acc
	local max_speed_xz, max_speed_y

	self.pbody:set_gravity_scale(self.p.gravity)

	if input.is_active("movement.cheat") then
		v_acc = self.p.vert_acceleration_cheat * delta
		max_speed_xz = self.p.max_speed_xz_cheat
		max_speed_y = self.p.max_speed_y_cheat
		self.pbody:set_linear_damping(self.p.linear_damping_cheat)
		self.pbody:set_vdamping(self.p.vdamping_cheat)
	else
		v_acc = self.p.vert_acceleration * delta
		max_speed_xz = self.p.max_speed_xz
		max_speed_y = self.p.max_speed_y
		self.pbody:set_linear_damping(self.p.linear_damping)
		self.pbody:set_vdamping(self.p.vdamping)
	end

	if input.is_active("movement.jump") then
		mov_vec[2] = mov_vec[2] + v_acc
	end

	if input.is_active("movement.crouch") then
		mov_vec[2] = mov_vec[2] - v_acc
	end

	local yaw = player.get_rot(self.saved_data.rider_id)
	local rotated = vec2.rotate({ mov_vec[1], mov_vec[3] }, 90 - yaw)
	mov_vec[1] = -rotated[1]
	mov_vec[3] = -rotated[2]

	local vel = self.pbody:get_vel()
	vel = vec3.add(vel, mov_vec)
	speed_xz_sqr = vel[1] * vel[1] + vel[3] * vel[3]
	if speed_xz_sqr > max_speed_xz * max_speed_xz then
		local len = math.sqrt(speed_xz_sqr)
		vel[1] = vel[1] * max_speed_xz / len
		vel[3] = vel[3] * max_speed_xz / len
	end
	speed_y_sqr = vel[2] * vel[2]
	if speed_y_sqr > max_speed_y * max_speed_y then
		local len = math.sqrt(speed_y_sqr)
		vel[2] = vel[2] * max_speed_y / len
	end

	self.pbody:set_vel(vel)
end

function comp.player_start_unmount(self)
	rideable_api.unmount(self.saved_data.rider_id)
end

function comp.check_unmount(self)
	local uid = self.entity:get_uid()
	if player.is_noclip(uid) or player.is_flight(uid) then
		self:player_start_unmount()
		return
	end

	local x, y, z = player.get_pos(self.saved_data.rider_id)
	if not ladder.is_in_ladder_range({ x, y, z }, self.saved_data.block_id) then
		self:player_start_unmount()
		return
	end
end

function comp.get_tag_name(self)
	return self.saved_data.block_tag
end

function comp.init_step_sounds(self)
	local s = self.saved_data
	s.last_time_played_step_sound = time.uptime()
	local mat = block.properties[s.block_id].material
	mat = string.sub(mat, string.find(mat, ":") + 1)
	s.block_material = mat
end

function comp.play_step_sounds(self)
	local s = self.saved_data
	local mat = s.block_material or "wood"
	s.last_time_played_step_sound = s.last_time_played_step_sound or time.uptime()
	local x, y, z = player.get_pos(s.rider_id)
	local speed = vec3.length(self.pbody:get_vel())
	local period = 0.8 - (-0.2 + math.clamp(speed, 0.2, 1)) / 0.8 * 0.2
	if speed >= 0.2 and time.uptime() - s.last_time_played_step_sound > period then
		audio.play_sound("steps/" .. mat, x, y + ladder.LADDER_CHECK_Y_SHIFT, z, 0.2, 1)
		s.last_time_played_step_sound = time.uptime()
	end
end

function comp.on_update(self)
	if self.saved_data.rider_id == nil then
		return
	end
	self:check_unmount()
	self:play_step_sounds()
end

function comp.on_physics_update(self, delta)
	if self.saved_data.rider_id == nil then
		return
	end
	self.pbody:set_gravity_scale(0)
	self:move(delta)
end

return M
