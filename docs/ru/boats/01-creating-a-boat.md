# 01. Создание стандартной лодки

Чтобы добавить лодку в ваш контент-пак, необходимо добавить компонент `intcom:boat` 
в определение вашей сущности.

См. [Руководство по созданию сущности](../common/creating-an-entity.md) для общего объяснения переопределений.

---

## Пример: Минимальная лодка

**`entities/my_boat.json`:**

```json
{
  "components": [
    "intcom:boat"
  ],
  "body-type": "dynamic",
  "hitbox": [
    1.125,
    0.375,
    1.125
  ],
  "solid": true,
  "mass": 30,
  "elasticity": 0.3
}
```

Компонент `intcom:boat` предоставляет:
- Физику и плавучесть
- Посадку игрока (через RideableAPI)
- Управление движением (WASD)

---

## Настройка

Чтобы настроить лодку, создайте файл модуля:

```
modules/intcom/boat/<имя_вашей_лодки>.lua
```

### Переопределение параметров

**Пример `modules/intcom/boat/my_boat.lua`:**

```lua
return {
    max_speed = 10,
    acceleration = 0.07,
}
```

### Переопределение функций

**Пример:**

```lua
local C = {}

function C.init(super)
    C.super = super
    C.super_funcs = {
        on_used = super.on_used
    }
    return C
end

function C.on_used(self, pid)
    console.chat("on used overridden!")
    C.super_funcs.on_used(self, pid)
end

C.params = {
    max_speed = 7,
}

return C.init
```

---

## Доступные функции для переопределения

| Функция | Описание |
| :--- | :--- |
| `on_spawn(self)` | Вызывается при появлении лодки |
| `on_save(self)` | Вызывается при сохранении лодки |
| `on_despawn(self)` | Вызывается при уничтожении лодки |
| `on_attacked(self, entity_id, pid)` | Вызывается при атаке лодки |
| `player_unmount(self)` | Вызывается при выходе игрока из лодки |
| `player_mount(self, pid)` | Вызывается при посадке игрока в лодку |
| `open_inventory(self)` | Открывает инвентарь лодки |
| `on_used(self, pid)` | Вызывается при взаимодействии игрока с лодкой |
| `check_unmount(self)` | Проверяет, должен ли игрок выйти из лодки |
| `tp_player(self)` | Телепортирует игрока на позицию лодки |
| `move(self)` | Обрабатывает физику движения |
| `spawn_move_water_splashes(self)` | Создаёт брызги воды при движении |
| `spawn_fall_water_splashes(self)` | Создаёт брызги воды при падении |
| `handle_water_behaviour(self)` | Обрабатывает физику воды |
| `on_update(self, tps)` | Вызывается каждый тик |
| `on_render(self, delta)` | Вызывается каждый кадр (для визуальных обновлений) |

Для проверки реализаций см. `intcom:modules/api/v1/components/boat.lua`.

---

## Доступные параметры

| Параметр | Тип | По умолчанию | Описание |
| :--- | :--- | :--- | :--- |
| `gravity` | `number` | `1` | Множитель гравитации для лодки |
| `max_speed` | `number` | `7` | Максимальная скорость вперёд |
| `rotation_acceleration` | `number` | `0.02` | Ускорение поворота |
| `rotation_deceleration` | `number` | `0.003` | Замедление поворота |
| `max_rotation_speed` | `number` | `1` | Максимальная скорость поворота |
| `max_ground_rotation_speed` | `number` | `0.2` | Максимальная скорость поворота на земле |
| `turn_velocity_dependency` | `number` | `0` | Насколько поворот зависит от скорости (0-1) |
| `roll_speed` | `number` | `0.1` | Скорость анимации крена |
| `max_roll` | `number` | `0` | Максимальный угол крена (в градусах) |
| `roll_lift` | `number` | `0` | Насколько крен поднимает лодку |
| `bottom_y_shift` | `number` | `-0.11` | Вертикальное смещение нижней точки |
| `acceleration` | `number` | `0.04` | Множитель ускорения вперёд |
| `water_splashes_number` | `integer` | `4` | Количество частиц брызг воды |
| `water_splashes_width` | `number` | `1` | Ширина эффекта брызг воды |
| `inventory_size` | `integer` | `0` | Размер инвентаря (0 = нет инвентаря) |
| `layout_id` | `string or nil` | `nil` | ID макета инвентаря |
| `player_pos_shift` | `vec3` | `{0, 0.8, 0}` | Смещение всадника относительно центра сущности |
