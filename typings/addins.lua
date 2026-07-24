---@meta

---@class random
random = {}

---@return number
function random.random() end

---@class vec2
vec2 = {}

--- Returns the vector rotated by an angle in degrees counterclockwise.
---@overload fun(v: vec2, angle: number, dst: vec2): vec2
---@param v vec2
---@param angle number Angle in degrees (counterclockwise)
---@param dst vec2|nil Destination vector (if provided, modifies it instead of creating new)
---@return vec2
function vec2.rotate(v, angle, dst) end

---@class voxelcore.class.entity.rigidbody
---@field get_vdamping fun(self: voxelcore.class.entity.rigidbody): number Возвращает множитель вертикального затухания скорости
---@field is_vdamping fun(self: voxelcore.class.entity.rigidbody): bool Проверяет, включено ли вертикальное затухание скорости
--- Включает/выключает вертикальное затухание скорости ИЛИ устанавливает множитель вертикального затухания скорости
---@overload fun(self: voxelcore.class.entity.rigidbody, value: bool)
---@overload fun(self: voxelcore.class.entity.rigidbody, value: number)
---@field set_vdamping fun(self: voxelcore.class.entity.rigidbody, value: bool|number)
---@field get_gravity_scale fun(self: voxelcore.class.entity.rigidbody): number Возвращает множитель гравитации

---@class voxelcore.libentities Библиотека предназначена для работы с реестром сущностей.
---@field def_index fun(name: string): int Возвращает индекс определения сущности по имени (числовой ID)
