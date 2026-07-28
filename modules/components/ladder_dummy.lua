---@type rideable_api
local rideable_api = require("rideable_api:mount")
require("utils")
local common_comp = require("components/common")
---@type ladder_core
local ladder = require("core/ladder")

local unpack = unpack or table.unpack

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
	p.max_speed = piniter("max_speed") or 2.5
	p.acceleration = piniter("acceleration") or 13
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

---@param self LadderComp
---@return voxelcore.class.entity.rigidbody
function M.new_common_body(self)
	---@type voxelcore.class.entity.rigidbody
	local body = table.copy(self.body)
	local pe = entities.get(player.get_entity(self.saved_data.rider_id))
	if pe == nil then
		return body
	end
	local pbody = pe.rigidbody
	local common_funcnames = {
		"get_gravity_scale",
		"set_gravity_scale",
		"get_linear_damping",
		"set_linear_damping",
		"is_vdamping",
		"get_vdamping",
		"set_vdamping",
		"get_vel",
		"set_vel",
	}
	for _, fname in pairs(common_funcnames) do
		body[fname] = function(...)
			if self.saved_data.rider_id == nil then
				return
			end
			local args = { ... }
			local num_args = select("#", ...)
			local result
			if num_args > 1 then
				result = self.body[fname](self.body, unpack(args, 2, num_args))
				pbody[fname](pbody, unpack(args, 2, num_args))
			else
				result = self.body[fname](self.body)
				pbody[fname](pbody)
			end
			return result
		end
	end
	return body
end

------------------------------ SAVE / SPAWN / DESPAWN -------------------------

function comp.player_unmount(self)
	local vel = self.body:get_vel()
	local vel_mod = 1
	if vel[2] > 0.5 then
		vel[2] = vel[2] + 4
	end
	vel[1] = vel[1] * vel_mod
	vel[3] = vel[3] * vel_mod
	player.set_vel(self.saved_data.rider_id, vel[1], vel[2], vel[3])
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
	self:save_player_body_settings()
	self.common_body = M.new_common_body(self)
	self.saved_data.rider_id = self.saved_data.rider_id or self.args.rider_id
	if self.saved_data.rider_id == nil then
		self.entity:despawn()
		return
	end
	if self.saved_data.already_initialized then
		self.entity:despawn()
		return
	end
	self.saved_data.already_initialized = true
	local vx, vy, vz = player.get_vel(self.saved_data.rider_id)
	self.body:set_vel({ vx, vy, vz })
	self.common_body:set_gravity_scale(0)
	self.common_body:set_vdamping(1)
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

	if input.is_active("movement.cheat") then
		local mod = 10
		acc = acc * mod
		v_acc = v_acc * mod
		max_speed = max_speed * mod
		self.common_body:set_linear_damping(1)
	else
		self.common_body:set_linear_damping(5)
	end

	if input.is_active("movement.jump") then
		mov_vec[2] = mov_vec[2] + v_acc
	end

	if input.is_active("movement.crouch") then
		mov_vec[2] = mov_vec[2] - v_acc
	end

	if input.is_active("movement.forward") then
		mov_vec[1] = mov_vec[1] + acc
	end
	if input.is_active("movement.back") then
		mov_vec[1] = mov_vec[1] - acc
	end
	if input.is_active("movement.left") then
		mov_vec[3] = mov_vec[3] - acc
	end
	if input.is_active("movement.right") then
		mov_vec[3] = mov_vec[3] + acc
	end

	local yaw = player.get_rot(self.saved_data.rider_id)
	local rotated = vec2.rotate({ mov_vec[1], mov_vec[3] }, 90 - yaw)
	mov_vec[1] = -rotated[1]
	mov_vec[3] = -rotated[2]

	local vel = self.common_body:get_vel()
	vel = vec3.add(vel, mov_vec)

	local len = vec3.length(vel)
	if len > max_speed then
		vel = vec3.mul(vel, max_speed / math.abs(len))
	end

	self.common_body:set_vel(vel)

	local pos = self.tsf:get_pos()
	if not ladder.is_in_ladder_range(pos[1], pos[2], pos[3]) then
		self:player_start_unmount()
	end
end

function comp.player_start_unmount(self)
	rideable_api.unmount(self.saved_data.rider_id)
end

function comp.sync_pos(self)
	if self.saved_data.rider_id == nil then
		return
	end
	local x, y, z = player.get_pos(self.saved_data.rider_id)
	self.tsf:set_pos({ x, y + ladder.LADDER_DUMMY_Y_SHIFT, z })
end

function comp.check_unmount(self)
	local uid = self.entity:get_uid()
	if player.is_noclip(uid) or player.is_flight(uid) then
		self:player_start_unmount()
		return
	end
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
	self.common_body:set_gravity_scale(0)
	self:move(delta)
end

function comp.on_render(self)
	self:sync_pos()
end

return M
