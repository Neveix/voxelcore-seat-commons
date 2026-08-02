---@type ladder_core
local ladder = require("intcom:api/v1/core/ladder")

function on_player_tick(pid, _)
	ladder.check_ladder(pid, "intcom:ladder", "intcom:ladder_dummy", "intcom:ladder_dummy")
end
