---@type ladder_core
local ladder = require("vehicle_api:core/ladder")

function on_player_tick(pid, _)
	ladder.check_ladder(pid)
end
