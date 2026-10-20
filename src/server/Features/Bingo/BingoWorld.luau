--!strict
-- Creates the simple lobby, queue portal, and Bingo MC stage for the first MVP.

local Workspace = game:GetService("Workspace")

local WORLD_NAME = "BingoWorld"
local LOBBY_SPAWN = CFrame.lookAt(Vector3.new(0, 3, -38), Vector3.new(0, 3, -28))
local MC_POSITION = Vector3.new(0, 2.6, 28)
local MATCH_POSITIONS = {
	Vector3.new(-10, 3, 12),
	Vector3.new(-5, 3, 10),
	Vector3.new(0, 3, 9),
	Vector3.new(5, 3, 10),
	Vector3.new(10, 3, 12),
	Vector3.new(-10, 3, 4),
	Vector3.new(-5, 3, 3),
	Vector3.new(0, 3, 2),
	Vector3.new(5, 3, 3),
	Vector3.new(10, 3, 4),
}

local portalPrompt: ProximityPrompt? = nil
local portalStatus: TextLabel? = nil
local mcDialogue: TextLabel? = nil
local placementTasks: {[Player]: thread} = {}
local worldGeneration = 0

local function makePart(
	parent: Instance,
	name: string,
	size: Vector3,
	cframe: CFrame,
	color: Color3,
	material: Enum.Material,
	shape: Enum.PartType?
): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cframe
	part.Color = color
	part.Material = material
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = true
	if shape then
		part.Shape = shape
	end
	part.Parent = parent
	return part
end

local function makeBillboard(
	adornee: BasePart,
	name: string,
	text: string,
	width: number,
	height: number,
	studsOffset: Vector3
): TextLabel
	local billboard = Instance.new("BillboardGui")
	billboard.Name = name
	billboard.Adornee = adornee
	billboard.Size = UDim2.fromOffset(width, height)
	billboard.StudsOffset = studsOffset
	billboard.AlwaysOnTop = true
	billboard.MaxDistance = if name == "PortalSign" then 48 else 36
	billboard.Parent = adornee

	local label = Instance.new("TextLabel")
	label.Name = "Text"
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundColor3 = Color3.fromRGB(18, 33, 51)
	label.BackgroundTransparency = 0.08
	label.TextColor3 = Color3.fromRGB(255, 248, 225)
	label.Text = text
	label.TextScaled = true
	label.TextWrapped = true
	label.Font = Enum.Font.GothamBold
	label.Parent = billboard

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = label
	return label
end

local function createPortal(parent: Folder): (ProximityPrompt, TextLabel)
	local model = Instance.new("Model")
	model.Name = "BingoQueuePortal"
	model.Parent = parent

	local portalBase = makePart(model, "PortalBase", Vector3.new(15, 0.6, 7), CFrame.new(0, 1.3, -28), Color3.fromRGB(33, 50, 70), Enum.Material.Slate)
	portalBase.CanCollide = true
	local left = makePart(model, "LeftPillar", Vector3.new(1.5, 9, 1.5), CFrame.new(-5.25, 5.7, -28), Color3.fromRGB(60, 208, 181), Enum.Material.Neon)
	local right = makePart(model, "RightPillar", Vector3.new(1.5, 9, 1.5), CFrame.new(5.25, 5.7, -28), Color3.fromRGB(60, 208, 181), Enum.Material.Neon)
	local top = makePart(model, "TopBeam", Vector3.new(12, 1.5, 1.5), CFrame.new(0, 10, -28), Color3.fromRGB(60, 208, 181), Enum.Material.Neon)
	local portalField = makePart(model, "PortalField", Vector3.new(8, 7, 0.35), CFrame.new(0, 5.65, -28), Color3.fromRGB(47, 190, 181), Enum.Material.ForceField)
	portalField.Transparency = 0.42
	portalField.CanQuery = false
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "QueuePrompt"
	prompt.ActionText = "Join / leave queue"
	prompt.ObjectText = "Bingo Portal"
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.GamepadKeyCode = Enum.KeyCode.ButtonX
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 12
	prompt.RequiresLineOfSight = false
	prompt.Parent = portalField

	local sign = makeBillboard(top, "PortalSign", "BINGO\nJOIN THE QUEUE", 280, 86, Vector3.new(0, 2, 0))
	model.PrimaryPart = left
	return prompt, sign
end

local function createMC(parent: Folder): (Model, TextLabel)
	local model = Instance.new("Model")
	model.Name = "BingoMC"
	model.Parent = parent

	local root = makePart(model, "HumanoidRootPart", Vector3.new(2, 2, 1), CFrame.new(MC_POSITION), Color3.new(1, 1, 1), Enum.Material.SmoothPlastic)
	root.Transparency = 1
	local torso = makePart(model, "Torso", Vector3.new(2.4, 2.8, 1.2), CFrame.new(MC_POSITION + Vector3.new(0, 2.15, 0)), Color3.fromRGB(26, 49, 74), Enum.Material.SmoothPlastic)
	local head = makePart(model, "Head", Vector3.new(1.7, 1.7, 1.7), CFrame.new(MC_POSITION + Vector3.new(0, 4.5, 0)), Color3.fromRGB(240, 191, 148), Enum.Material.SmoothPlastic, Enum.PartType.Ball)
	local tie = makePart(model, "Tie", Vector3.new(0.32, 1.15, 0.18), CFrame.new(MC_POSITION + Vector3.new(0, 2.15, -0.7)), Color3.fromRGB(60, 208, 181), Enum.Material.Neon)
	local hair = makePart(model, "Hair", Vector3.new(1.8, 0.55, 1.8), CFrame.new(MC_POSITION + Vector3.new(0, 5.25, 0)), Color3.fromRGB(45, 33, 30), Enum.Material.SmoothPlastic, Enum.PartType.Ball)
	local leftArm = makePart(model, "LeftArm", Vector3.new(0.65, 2.5, 0.65), CFrame.new(MC_POSITION + Vector3.new(-1.55, 2.2, 0)), Color3.fromRGB(240, 191, 148), Enum.Material.SmoothPlastic)
	local rightArm = makePart(model, "RightArm", Vector3.new(0.65, 2.5, 0.65), CFrame.new(MC_POSITION + Vector3.new(1.55, 2.2, 0)) * CFrame.Angles(0, 0, math.rad(-35)), Color3.fromRGB(240, 191, 148), Enum.Material.SmoothPlastic)
	local leftLeg = makePart(model, "LeftLeg", Vector3.new(0.8, 2.5, 0.8), CFrame.new(MC_POSITION + Vector3.new(-0.55, 0.55, 0)), Color3.fromRGB(37, 57, 81), Enum.Material.SmoothPlastic)
	local rightLeg = makePart(model, "RightLeg", Vector3.new(0.8, 2.5, 0.8), CFrame.new(MC_POSITION + Vector3.new(0.55, 0.55, 0)), Color3.fromRGB(37, 57, 81), Enum.Material.SmoothPlastic)
	makePart(model, "EyeLeft", Vector3.new(0.15, 0.2, 0.08), CFrame.new(MC_POSITION + Vector3.new(-0.32, 4.55, -0.83)), Color3.fromRGB(35, 30, 30), Enum.Material.SmoothPlastic, Enum.PartType.Ball)
	makePart(model, "EyeRight", Vector3.new(0.15, 0.2, 0.08), CFrame.new(MC_POSITION + Vector3.new(0.32, 4.55, -0.83)), Color3.fromRGB(35, 30, 30), Enum.Material.SmoothPlastic, Enum.PartType.Ball)
	makePart(model, "Smile", Vector3.new(0.45, 0.08, 0.06), CFrame.new(MC_POSITION + Vector3.new(0, 4.18, -0.84)), Color3.fromRGB(143, 62, 65), Enum.Material.SmoothPlastic)
	for _, part in { root, torso, head, tie, hair, leftArm, rightArm, leftLeg, rightLeg } do
		part.CanCollide = false
	end
	local humanoid = Instance.new("Humanoid")
	humanoid.DisplayName = "Bingo MC"
	humanoid.NameDisplayDistance = 100
	humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
	humanoid.Parent = model
	model.PrimaryPart = root
	local dialogue = makeBillboard(head, "MCDialogue", "Welcome to Bingo!", 360, 100, Vector3.new(0, 1.5, 0))
	return model, dialogue
end

local function buildWorld(): (Folder, ProximityPrompt, TextLabel, TextLabel)
	local existing = Workspace:FindFirstChild(WORLD_NAME)
	if existing then
		assert(existing:IsA("Folder"), `{WORLD_NAME} must be a Folder`)
		local folder = existing :: Folder
		local portal = folder:FindFirstChild("BingoQueuePortal")
		local mc = folder:FindFirstChild("BingoMC")
		assert(portal and mc, "BingoWorld is missing required scene objects")
		local prompt = portal:FindFirstChild("QueuePrompt", true)
		local sign = portal:FindFirstChild("PortalSign", true)
		local dialogue = mc:FindFirstChild("MCDialogue", true)
		local signText = sign and sign:FindFirstChild("Text")
		local text = dialogue and dialogue:FindFirstChild("Text")
		assert(prompt and prompt:IsA("ProximityPrompt"), "Bingo portal prompt is missing")
		assert(signText and signText:IsA("TextLabel"), "Bingo portal sign is missing")
		assert(text and text:IsA("TextLabel"), "MC dialogue label is missing")
		return folder, prompt, text, signText
	end

	local folder = Instance.new("Folder")
	folder.Name = WORLD_NAME
	folder.Parent = Workspace

	local lobbyFloor = makePart(folder, "LobbyFloor", Vector3.new(96, 1, 120), CFrame.new(0, 0.5, -2), Color3.fromRGB(36, 54, 68), Enum.Material.Slate)
	lobbyFloor.CanCollide = true
	local matchPlatform = makePart(folder, "MatchPlatform", Vector3.new(34, 1, 34), CFrame.new(0, 1.1, 16), Color3.fromRGB(51, 70, 84), Enum.Material.SmoothPlastic)
	matchPlatform.CanCollide = true
	local mcStage = makePart(folder, "MCStage", Vector3.new(16, 1, 8), CFrame.new(0, 1.4, 29), Color3.fromRGB(60, 208, 181), Enum.Material.SmoothPlastic)
	mcStage.CanCollide = true
	local desk = makePart(folder, "CallersDesk", Vector3.new(10, 2.2, 2), CFrame.new(0, 3, 24), Color3.fromRGB(30, 45, 64), Enum.Material.WoodPlanks)
	desk.CanCollide = true
	local portal, signText = createPortal(folder)
	local _, dialogue = createMC(folder)
	return folder, portal, dialogue, signText
end

local WorldService = {}

function WorldService.Start(): ProximityPrompt
	worldGeneration += 1
	local _, prompt, dialogue, sign = buildWorld()
	portalPrompt = prompt
	mcDialogue = dialogue
	portalStatus = sign
	return prompt
end

function WorldService.PlacePlayer(player: Player, resolve: () -> CFrame): ()
	local previous = placementTasks[player]
	if previous then pcall(task.cancel, previous) end
	local generation = worldGeneration
	placementTasks[player] = task.defer(function()
		local deadline = os.clock() + 10
		while os.clock() < deadline and player.Parent and generation == worldGeneration do
			local character = player.Character
			local root = character and character:FindFirstChild("HumanoidRootPart")
			if root and root:IsA("BasePart") and character == player.Character then
				root.CFrame = resolve()
				placementTasks[player] = nil
				return
			end
			task.wait(0.1)
		end
		placementTasks[player] = nil
	end)
end

function WorldService.RemovePlayer(player: Player): ()
	local pending = placementTasks[player]
	if pending then pcall(task.cancel, pending); placementTasks[player] = nil end
end

function WorldService.Destroy(): ()
	worldGeneration += 1
	for player in placementTasks do WorldService.RemovePlayer(player) end
	portalPrompt = nil; portalStatus = nil; mcDialogue = nil
end

function WorldService.GetLobbyCFrame(): CFrame
	return LOBBY_SPAWN
end

function WorldService.GetMatchCFrame(index: number): CFrame
	local position = MATCH_POSITIONS[((index - 1) % #MATCH_POSITIONS) + 1]
	return CFrame.lookAt(position, MC_POSITION + Vector3.new(0, 2.5, 0))
end

function WorldService.IsNearQueuePortal(player: Player): boolean
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local prompt = portalPrompt
	local portalPart = prompt and prompt.Parent
	if not root or not root:IsA("BasePart") or not portalPart or not portalPart:IsA("BasePart") then
		return false
	end
	local distance = (root.Position - portalPart.Position).Magnitude
	return distance == distance and distance <= 14
end

function WorldService.SetQueueStatus(message: string): ()
	local sign = portalStatus
	if sign and sign.Parent then
		sign.Text = message
	end
end

function WorldService.SetMCDialogue(message: string): ()
	local dialogue = mcDialogue
	if dialogue and dialogue.Parent then
		dialogue.Text = message
	end
end

return WorldService
