local comp = require("intcom:api/v1/components/ladder_dummy")
local self = comp.new(entity, SAVED_DATA, ARGS)

self:on_spawn()

function on_save()
	self:on_save()
end

function on_despawn()
	self:on_despawn()
end

function on_grounded(force)
	self:on_grounded(force)
end

function on_fall()
	self:on_fall()
end

function on_attacked(entity_id, pid)
	self:on_attacked(entity_id, pid)
end

function on_used(pid)
	self:on_used(pid)
end

function on_update(tps)
	self:on_update(tps)
end

function on_physics_update(delta)
	self:on_physics_update(delta)
end

function on_render(delta)
	self:on_render(delta)
end

function on_sensor_enter(index, entity_uid)
	self:on_sensor_enter(index, entity_uid)
end

function on_sensor_exit(index, entity_uid)
	self:on_sensor_exit(index, entity_uid)
end

function on_aim_on(playerid)
	self:on_aim_on(playerid)
end

function on_aim_off(playerid)
	self:on_aim_off(playerid)
end

function on_player_set(playerid)
	self:on_player_set(playerid)
end
