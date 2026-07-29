# 02. Custom Boat component

If you need custom behavior for a whole class of boats in your content pack,
you can create your own component based on the default `seat_commons:boat`
implementation.

This is useful when you want other developers to be able to use your enhanced component.

---

## Creating a Custom component

Create a file in your content pack:

```
scripts/components/<your_component_name>.lua
```

**Example `scripts/components/my_boat.lua`:**

```lua
local boat_comp = require("seat_commons:api/v1/components/boat")
local self = boat_comp.new(entity, SAVED_DATA, ARGS)

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


## Using Your Custom component

In your entity definition, reference your custom component instead of
`seat_commons:boat`:

**Example `entities/my_boat.json`:**

```json
{
  "components": [
    "my_pack:my_boat"
  ],
  "body-type": "dynamic",
  "hitbox": [
    1.125,
    0.375,
    1.125
  ],
  "solid": true,
  "mass": 30,
  "elasticity": 0.3
}
```

---

## When to Use This vs. Simple Overrides

| Approach | When to use |
| :--- | :--- |
| **Simple Overrides** (`modules/seat_commons/boat/`) | You want to change behavior for a **specific boat type** in your pack |
| **Custom component** (`scripts/components/`) | You want to create a **new reusable component** that others can use |
