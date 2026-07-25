
## 2. Custom Boat Script

If you need custom behavior (e.g., adding a horn, custom interactions),
create your own component that inherits from VehicleAPI's boat logic.

**Example `scripts/components/my_boat.lua`:**

```lua
local boat = require("vehicle_api:boat")

-- Call the parent logic
local M = boat()

-- Override or extend methods
function M:on_used(pid)
    -- Custom interaction
    console.chat("Custom boat used!")
    -- Call parent logic (mounting)
    M.parent.on_used(self, pid)
end

function M:on_update(dt)
    -- Custom update logic
    M.parent.on_update(self, dt)
end

return M
```

**Entity definition:**

```json
{
  "components": [
    "my_pack:my_boat"
  ]
}
```

This approach keeps your custom logic separate while reusing
the core physics and mounting system.

---
