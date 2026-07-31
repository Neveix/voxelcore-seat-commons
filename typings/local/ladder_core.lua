---@meta

---@class ladder_core
---@field LADDER_CHECK_Y_SHIFT number
---@field is_in_ladder_range fun(pl_pos: vec3, block_id: integer): boolean
---@field check_ladder fun(pid: integer, ladder_tag: string, entity_name: string, component_name: string)
---@field get_ladder_check_pos fun(pl_pos: vec3): vec3
---@field is_close_to_ladder fun(x: number, z: number, rx: number, rz: number, rot: integer): boolean
