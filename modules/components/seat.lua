---@type rideable_api
local rideable_api = require("rideable_api:mount")
require("utils")
local common_comp = require("components/common")

local M = {}

---@diagnostic disable: missing-fields
---@type SeatComp
local comp = {}
---@diagnostic enable: missing-fields

M.comp = comp

---@param SAVED_DATA table
---@param ARGS table
---@param default_params table
function M.calc_params(SAVED_DATA, ARGS, default_params)
	local piniter = common_comp.new_param_initializer(SAVED_DATA, ARGS, default_params)
	local p = {}
	p.player_pos_shift = piniter("player_pos_shift") or { 0.2, 1.5, 0 }
	p.player_pos_shift_after_unmount = piniter("player_pos_shift_after_unmount") or { 0.2, 2, 0 }
	return p
end

---@param entity voxelcore.class.entity
---@param SAVED_DATA table
---@param ARGS table
---@return SeatComp
function M.new(entity, SAVED_DATA, ARGS)
	local component_name = "seat"
	local new_comp = common_comp.new(entity, SAVED_DATA, ARGS, comp, component_name)
	local _, def_params = common_comp.get_entity_defaults(new_comp, component_name)
	new_comp.p = M.calc_params(SAVED_DATA, ARGS, def_params)
	return new_comp
end

------------------------------ SAVE / SPAWN / DESPAWN -------------------------

function comp.player_unmount(self)
	local pos = self.tsf:get_pos()
	-- pos = vec3.add(pos, self.p.player_pos_shift_after_unmount)
	pos = self:calc_rotated_shifted_pos(self.p.player_pos_shift_after_unmount)
	player.set_pos(self.saved_data.rider_id, pos[1], pos[2], pos[3])
	self.entity:despawn()
end

function comp.player_mount(self)
	local rider_id = self.saved_data.rider_id
	rideable_api.mount(rider_id, self.entity:get_uid(), nil, function()
		self:player_unmount()
	end)
end

------

function comp.on_spawn(self)
	self.saved_data.rider_id = self.saved_data.rider_id or self.args.rider_id
	self.body:set_gravity_scale(0)
	if self.saved_data.rider_id then
		self:player_mount(self.saved_data.rider_id)
	else
		rideable_api.unmount(self.saved_data.rider_id)
	end
end

------------------------------ PERIODICAL EVENTS ------------------------------

function comp.calc_rotated_shifted_pos(self, shift)
	local pos = self.tsf:get_pos()
	local rot = block.get_rotation(pos[1], pos[2], pos[3])
	local rotated_shift = vec2.rotate({
		shift[1],
		shift[3],
	}, (rot + 1) % 4 * 90)
	return vec3.add(pos, {
		-rotated_shift[1],
		shift[2],
		rotated_shift[2],
	})
end

function comp.tp_player(self)
	local rider_id = self.saved_data.rider_id
	if rider_id == nil then
		return
	end
	local pos = self.tsf:get_pos()
	pos = self:calc_rotated_shifted_pos(self.p.player_pos_shift)
	player.set_pos(rider_id, pos[1], pos[2], pos[3])
	player.set_vel(rider_id, 0, 0, 0)
end

function comp.check_unmount(self)
	if input.is_active("movement.crouch") then
		rideable_api.unmount(self.saved_data.rider_id)
	end
end

function comp.get_tag_name(_)
	return "seat_commons:seat"
end

function comp.check_destroyed(self)
	local pos = self.tsf:get_pos()
	pos = {
		math.floor(pos[1]),
		math.floor(pos[2]),
		math.floor(pos[3]),
	}
	local block_id = block.get(pos[1], pos[2], pos[3])
	if not block.has_tag(block_id, self:get_tag_name()) then
		rideable_api.unmount(self.saved_data.rider_id)
	end
end

function comp.on_update(self)
	self:check_unmount()
	self:check_destroyed()
end

function comp.on_render(self)
	self:tp_player()
end

return M
