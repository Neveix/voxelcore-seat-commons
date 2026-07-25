# 1. Creating a Standard Boat

To add a standard boat to your content pack, create an entity definition.

**Example `entities/my_boat.json`:**

```json
{
  "components": [
    "vehicle_api:boat"
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

The `vehicle_api:boat` component provides:
- Physics and buoyancy
- Player mounting (via RideableAPI)
- Movement controls (WASD)

---

## Parameters

You can override default parameters by creating a module file in your content pack.

**Create `modules/vehicle_api/boat/<your_boat_name>.lua`:**

```lua
return {
	get = function()
		return {
			gravity = 1,
			max_speed = 7,
			rotation_acceleration = 0.02,
			rotation_deceleration = 0.003,
			max_rotation_speed = 1,
			max_ground_rotation_speed = 0.2,
			turn_velocity_dependency = 0,
			roll_speed = 0.1,
			max_roll = 0,
			roll_lift = 0,
			bottom_y_shift = 0,
			acceleration = 0.04,
			water_splashes_number = 3,
			water_splashes_width = 1,
			inventory_size = 0,
			layout_id = nil,
			player_pos_shift = {0, 0.8, 0},
		}
	end,
}
```

All parameters are optional. If omitted, default values are used.

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
| `bottom_y_shift` | `number` | `0` | Vertical shift of the bottom point |
| `acceleration` | `number` | `0.04` | Forward acceleration multiplier |
| `water_splashes_number` | `integer` | `3` | Number of water splash particles |
| `water_splashes_width` | `number` | `1` | Width of water splash effect |
| `inventory_size` | `integer` | `0` | Inventory size |
| `layout_id` | `string or nil` | `nil` | Inventory layout ID (nil = no inventory) |
| `player_pos_shift` | `vec3` | `{0, 0.8, 0}` | Offset of the rider relative to entity center |

---

## Notes

- The module file path is `modules/vehicle_api/boat/<your_boat_name>.lua`
- The `<your_boat_name>` should match your entity name
- All parameters are optional — only define what you need to change
