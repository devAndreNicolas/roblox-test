--!strict
-- Inject as a temporary LocalScript during Studio validation, outside the Rojo source tree.
local player = game:GetService("Players").LocalPlayer
local feature = player.PlayerScripts.Client.Features.Bingo
local controller = require(feature.BingoController)
local result = {}
local function countGui(): number
	local count = 0
	for _, child in player.PlayerGui:GetChildren() do if child.Name == "BingoGui" then count += 1 end end
	return count
end
local ok, failure = pcall(function()
	controller.Start(); controller.Start()
	assert(countGui() == 1, "duplicate GUI")
	controller.Destroy(); assert(countGui() == 0, "GUI not destroyed")
	controller.Start(); task.wait(0.2); assert(countGui() == 1)
	table.insert(result, "controller Start/Destroy/Start")
	local scene = require(feature.ScenePresenter).new()
	local completion = 0
	scene.Play(0.1, function() completion += 1 end)
	task.wait(0.2)
	assert(completion == 1 and workspace.CurrentCamera.CameraType == Enum.CameraType.Custom)
	scene.Play(1, function() completion += 1 end)
	scene.Stop(true); scene.Stop(true)
	assert(completion == 2, "duplicate completion")
	local original = workspace.CurrentCamera
	local replacement = Instance.new("Camera"); replacement.CFrame = original.CFrame; replacement.Parent = workspace
	scene.Play(1, function() completion += 1 end)
	workspace.CurrentCamera = replacement
	task.wait(0.1)
	assert(completion == 3 and replacement.CameraType == Enum.CameraType.Custom, "replacement cleanup failed")
	assert(replacement.CameraSubject == player.Character:FindFirstChildOfClass("Humanoid"))
	replacement.Name = "Camera"
	scene.SetParticipant(true)
	local prompt = workspace.BingoWorld.BingoQueuePortal.PortalField.QueuePrompt
	assert(not prompt.Enabled)
	scene.Destroy()
	assert(prompt.Enabled)
	table.insert(result, "scene completion/skip/camera replacement/world UI restoration")
	local status = require(player.PlayerScripts.Client.UI.StatusMessage).new(player.PlayerGui.BingoGui)
	status.Update({id = 1, kind = "error", text = "Uncalled number"}, 1)
	status.Update(nil, 1); assert(status.Instance.Visible)
	task.wait(3.1); status.Tick(); assert(not status.Instance.Visible)
	status.Destroy()
	table.insert(result, "notice survives snapshots and expires")
end)
script:SetAttribute("Result", game:GetService("HttpService"):JSONEncode({ok = ok, failure = tostring(failure), checks = result}))
