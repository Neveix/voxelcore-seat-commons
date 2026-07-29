local M = {}

function math.sign(x)
	if x > 0 then
		return 1
	elseif x < 0 then
		return -1
	else
		return 0
	end
end

---@param vec vec3
function vec3.length_sqr(vec)
	return vec[1] * vec[1] + vec[2] * vec[2] + vec[3] * vec[3]
end

return M
