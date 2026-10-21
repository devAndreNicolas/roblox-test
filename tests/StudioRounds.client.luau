--!strict
-- Uses the actual proximity prompt and remotes; no production testing endpoints.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local session = ReplicatedStorage:WaitForChild("BingoValidationSession")
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local state: any = nil
local connection = remotes.RoundUpdate.OnClientEvent:Connect(function(snapshot)
	state = snapshot
end)
local deadline = os.clock() + 80
local lastPortal = -math.huge
local malformedSent = false
remotes.RequestSnapshot:FireServer()
while session:GetAttribute("Stage") ~= "Done" and os.clock() < deadline do
	task.wait(0.12)
	if session:GetAttribute("Stage") == "Done" then
		break
	end
	if not state then
		continue
	end
	if not state.isParticipant and not state.isQueued and os.clock() - lastPortal >= 1 then
		lastPortal = os.clock()
		local prompt = workspace.BingoWorld.BingoQueuePortal.PortalField.QueuePrompt
		prompt:InputHoldBegin()
		task.wait(0.05)
		prompt:InputHoldEnd()
	elseif state.phase == "CallingNumbers" and state.isParticipant and state.matchId ~= 2 then
		if not malformedSent then
			malformedSent = true
			remotes.MarkCell:FireServer(0 / 0, 1)
			task.wait(0.12)
			remotes.MarkCell:FireServer(state.matchId, math.huge)
			task.wait(0.12)
			remotes.MarkCell:FireServer(state.matchId, "1")
			task.wait(0.12)
			remotes.MarkCell:FireServer(state.matchId - 1, 1)
			task.wait(0.12)
		end
		local called = {}
		for _, number in state.calledNumbers do
			called[number] = true
		end
		for index, cell in state.card do
			if not cell.isMarked and called[cell.number] then
				remotes.MarkCell:FireServer(state.matchId, index)
				break
			end
		end
	end
end
task.wait(0.5)
assert(state and state.matchId == 0 and not state.isParticipant, "server restart snapshot was ignored")
assert(game.Players.LocalPlayer.PlayerGui.BingoGui.Content.LobbyView.Visible, "restart did not restore lobby UI")
assert(workspace.BingoWorld.BingoQueuePortal.PortalField.QueuePrompt.Enabled, "portal stayed disabled after restart")
script:SetAttribute("RestartPassed", true)
connection:Disconnect()
