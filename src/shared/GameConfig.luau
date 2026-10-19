--!strict
-- GameConfig
-- Shared settings for the first Bingo MVP.
-- Container: ReplicatedStorage/Shared

local GameConfig = {
	MINIMUM_PLAYERS = 2,
	SOLO_STUDIO_OVERRIDE = true,
	LOBBY_COUNTDOWN_SECONDS = 10,
	CALL_INTERVAL_SECONDS = 1.5,
	RESULT_DURATION_SECONDS = 8,
	MARK_REQUEST_INTERVAL_SECONDS = 0.1,
}

return table.freeze(GameConfig)
