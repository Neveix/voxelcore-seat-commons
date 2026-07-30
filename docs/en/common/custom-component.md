# Creating a Custom Component

If you need custom behavior for a whole class of entities in your content pack,
you can create your own component based on the default SeatCommons implementation.

This is useful when you want other developers to be able to use your enhanced component.

---

## Creating a Custom Component

Create a file in your content pack:

```
scripts/components/<your_component_name>.lua
```

**Example:**

```lua
local comp = require("seat_commons:api/v1/components/<entity_type>")
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
    console.chat("component overridden!")
    self:on_used(pid)
end

function on_update(tps)
    self:on_update(tps)
end

function on_render(delta)
    self:on_render(delta)
end
```

Or use full version of it:
```lua
local comp = require("seat_commons:api/v1/components/<entity_type>")
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
```

---


## Using Your Custom Component

In your entity definition, reference your custom component instead of the default one.

**Example:**

```json
{
  "components": [
    "my_pack:my_component"
  ]
}
```

---

## When to Use This vs. Simple Overrides

| Approach | When to use |
| :--- | :--- |
| **Simple Overrides** (`modules/seat_commons/<entity_type>/`) | You want to change behavior for a **specific entity type** in your pack |
| **Custom Component** (`scripts/components/`) | You want to create a **new reusable component** that others can use |
