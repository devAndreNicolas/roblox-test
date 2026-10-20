--!strict
local Types = require(game:GetService("ReplicatedStorage").Shared.Features.Bingo.BingoTypes)
local State = {}
export type Model = {
	view: string, title: string, detail: string, count: string,
	sceneKey: string?, sceneDuration: number, sceneActive: boolean,
	snapshot: Types.Snapshot?, seconds: number,
}
function State.Derive(snapshot: Types.Snapshot?, completed: {[string]: boolean}): Model
	local model: Model = {view = "Lobby", title = "Finding your game…", detail = "Connecting to the Bingo club.",
		count = "", sceneDuration = 0, sceneActive = false, snapshot = snapshot, seconds = 0}
	if not snapshot then return model end
	local s = snapshot
	model.seconds = math.ceil(s.timeRemaining)
	model.count = `{s.waitingPlayers} / {s.minimumPlayers} players ready`
	if not s.isParticipant then
		if s.phase == "LobbyCountdown" then
			model.title = if s.isQueued then `Starting in {model.seconds}s` else `Join this round • {model.seconds}s`
			model.detail = if s.isQueued then "You're in! Use the portal again to leave." else "Use the glowing portal before the countdown ends."
		elseif s.phase == "LobbyWaiting" then
			model.title = if s.isQueued then "You're in the queue!" else "Let's play Bingo"
			model.detail = if s.isQueued then `Waiting for {math.max(0, s.minimumPlayers - s.waitingPlayers)} more. Use the portal to leave.`
				else "Walk to the glowing portal. Press E or tap its prompt."
		else
			model.title = if s.isQueued then "You're up next" else "A round is in progress"
			model.detail = if s.isQueued then "Stay in the lobby. Your next round is on its way." else "Use the portal to join the next round."
		end
		return model
	end
	if s.phase == "MatchIntro" then
		model.view = "Intro"; model.sceneKey = `{s.matchId}:intro`
		model.sceneDuration = math.min(if s.isFirstMatch then 8 else 3, s.timeRemaining)
		model.title = if s.isFirstMatch then "Meet your Bingo card" else "Welcome back!"
		model.detail = "Find the number I call. Tap it. Fill every square to win! The star is free."
	elseif s.phase == "RoundComplete" then
		model.view = "Results"; model.sceneKey = `{s.matchId}:result`
		model.sceneDuration = math.min(3, s.timeRemaining)
		model.title = "Round complete"
		model.detail = `Back to the lobby in {model.seconds}s`
	elseif s.phase == "CallingNumbers" then
		model.view = "Match"; model.title = "Your Bingo card"
		model.detail = "Calls auto-advance. Tap called numbers to mark."
	end
	if model.sceneKey then model.sceneActive = not completed[model.sceneKey] and model.sceneDuration > 0 end
	return model
end
return State
