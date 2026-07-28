local comp = require("seat_commons:api/v1/components/seat")
local self = comp.new(entity, SAVED_DATA, ARGS)

self:on_spawn()

function on_save()
	self:on_save()
end

function on_despawn()
	self:on_despawn()
end

function on_attacked(entity_id, pid)
	self:on_attacked(entity_id, pid)
end

function on_used(pid)
	self.on_used(self, pid)
end

function on_update(tps)
	self:on_update(tps)
end

function on_render(delta)
	self:on_render(delta)
end
