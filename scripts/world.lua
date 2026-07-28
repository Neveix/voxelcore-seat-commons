---@type ladder_core
local ladder = require("seat_commons:api/v1/core/ladder")

function on_player_tick(pid, _)
	ladder.check_ladder(pid, "seat_commons:ladder")
end
