---@meta

---@class ladder_core
---@field LADDER_CHECK_Y_SHIFT number
---@field is_in_ladder_range fun(x: number, y: number, z: number, ladder_tag: string): boolean
---@field check_ladder fun(pid: integer, ladder_tag: string, entity_name: string, component_name: string)
---@field get_ladder_block_str_id fun(x: number, y: number, z: number): string
