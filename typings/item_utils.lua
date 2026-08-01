---@meta

---@class seat_item_utils
---@field sit_reach number
---@field sit_player fun(x: integer, y: integer, z: integer, pid: integer) Place player pid on the block with coordinates x, y, z
---@field try_sit_player fun(x: integer, y: integer, z: integer, pid: integer): boolean Check distance of reach and do self.sit_player, returns success
