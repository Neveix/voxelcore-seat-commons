# 01. Создание стула

Чтобы добавить сиденье в ваш контент-пак, вам нужно добавить тег `intcom:seat`
в определение вашего блока и создать небольшой скрипт.

Общее объяснение переопределений см. в [Руководстве по созданию сущностей](../common/creating-an-entity.md).

---

## Пример: Минимальный стул

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
    "intcom:seat"
  ]
}
```

**Обязательные поля:**

| Поле | Значение | Описание |
| :--- | :--- | :--- |
| `script-name` | `<имя_вашего_скрипта>` | Имя файла Lua-скрипта |
| `tags` | `["intcom:seat"]` | Необходимо для идентификации этого блока как сиденья |

---

## Шаг 2: Создание скрипта

Создайте `scripts/<имя_вашего_скрипта>.lua`:

```lua
---@type seat_item_utils
local seat_item_utils = require("intcom:api/v1/item_utils/seat")

function on_interact(x, y, z, pid)
    return seat_item_utils.try_sit_player(x, y, z, pid)
end
```

Функция `try_sit_player()` обрабатывает всю логику посадки:
- Проверяет, является ли блок допустимым сиденьем
- Сажает игрока через RideableAPI
- Позиционирует игрока на сиденье

---

## Настройка

Чтобы настроить поведение стула, создайте файл модуля:

```
modules/intcom/seat/<имя_вашего_блока>.lua
```

### Переопределение параметров

**Пример `modules/intcom/seat/chair.lua`:**

```lua
return {
    player_pos_shift_after_unmount = { 0.8, 3.9, 0 }
}
```

### Переопределение функций

**Пример:**

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

## Доступные функции для переопределения

| Функция | Описание |
| :--- | :--- |
| `on_spawn(self)` | Вызывается при появлении сущности стула |
| `player_mount(self, pid)` | Вызывается, когда игрок садится на стул |
| `player_unmount(self)` | Вызывается, когда игрок встаёт со стула |
| `tp_player(self)` | Телепортирует игрока на позицию стула |
| `check_unmount(self)` | Проверяет, должен ли игрок встать (например, по клавише красться) |
| `check_destroyed(self)` | Проверяет, существует ли блок, и снимает игрока, если блок уничтожен |
| `get_tag_name(self)` | Возвращает тег, используемый для идентификации сиденья |
| `on_update(self, tps)` | Вызывается каждый тик |

Реализации см. в `intcom:modules/api/v1/components/seat.lua`.

---

## Доступные параметры

| Параметр | Тип | По умолчанию | Описание |
| :--- | :--- | :--- | :--- |
| `enable_noclip` | `boolean` | `false` | Включать ли noclip при начале сидения |
| `player_pos_shift` | `vec3` | `{0.2, 0.8, 0}` | Смещение игрока относительно центра стула во время сидения |
| `player_pos_shift_after_unmount` | `vec3` | `{0.8, 0.9, 0}` | Позиция, куда игрок телепортируется после вставания |
