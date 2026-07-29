---@type rideable_api
local rideable_api = require("rideable_api:api/v1/mount")
require("seat_commons:common/utils")
local common_comp = require("seat_commons:common/components/common")
---@type ladder_core
local ladder = require("seat_commons:common/core/ladder")

local M = {}

---@type ladder_comp
---@diagnostic disable-next-line: missing-fields
local comp = {}

M.comp = comp

comp.default_params = {
	max_speed = 4,
	max_speed_cheat = 40,
	linear_damping = 15,
	linear_damping_cheat = 1,
	vdamping = 0.7,
	vdamping_cheat = 1,
	vert_acceleration = 20,
	vert_acceleration_cheat = 100,
	gravity = 0,
}

---@param SAVED_DATA table
---@param ARGS table
---@param overriden_params table
function M.calc_params(SAVED_DATA, ARGS, overriden_params)
	local piniter = common_comp.new_param_initializer(SAVED_DATA, ARGS, overriden_params, comp.default_params)
	local p = {}
	p.max_speed = piniter("max_speed")
	p.max_speed_cheat = piniter("max_speed_cheat")

	p.linear_damping = piniter("linear_damping")
	p.linear_damping_cheat = piniter("linear_damping_cheat")

	p.vdamping = piniter("vdamping")
	p.vdamping_cheat = piniter("vdamping_cheat")

	p.vert_acceleration = piniter("vert_acceleration")
	p.vert_acceleration_cheat = piniter("vert_acceleration_cheat")

	p.gravity = piniter("gravity")
	return p
end

---@param entity voxelcore.class.entity
---@param SAVED_DATA table
---@param ARGS table
---@return ladder_comp
function M.new(entity, SAVED_DATA, ARGS)
	local component_name = "ladder"
	local new_comp = common_comp.new(entity, SAVED_DATA, ARGS, comp, component_name)
	local overridden_funcs, overriden_params = common_comp.get_entity_overriden(new_comp, component_name)
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
		vel[2] = vel[2] + 4
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
	self.body:set_gravity_scale(0)
	self.saved_data.rider_id = self.saved_data.rider_id or self.args.rider_id
	self.saved_data.block_str_id = self.saved_data.block_str_id or self.args.block_str_id
	if self.saved_data.rider_id == nil then
		self.entity:despawn()
		return
	end
	self.pbody = entities.get(player.get_entity(self.saved_data.rider_id)).rigidbody
	self:save_player_body_settings()
	if self.saved_data.already_initialized then
		self.entity:despawn()
		return
	end
	self.saved_data.already_initialized = true
	self:player_mount()
end

function comp.on_despawn(self)
	self:load_player_body_settings()
	self.saved_data.rider_id = nil
end

------------------------------ PERIODICAL EVENTS ------------------------------

function comp.move(self, delta)
	local mov_vec = { 0.0, 0.0, 0.0 }
	local v_acc
	local max_speed

	self.pbody:set_gravity_scale(self.p.gravity)

	if input.is_active("movement.cheat") then
		v_acc = self.p.vert_acceleration_cheat * delta
		max_speed = self.p.max_speed_cheat
		self.pbody:set_linear_damping(self.p.linear_damping_cheat)
		self.pbody:set_vdamping(self.p.vdamping_cheat)
	else
		v_acc = self.p.vert_acceleration * delta
		max_speed = self.p.max_speed
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

	len_sqr = vec3.length_sqr(vel)
	if len_sqr > max_speed * max_speed then
		local len = math.sqrt(len_sqr)
		vel = vec3.mul(vel, max_speed / len)
	end

	self.pbody:set_vel(vel)

	local x, y, z = player.get_pos(self.saved_data.rider_id)
	if not ladder.is_in_ladder_range(x, y, z, self:get_tag_name()) then
		self:player_start_unmount()
	end
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
end

function comp.get_tag_name(_)
	return "seat_commons:ladder"
end

function comp.on_update(self)
	if self.saved_data.rider_id == nil then
		return
	end
	self:check_unmount()
end

function comp.on_physics_update(self, delta)
	if self.saved_data.rider_id == nil then
		return
	end
	self.pbody:set_gravity_scale(0)
	self:move(delta)
end

return M
