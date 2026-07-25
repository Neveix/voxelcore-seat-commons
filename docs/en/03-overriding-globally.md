# 03. Overriding Default Behavior Globally

Content packs can override the default behavior of boat functions globally.
This affects **all** boats in the game, regardless of which pack they come from.

This is useful when you want to:
- Add global mechanics (e.g., all boats play a sound when used)
- Fix bugs or change default behavior across the entire game
- Extend functionality without modifying individual components

---

## How It Works

1. Get the default boat component module via `require("vehicle_api:components/boat")`.
2. Access the internal function table `C`.
3. Replace any function with your own implementation.
4. Store a reference to the original function if you need to call it.

---

## Example: Global `on_used` Override

Create `scripts/world.lua` in your content pack:

```lua
local boat_comp = require("vehicle_api:components/boat")
local C = boat_comp.C

function on_world_open()
    local super_on_used = C.on_used
    console.chat("global function overridden!")

    C.on_used = function(self, pid)
        console.chat("global overridden function used!")
        super_on_used(self, pid)
    end
end
```

### What happens

- The `on_world_open()` event is triggered when the world loads.
- The default `C.on_used` is replaced with a custom version.
- The custom version logs a message and then calls the original function.

---

## Important Notes

### Event Timing

Global overrides should be applied **when the world opens**, not at the top level of the file.

✅ **Correct:**
```lua
function on_world_open()
    C.on_used = function(self, pid)
        -- custom logic
    end
end
```

❌ **Incorrect:**
```lua
-- This may run before vehicle_api is fully loaded
C.on_used = function(self, pid)
    -- custom logic
    end
```

### Preserving Original Functions

Always store a reference to the original function before overriding it.
This allows you to call the original implementation when needed.

```lua
local super_on_used = C.on_used
C.on_used = function(self, pid)
    -- custom logic
    super_on_used(self, pid)  -- call original
end
```

### Scope

Global overrides affect **all** boats in the game, including those from other packs.
Use this feature carefully, especially when distributing your pack to others.

---

## Use Cases

| Scenario | Example |
| :--- | :--- |
| **Global logging** | Log every time a boat is used for debugging |
| **Security** | Prevent players from using boats in restricted areas |
| **Game mechanics** | Add a global speed limit or fuel system |
| **Sound effects** | Play a global sound when any boat spawns |

---

## Available Functions

For a full list of functions available for override, see the
[Available Functions](./01-creating-a-standard-boat.md#available-functions-for-override)
section in the "Creating a Standard Boat" guide.
