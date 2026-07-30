# 03. Overriding Default Behavior Globally

Content packs can override the default behavior of boat functions globally.
This affects **all** boats in the game, regardless of which pack they come from.

This is useful when you want to:
- Add global mechanics (e.g., all boats play a sound when used)
- Fix bugs or change default behavior across the entire game

---

## How It Works

1. Get the default boat component
2. Access the internal function table `comp`.
3. Replace any function with your own implementation.
4. Store a reference to the original function if you need to call it.

### Default parameters override

1. Get the default boat component
2. Modify `default_param` as you want.

---

## Example: Global `on_used` Override

Create `scripts/world.lua` in your content pack:

```lua
local boat_comp = require("seat_commons:api/v1/components/boat")
local comp = boat_comp.comp

function on_world_open()
	local super_on_used = comp.on_used

	comp.default_params.max_speed = 15
	comp.on_used = function(self, pid)
		console.chat("global overridden function used!")
		super_on_used(self, pid)
	end
end
```

## Important Notes

- Global overrides should be applied **when the world opens** (`on_world_open`), not at the top level of the file.
- Always store a reference to the original function before overriding it.
- Global overrides affect **all** entities of that type, including those from other packs.

