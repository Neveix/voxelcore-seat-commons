---@type rideable_api
local rideable_api = require("rideable_api:api/v1/mount")
require("seat_commons:common/utils")
local common_comp = require("seat_commons:common/components/common")
---@type ladder_core
local ladder = require("seat_commons:common/core/ladder")

local M = {}

---@type LadderComp
---@diagnostic disable-next-line: missing-fields
local comp = {}

M.comp = comp

---@param SAVED_DATA table
---@param ARGS table
---@param default_params table
function M.calc_params(SAVED_DATA, ARGS, default_params)
	local piniter = common_comp.new_param_initializer(SAVED_DATA, ARGS, default_params)
	local p = {}
	p.max_speed = piniter("max_speed") or 4
	p.acceleration = piniter("acceleration") or 1
	p.vert_acceleration = piniter("vert_acceleration") or 20
	return p
end

---@param entity voxelcore.class.entity
---@param SAVED_DATA table
---@param ARGS table
---@return LadderComp
function M.new(entity, SAVED_DATA, ARGS)
	local component_name = "ladder"
	local new_comp = common_comp.new(entity, SAVED_DATA, ARGS, comp, component_name)
	local _, def_params = common_comp.get_entity_defaults(new_comp, component_name)
	new_comp.p = M.calc_params(SAVED_DATA, ARGS, def_params)
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
	pbody:set_gravity_scale(self.player_stored.gravity_scale)
	pbody:set_linear_damping(self.player_stored.linear_damping)
	pbody:set_vdamping(self.player_stored.vdamping)
	pbody:set_elasticity(self.player_stored.elasticity)
end

function comp.on_spawn(self)
	self.body:set_gravity_scale(0)
	self.saved_data.rider_id = self.saved_data.rider_id or self.args.rider_id
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
	local acc = delta * self.p.acceleration
	local v_acc = delta * self.p.vert_acceleration
	local max_speed = self.p.max_speed

	self.pbody:set_gravity_scale(0)

	if input.is_active("movement.cheat") then
		local mod = 10
		acc = acc * mod
		v_acc = v_acc * mod
		max_speed = max_speed * mod
		self.pbody:set_linear_damping(1)
		self.pbody:set_vdamping(5)
	else
		self.pbody:set_linear_damping(10)
		self.pbody:set_vdamping(1)
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
