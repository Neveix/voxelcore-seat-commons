# 01. Creating a Chair

To add a seat to your content pack, you need to add the `seat_commons:seat` tag
to your block definition and create a small script.

See the [Creating an Entity Guide](../common/creating-an-entity.md) for a general explanation of overrides.

---

## Example: Minimal Chair

**`blocks/chair.json`:**

```json
{
  "model": "custom",
  "model-name": "chair",
  "rotation": "pane",
  "caption": "chair",
  "script-name": "chair",
  "material": "base:wood",
  "sky-light-passing": true,
  "solid": false,
  "light-passing": true,
  "hitbox": [
    0.125,
    0,
    0.125,
    0.75,
    0.625,
    0.75
  ],
  "tags": [
    "seat_commons:seat"
  ]
}
```

**Required fields:**

| Field | Value | Description |
| :--- | :--- | :--- |
| `script-name` | `<your_script_name>` | Name of the Lua script file |
| `tags` | `["seat_commons:seat"]` | Required to identify this block as a seat |

---

## Step 2: Create the Script

Create `scripts/<your_script_name>.lua`:

```lua
---@type seat_item_utils
local seat_item_utils = require("seat_commons:api/v1/item_utils/seat")

function on_interact(x, y, z, pid)
    return seat_item_utils.try_sit_player(x, y, z, pid)
end
```

The `try_sit_player()` function handles all mounting logic:
- Checks if the block is a valid seat
- Mounts the player via RideableAPI
- Positions the player on the seat

---

## Customization

To customize a chair's behavior, create a module file:

```
modules/seat_commons/seat/<your_block_name>.lua
```

### Overriding Parameters

**Example `modules/seat_commons/seat/chair.lua`:**

```lua
return {
    player_pos_shift_after_unmount = { 0.8, 3.9, 0 }
}
```

### Overriding Functions

**Example:**

```lua
local C = {}

function C.init(super)
    C.super = super
    C.super_funcs = {
        player_unmount = super.player_unmount
    }
    return C
end

function C.player_unmount(self)
    console.chat("player unmount overridden!")
    C.super_funcs.player_unmount(self)
end

C.params = {
    player_pos_shift_after_unmount = { 0.8, 3.9, 0 }
}

return C.init
```

---

## Available Functions for Override

| Function | Description |
| :--- | :--- |
| `on_spawn(self)` | Called when the chair entity spawns |
| `player_mount(self, pid)` | Called when a player mounts the chair |
| `player_unmount(self)` | Called when a player unmounts from the chair |
| `tp_player(self)` | Teleports the player to the chair position |
| `check_unmount(self)` | Checks if the player should unmount (e.g., via sneak key) |
| `check_destroyed(self)` | Checks if the block still exists and unmounts if destroyed |
| `get_tag_name(self)` | Returns the tag used to identify the seat |
| `on_update(self, tps)` | Called every tick |

For reference implementations, see `seat_commons:modules/api/v1/components/seat.lua`.

---

## Available Parameters

| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `enable_noclip` | `boolean` | `false` | Whether enable noclip when start sitting |
| `player_pos_shift` | `vec3` | `{0.2, 0.8, 0}` | Offset of the rider relative to the chair center while sitting |
| `player_pos_shift_after_unmount` | `vec3` | `{0.8, 0.9, 0}` | Position the player is teleported to after unmounting |
