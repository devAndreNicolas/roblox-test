--!strict
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Presenter = {}
function Presenter.new()
	local player = Players.LocalPlayer
	local connections: {RBXScriptConnection} = {}
	local savedEnabled: {[Instance]: boolean} = {}
	local participant = false
	local camera: Camera? = nil
	local savedType = Enum.CameraType.Custom
	local savedSubject: Instance? = nil
	local savedField = 70
	local tween: Tween? = nil
	local timer: thread? = nil
	local viewportConnection: RBXScriptConnection? = nil
	local onComplete: (() -> ())? = nil
	local generation = 0
	local presenter = {}
	local function suppress(object: Instance): ()
		if not participant or savedEnabled[object] ~= nil then return end
		if object:IsA("BillboardGui") and (object.Name == "PortalSign" or object.Name == "MCDialogue") then
			savedEnabled[object] = object.Enabled; object.Enabled = false
		elseif object:IsA("ProximityPrompt") and object.Name == "QueuePrompt" then
			savedEnabled[object] = object.Enabled; object.Enabled = false
		end
	end
	function presenter.SetParticipant(value: boolean): ()
		if value == participant then return end
		participant = value
		if value then
			local world = Workspace:FindFirstChild("BingoWorld")
			if world then for _, object in world:GetDescendants() do suppress(object) end end
		else
			for object, enabled in savedEnabled do
				if object.Parent then
					if object:IsA("BillboardGui") then object.Enabled = enabled
					elseif object:IsA("ProximityPrompt") then object.Enabled = enabled end
				end
			end
			table.clear(savedEnabled)
		end
	end
	function presenter.Stop(complete: boolean?): ()
		generation += 1
		if timer then pcall(task.cancel, timer); timer = nil end
		if tween then tween:Cancel(); tween = nil end
		if viewportConnection then viewportConnection:Disconnect(); viewportConnection = nil end
		local previous = camera
		camera = nil
		if previous and previous.Parent then
			previous.CameraType = savedType
			previous.FieldOfView = savedField
			local character = player.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if humanoid then previous.CameraSubject = humanoid
			elseif savedSubject and savedSubject.Parent then previous.CameraSubject = savedSubject end
		end
		local callback = onComplete
		onComplete = nil
		if complete and callback then callback() end
	end
	function presenter.Play(duration: number, callback: () -> ()): ()
		presenter.Stop(false)
		onComplete = callback
		local thisGeneration = generation
		camera = Workspace.CurrentCamera
		local world = Workspace:FindFirstChild("BingoWorld")
		local mc = world and world:FindFirstChild("BingoMC")
		local head = mc and mc:FindFirstChild("Head")
		if camera then
			savedType, savedSubject, savedField = camera.CameraType, camera.CameraSubject, camera.FieldOfView
			if head and head:IsA("BasePart") then
				local activeCamera = camera
				local function target(): CFrame
					local portrait = activeCamera.ViewportSize.X < activeCamera.ViewportSize.Y
					local focus = head.Position
					return CFrame.lookAt(focus + Vector3.new(0, 1.4, -12), focus - Vector3.new(0, if portrait then 6.5 else 0.8, 0))
				end
				activeCamera.CameraType = Enum.CameraType.Scriptable
				tween = TweenService:Create(activeCamera, TweenInfo.new(0.45, Enum.EasingStyle.Quad), {CFrame = target()})
				tween:Play()
				viewportConnection = activeCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
					if generation ~= thisGeneration then return end
					if tween then tween:Cancel(); tween = nil end
					activeCamera.CFrame = target()
				end)
			end
		end
		timer = task.delay(math.max(0.05, duration), function()
			timer = nil
			if generation == thisGeneration then presenter.Stop(true) end
		end)
	end
	table.insert(connections, Workspace.DescendantAdded:Connect(suppress))
	table.insert(connections, Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		local owned = camera ~= nil
		presenter.Stop(true)
		local replacement = Workspace.CurrentCamera
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if owned and replacement and humanoid then
			replacement.CameraType = Enum.CameraType.Custom
			replacement.CameraSubject = humanoid
		end
	end))
	table.insert(connections, player.CharacterRemoving:Connect(function() presenter.Stop(true) end))
	table.insert(connections, player.CharacterAdded:Connect(function()
		presenter.Stop(true)
		local current = Workspace.CurrentCamera
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if current and humanoid and current.CameraType == Enum.CameraType.Custom then current.CameraSubject = humanoid end
	end))
	function presenter.Destroy(): ()
		presenter.Stop(false); presenter.SetParticipant(false)
		for _, connection in connections do connection:Disconnect() end
		table.clear(connections)
	end
	return presenter
end
return Presenter
