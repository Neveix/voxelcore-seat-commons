# 01. Creating a Standard Boat

To add a boat to your content pack, you need to add the `seat_commons:boat` component 
to your entity definition.

---

## Example: Minimal Boat

**`entities/my_boat.json`:**

```json
{
  "components": [
    "seat_commons:boat"
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

The `seat_commons:boat` component provides:
- Physics and buoyancy
- Player mounting (via RideableAPI)
- Movement controls (WASD)

---

## Customization

To customize a boat, create a module file in your content pack:

```
modules/seat_commons/boat/<your_boat_name>.lua
```

The `<your_boat_name>` should match the component name used in your entity definition.

There are two types of overrides:

1. **Parameters** — simple values like speed, acceleration, etc.
2. **Functions** — custom logic for specific events (e.g., `on_used`, `on_update`)

---

### Overriding Parameters

Return a table with the parameters you want to change.

**Example `modules/seat_commons/boat/my_boat.lua`:**

```lua
return {
    max_speed = 10,
    acceleration = 0.07,
}
```

All parameters are optional. If omitted, default values are used.


See the [Available Parameters](#available-parameters) section below for full list.

---

### Overriding Functions

To override functions, return an initializer function that accepts a `boat_comp` instance (the default implementation).

**Example:**

```lua
local C = {}

function C.init(super)
	C.super = super
  C.super_funcs = {
    on_used = super.on_used
  }
	return C
end

function C.on_used(self, pid)
	console.chat("on used overriden!")
	C.super_funcs.on_used(self, pid)
end

C.params = {
	max_speed = 7,
	rotation_acceleration = 0.01,
	rotation_deceleration = 0.002,
	max_rotation_speed = 0.8,
}

return C.init
```

### How it works

- The initializer receives a `super` table containing the default implementation.
- The returned table should contain:
  - [optional] Overridden functions (e.g., `on_used`, `on_update`)
  - [optional] A `params` field with parameter overrides
- To call the parent implementation, store a reference to the original function
  (e.g., in `C.super_funcs`) and use it later.

```lua
C.super_funcs = {
    on_used = super.on_used
}
```

> ⚠️ **Warning:** Do **not** call `C.super.on_used(self, pid)` directly inside the overridden function, 
as this will cause **infinite recursion** (it calls itself). 
Instead, store the reference separately as shown above.

---

## Available Functions for Override

| Function | Description |
| :--- | :--- |
| `on_spawn(self)` | Called when the boat spawns |
| `on_save(self)` | Called when saving the boat |
| `on_despawn(self)` | Called when the boat is destroyed |
| `on_attacked(self, entity_id, pid)` | Called when the boat is attacked |
| `player_unmount(self)` | Called when a player unmounts |
| `player_mount(self, pid)` | Called when a player mounts |
| `open_inventory(self)` | Opens the boat inventory |
| `on_used(self, pid)` | Called when a player interacts with the boat |
| `check_unmount(self)` | Checks if the player should unmount |
| `tp_player(self)` | Teleports the player to the boat position |
| `move(self)` | Handles movement physics |
| `spawn_move_water_splashes(self)` | Spawns water splashes when moving |
| `spawn_fall_water_splashes(self)` | Spawns water splashes when falling |
| `handle_water_behaviour(self)` | Handles water physics |
| `on_update(self, tps)` | Called every tick |
| `on_render(self, delta)` | Called every frame (for visual updates) |

For reference implementations, see `seat_commons:modules/api/v1/components/boat.lua`.

---

## Available Parameters

| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `gravity` | `number` | `1` | Gravity multiplier for the boat |
| `max_speed` | `number` | `7` | Maximum forward speed |
| `rotation_acceleration` | `number` | `0.02` | Acceleration of rotation |
| `rotation_deceleration` | `number` | `0.003` | Deceleration of rotation |
| `max_rotation_speed` | `number` | `1` | Maximum rotation speed |
| `max_ground_rotation_speed` | `number` | `0.2` | Maximum rotation speed when on ground |
| `turn_velocity_dependency` | `number` | `0` | How much turn depends on velocity (0-1) |
| `roll_speed` | `number` | `0.1` | Speed of roll animation |
| `max_roll` | `number` | `0` | Maximum roll angle (degrees) |
| `roll_lift` | `number` | `0` | How much roll lifts the boat |
| `bottom_y_shift` | `number` | `-0.11` | Vertical shift of the bottom point |
| `acceleration` | `number` | `0.04` | Forward acceleration multiplier |
| `water_splashes_number` | `integer` | `3` | Number of water splash particles |
| `water_splashes_width` | `number` | `1` | Width of water splash effect |
| `inventory_size` | `integer` | `0` | Inventory size (0 = no inventory) |
| `layout_id` | `string or nil` | `nil` | Inventory layout ID |
| `player_pos_shift` | `vec3` | `{0, 0.8, 0}` | Offset of the rider relative to entity center |
