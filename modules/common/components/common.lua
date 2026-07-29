local M = {}

---@param SAVED_DATA table
---@param ARGS table
---@param default_params table
function M.new_param_initializer(SAVED_DATA, ARGS, default_params)
	---@param name string
	---@return any
	function init_func(name)
		local res = SAVED_DATA[name] or ARGS[name] or default_params[name]
		SAVED_DATA[name] = res
		return res
	end
	return init_func
end

M.DUMMY_FUNCTIONS_NAMES = {
	"on_despawn",
	"on_grounded",
	"on_fall",
	"on_save",
	"on_update",
	"on_physics_update",
	"on_render",
	"on_sensor_enter",
	"on_sensor_exit",
	"on_aim_on",
	"on_aim_off",
	"on_attacked",
	"on_used",
	"on_player_set",
}

---@param comp comp
function M.create_dummies(comp)
	for _, fname in ipairs(M.DUMMY_FUNCTIONS_NAMES) do
		if comp[fname] == nil then
			comp[fname] = function() end
		end
	end
end

---@param comp comp
---@param SAVED_DATA table
---@param ARGS table
---@param defaults table
function M.override_functions(comp, SAVED_DATA, ARGS, defaults)
	for k, v in pairs(defaults) do
		if k ~= "init" and type(v) == "function" then
			comp[k] = SAVED_DATA[k] or ARGS[k] or defaults[k] or comp[k]
			if comp[k] == nil then
				debug.error("function " .. k .. " not found for entity " .. comp.entity:def_name())
			end
		end
	end
end

---@param comp comp
---@param component_name string
---@return table functions, table params
function M.get_entity_defaults(comp, component_name)
	local ename = comp.entity:def_name()
	local sep_index = string.find(ename, ":")

	local success, defaults = pcall(function()
		return require(
			string.sub(ename, 1, sep_index)
				.. "seat_commons/"
				.. component_name
				.. "/"
				.. string.sub(ename, sep_index + 1)
		)
	end)
	if not success then
		return {}, {}
	end
	if type(defaults) == "table" then
		return {}, defaults
	elseif type(defaults) == "function" then
		defaults = defaults(comp)
		return defaults, defaults.params or {}
	end
	return {}, {}
end

---@param comp comp
---@return table functions, table params
function M.get_block_defaults(comp, component_name)
	local bid = comp.saved_data.block_str_id or comp.args.block_str_id
	local sep_index = string.find(bid, ":")

	local import_path = string.sub(bid, 1, sep_index)
		.. "seat_commons/"
		.. component_name
		.. "/"
		.. string.sub(bid, sep_index + 1)
	local success, defaults = pcall(function()
		return require(import_path)
	end)
	if not success then
		return {}, {}
	end
	if type(defaults) == "table" then
		return {}, defaults
	elseif type(defaults) == "function" then
		defaults = defaults(comp)
		return defaults, defaults.params or {}
	end
	return {}, {}
end

---@param entity voxelcore.class.entity
---@param SAVED_DATA table
---@param ARGS table
---@param base_comp table
---@return table
function M.new(entity, SAVED_DATA, ARGS, base_comp)
	local comp = table.copy(base_comp)
	comp.entity = entity
	comp.tsf = entity.transform
	comp.body = entity.rigidbody
	comp.rig = entity.skeleton
	comp.saved_data = SAVED_DATA
	comp.args = ARGS
	return comp
end

return M
