# 01. Creating a Ladder

To add a ladder to your content pack, you need to add the `seat_commons:ladder` tag
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
    "seat_commons:ladder"
  ]
}
```

**Required fields:**

| Field | Value | Description |
| :--- | :--- | :--- |
| `tags` | `["seat_commons:ladder"]` | Required to identify this block as a ladder |

---

## Customization

To customize a ladder's behavior, create a module file in your content pack:

```
modules/seat_commons/ladder/<your_ladder_name>.lua
```

The `<your_ladder_name>` should match the name used in your block definition.

---

### Overriding Parameters

**Example `modules/seat_commons/ladder/ladder.lua`:**

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
| `player_mount(self, pid)` | Called when a player mounts the ladder |
| `player_unmount(self)` | Called when a player unmounts from the ladder |
| `tp_player(self)` | Teleports the player to the ladder position |
| `on_update(self, tps)` | Called every tick |
| `on_render(self, delta)` | Called every frame (for visual updates) |

For reference implementations, see `seat_commons:modules/api/v1/components/ladder.lua`.

---

## Available Parameters

| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `linear_damping` | `number` | `10` | Damping applied to the player's movement while on the ladder |
| `player_pos_shift` | `vec3` | `{0, 0.8, 0}` | Offset of the rider relative to the ladder center while climbing |
| `player_pos_shift_after_unmount` | `vec3` | `{0, 1.0, 0}` | Position the player is teleported to after unmounting |
