--!strict
-- Studio-only harness. The runner supplies isolated cloned feature folders with fast config.
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local session = game.ReplicatedStorage:WaitForChild("BingoValidationSession")
local original = require(game.ServerScriptService.Server.Features.Bingo.BingoService)
local public = require(game.ServerScriptService.BingoPublicFixture.BingoService)
local fast = require(game.ServerScriptService.BingoFastFixture.BingoService)
local outcomes = {}
local player = Players:GetPlayers()[1]
original.Destroy()
local ok, failure = pcall(function()
	public.Start()
	session:SetAttribute("Stage", "Minimum")
	local waitingDeadline = os.clock() + 12
	repeat
		task.wait(0.1)
		local state = public.GetSnapshot(player)
		if state and state.isQueued then
			assert(state.minimumPlayers == 2 and state.phase == "LobbyWaiting")
			task.wait(0.5)
			assert(public.GetSnapshot(player).phase == "LobbyWaiting")
			session:SetAttribute("MinimumPassed", true)
			break
		end
	until os.clock() >= waitingDeadline
	assert(session:GetAttribute("MinimumPassed"), "client never joined public-minimum queue")
	public.Destroy()
	fast.Start()
	session:SetAttribute("Stage", "Rounds")
	local lastMatch = 0
	local lastCallAt = 0
	local lastCallMatch = 0
	local testDeadline = os.clock() + 65
	while #outcomes < 3 and os.clock() < testDeadline do
		task.wait(0.03)
		local state = fast.GetSnapshot(player)
		if state and state.card then
			local called = {}
			for _, number in state.calledNumbers do called[number] = true end
			for _, cell in state.card do assert(not cell.isMarked or cell.isFree or called[cell.number], "uncalled mark accepted") end
			if #state.calledNumbers == 75 and lastCallMatch ~= state.matchId then
				lastCallAt = os.clock(); lastCallMatch = state.matchId
			end
			if state.phase == "RoundComplete" and state.matchId ~= lastMatch then
				lastMatch = state.matchId
				assert(state.result ~= nil)
				assert(state.result.isDraw == (state.matchId == 2), "unexpected winner/draw")
				if state.result.isDraw then assert(os.clock() - lastCallAt >= 0.12, "last call had no action interval") end
				assert(state.isFirstMatch == (state.matchId == 1), "tutorial session state incorrect")
				table.insert(outcomes, {matchId = state.matchId, draw = state.result.isDraw, calls = #state.calledNumbers})
				session:SetAttribute("CompletedRounds", #outcomes)
			end
		end
	end
	assert(#outcomes == 3, "three rounds did not finish")
end)
session:SetAttribute("Stage", "Done")
public.Destroy(); fast.Destroy()
original.Start()
session:SetAttribute("Result", HttpService:JSONEncode({ok = ok, failure = tostring(failure), outcomes = outcomes}))
