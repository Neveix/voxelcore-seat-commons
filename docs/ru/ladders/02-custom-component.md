# 02. Пользовательский компонент лестницы

Общее объяснение см. в [Руководстве по созданию пользовательских компонентов](../common/custom-component.md).

Имя компонента — `ladder_dummy`

После создания вашего пользовательского компонента добавьте это в world.lua:
```lua
---@type ladder_core
local ladder = require("intcom:api/v1/core/ladder")

function on_player_tick(pid, _)
	ladder.check_ladder(pid, "<pack_id>:<ladder_tag_name>", "<pack_id>:<ladder_entity_name>", "<pack_id>:<ladder_component_name>")
end
```

И создайте вашу новую пользовательскую сущность, например `ladder_dummy` из `InteractiveCommons`,
и дайте ей ваш пользовательский компонент:
```json
{
  "components": [
    "<pack_id>:<component_name>"
  ],
}
```

---

## Ссылки

- [Доступные функции](./01-creating-a-ladder.md#available-functions-for-override)
- [Доступные параметры](./01-creating-a-ladder.md#available-parameters)