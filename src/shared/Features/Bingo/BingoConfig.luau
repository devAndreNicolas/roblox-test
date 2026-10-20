--!strict
-- GameConfig
-- Shared settings for the first Bingo MVP.
-- Container: ReplicatedStorage/Shared

local GameConfig = {
	MINIMUM_PLAYERS = 2,
	MAXIMUM_PLAYERS_PER_MATCH = 8,
	SOLO_STUDIO_OVERRIDE = true,
	LOBBY_COUNTDOWN_SECONDS = 10,
	INTRO_CUTSCENE_SECONDS = 8,
	REPEAT_INTRO_SECONDS = 3,
	CALL_INTERVAL_SECONDS = 5,
	RESULT_DURATION_SECONDS = 8,
	MARK_REQUEST_INTERVAL_SECONDS = 0.1,
	-- Free Creator Store prototype track; replace with founder-created music when ready.
	TEMP_JAZZ_SOUND_ID = "rbxassetid://101443293051695",
}

return table.freeze(GameConfig)
