# 01. Creating a Ladder

To add a ladder to your content pack, you need to add the `intcom:ladder` tag
to your block definition.

See the [Creating an Entity Guide](../common/creating-an-entity.md) for a general explanation of overrides.

---

## Example: Minimal Ladder

**`blocks/ladder.json`:**

```json
{
  "model": "custom",
  "model-name": "ladder",
  "rotation": "pane",
  "caption": "ladder",
  "hitbox": [
    0.125,
    0,
    0,
    0.75,
    1,
    0.125
  ],
  "sky-light-passing": true,
  "solid": false,
  "light-passing": true,
  "tags": [
    "intcom:ladder"
  ]
}
```

**Required fields:**

| Field | Value | Description |
| :--- | :--- | :--- |
| `tags` | `["intcom:ladder"]` | Required to identify this block as a ladder |

---


## Customization

### Double Sided Ladder

Simply add a tag to tags field of your ladder:
```json
{
  "tags": [
    "intcom:ladder",
    "intcom:double_sided_ladder"
  ]
}
```

### Deeper Customization

To customize a ladder's behavior, create a module file in your content pack:

```
modules/intcom/ladder/<your_ladder_name>.lua
```

The `<your_ladder_name>` should match the name used in your block definition.

---

### Overriding Parameters

**Example `modules/intcom/ladder/ladder.lua`:**

```lua
return {
    linear_damping = 20,
}
```

All parameters are optional. If omitted, default values are used.

See the [Available Parameters](#available-parameters) section below for full list.

---

### Overriding Functions

**Example:**

```lua
local C = {}

---@param super ladder_comp
function C.init(super)
    C.super = super
    C.super_funcs = {
        player_mount = super.player_mount,
    }
    return C
end

function C.player_mount(self)
    C.super_funcs.player_mount(self)
end

C.params = {
    linear_damping = 20,
}

return C.init
```

---

## Available Functions for Override

| Function | Description |
| :--- | :--- |
| `on_spawn(self)` | Called when the ladder entity spawns |
| `on_despawn(self)` | Called when the ladder entity is destroyed |
| `player_mount(self)` | Called when a player mounts the ladder |
| `player_unmount(self)` | Called when a player unmounts from the ladder |
| `player_start_unmount(self)` | Starts the unmount process |
| `save_player_body_settings(self)` | Saves player physics settings before mounting |
| `load_player_body_settings(self)` | Restores player physics settings after unmounting |
| `move(self, delta)` | Handles ladder movement and input |
| `check_unmount(self)` | Checks if the player should unmount (e.g., noclip, flight) |
| `get_tag_name(self)` | Returns the block tag used to identify the ladder |
| `on_update(self, tps)` | Called every tick |
| `init_step_sounds(self, delta)` | Called in on_spawn. |
| `play_step_sounds(self, delta)` | Called in on_update to play step sounds |

For reference implementations, see `intcom:modules/api/v1/components/ladder.lua`.

---

## Available Parameters

| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `max_speed_xz` | `number` | `1.5` | Maximum horizontal climbing speed (normal mode) |
| `max_speed_xz_cheat` | `number` | `50` | Maximum horizontal climbing speed (cheat/fast mode) |
| `max_speed_y` | `number` | `2` | Maximum vertical climbing speed (normal mode) |
| `max_speed_y_cheat` | `number` | `80` | Maximum vertical climbing speed (cheat/fast mode) |
| `linear_damping` | `number` | `10` | Damping applied to horizontal movement while on ladder |
| `linear_damping_cheat` | `number` | `2` | Horizontal damping in cheat/fast mode |
| `vdamping` | `number` | `0.5` | Vertical damping while climbing |
| `vdamping_cheat` | `number` | `0.2` | Vertical damping in cheat/fast mode |
| `vert_acceleration` | `number` | `10` | Vertical acceleration while climbing |
| `vert_acceleration_cheat` | `number` | `100` | Vertical acceleration in cheat/fast mode |
| `gravity` | `number` | `0` | Gravity applied to the player while on ladder (0 = no gravity) |
