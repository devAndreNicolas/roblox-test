--!strict
return function(feature: Instance): number
	local State = require(feature:FindFirstChild("PresentationState") :: ModuleScript)
	local base: any = {
		kind = "Snapshot",
		matchId = 4,
		phase = "LobbyWaiting",
		isParticipant = false,
		isQueued = false,
		isFirstMatch = true,
		timeRemaining = 8,
		minimumPlayers = 2,
		waitingPlayers = 1,
		calledNumbers = {},
		callIntervalSeconds = 5,
		phaseDurationSeconds = 8,
	}
	local checks = 0
	for _, phase in { "LobbyWaiting", "LobbyCountdown", "MatchIntro", "CallingNumbers", "RoundComplete" } do
		for _, queued in { false, true } do
			local data = table.clone(base)
			data.phase = phase
			data.isQueued = queued
			local model = State.Derive(data, {})
			assert(model.view == "Lobby" and model.sceneKey == nil)
			if phase == "LobbyCountdown" and not queued then
				assert(string.find(model.title, "this round"))
			end
			checks += 1
		end
	end
	base.phase = "MatchIntro"
	base.isParticipant = true
	assert(State.Derive(base, {}).sceneDuration == 8)
	base.isFirstMatch = false
	assert(State.Derive(base, {}).sceneDuration == 3)
	base.timeRemaining = 1
	assert(State.Derive(base, {}).sceneDuration == 1)
	assert(not State.Derive(base, { ["4:intro"] = true }).sceneActive)
	base.phase = "CallingNumbers"
	assert(State.Derive(base, {}).view == "Match" and State.Derive(base, {}).sceneKey == nil)
	base.phase = "RoundComplete"
	assert(State.Derive(base, {}).view == "Results")
	assert(not State.Derive(base, { ["4:result"] = true }).sceneActive)
	assert(State.Derive(nil, {}).view == "Lobby")
	return checks + 8
end
