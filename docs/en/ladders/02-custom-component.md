# 02. Custom Ladder Component

For a general explanation, see the [Custom Component Guide](../common/custom-component.md).

Component's name is `ladder_dummy`

After creating your custom component, add this to world.lua:
```lua
---@type ladder_core
local ladder = require("intcom:api/v1/core/ladder")

function on_player_tick(pid, _)
	ladder.check_ladder(pid, "<pack_id>:<ladder_tag_name>", "<pack_id>:<ladder_entity_name>", "<pack_id>:<ladder_component_name>")
end
```

And create your new custom entity, like `ladder_dummy` of `InteractiveCommons`,
and give it your custom component:
```json
{
  "components": [
    "<pack_id>:<component_name>"
  ],
}
```

---

## Links

- [Available Functions](./01-creating-a-ladder.md#available-functions-for-override)
- [Available Parameters](./01-creating-a-ladder.md#available-parameters)
