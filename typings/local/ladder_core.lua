---@meta

---@class ladder_core
---@field LADDER_ID integer
---@field LADDER_CHECK_Y_SHIFT number
---@field LADDER_DUMMY_Y_SHIFT number
---@field get_pos_for_ladder_entity fun(x: number, y: number, z: number): number[]
---@field is_in_ladder_range fun(x: number, y: number, z: number): boolean
---@field check_ladder fun(pid: integer)
