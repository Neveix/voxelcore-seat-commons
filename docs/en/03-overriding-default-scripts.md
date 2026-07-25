## 3. Overriding Default Scripts

If you want to change the behavior of **all** boats globally,
you can replace a module.

### How it works

1. VehicleAPI loads modules from `modules/`.
2. Components use `require("vehicle_api:module_name")`.
3. The pack system checks your content pack first
   when resolving `vehicle_api:` dependencies.

### Example: Custom boat physics

Create `modules/boat.lua` in your content pack:

```lua
-- Override default boat physics
local M = {}

function M:update(dt)
    -- Custom physics logic
end

return M
```

Your file will be loaded instead of VehicleAPI's default
`modules/boat.lua`.

---

## API Reference

### `vehicle_api:boat`

The main boat component.

**Methods:**

| Method | Description |
| :--- | :--- |
| `on_update(dt)` | Called every frame. Handles physics and movement. |
| `on_used(pid)` | Called when a player interacts with the boat. |
| `mount_player(pid)` | Mounts a player on the boat. |
| `unmount_player(pid)` | Unmounts a player from the boat. |
| `get_speed()` | Returns current speed. |
| `get_forward()` | Returns the forward direction vector. |

---

## See Also

- [RideableAPI Documentation](../rideable-api/docs/en/api.md)
- [Tutorial: Creating a Rideable Vehicle](./tutorial.md)
