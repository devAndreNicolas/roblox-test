--!strict
-- Server-owned backstage, studio, host, queue portal, and participant stations.
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local WORLD_NAME = "BingoWorld"
local WORLD_VERSION = 6
local MIDNIGHT = Color3.fromRGB(16, 26, 51)
local BLUE = Color3.fromRGB(35, 59, 104)
local AMBER = Color3.fromRGB(242, 184, 75)
local IVORY = Color3.fromRGB(255, 244, 216)
local BURGUNDY = Color3.fromRGB(125, 48, 72)
local INK = Color3.fromRGB(23, 32, 51)
local LOBBY_SPAWN = CFrame.lookAt(Vector3.new(0, 3, -51), Vector3.new(0, 3, -28))
local MC_POSITION = Vector3.new(0, 2.1, 101)
local STATION_POSITIONS = {
	Vector3.new(-5, 1.7, 79),
	Vector3.new(5, 1.7, 79),
	Vector3.new(-15, 1.7, 79),
	Vector3.new(15, 1.7, 79),
	Vector3.new(-5, 1.7, 70),
	Vector3.new(5, 1.7, 70),
	Vector3.new(-15, 1.7, 70),
	Vector3.new(15, 1.7, 70),
}

local portalPrompt: ProximityPrompt? = nil
local portalStatus: TextLabel? = nil
local mcDialogue: TextLabel? = nil
local callDisplay: TextLabel? = nil
local callLight: PointLight? = nil
local stations: { Seat } = {}
local placementTasks: { [Player]: thread } = {}
local seatConnections: { [Player]: RBXScriptConnection } = {}
local placementGeneration: { [Player]: number } = {}
local worldGeneration = 0
local lightTween: Tween? = nil
local armTween: Tween? = nil
local mcArm: BasePart? = nil
local celebrationEmitters: { ParticleEmitter } = {}

local function part(
	parent: Instance,
	name: string,
	size: Vector3,
	cf: CFrame,
	color: Color3,
	material: Enum.Material,
	collidable: boolean?
): Part
	local item = Instance.new("Part")
	item.Name = name
	item.Size = size
	item.CFrame = cf
	item.Color = color
	item.Material = material
	item.Anchored = true
	item.CanCollide = collidable == true
	item.CanTouch = false
	item.CanQuery = collidable == true
	item.Parent = parent
	return item
end

local function billboard(
	adornee: BasePart,
	name: string,
	message: string,
	width: number,
	height: number,
	offset: Vector3
): TextLabel
	local gui = Instance.new("BillboardGui")
	gui.Name = name
	gui.Adornee = adornee
	gui.Size = UDim2.fromOffset(width, height)
	gui.StudsOffset = offset
	gui.AlwaysOnTop = true
	gui.MaxDistance = if name == "PortalSign" then 48 else 42
	gui.Parent = adornee
	local label = Instance.new("TextLabel")
	label.Name = "Text"
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundColor3 = MIDNIGHT
	label.BackgroundTransparency = 0.08
	label.TextColor3 = IVORY
	label.Text = message
	label.TextScaled = true
	label.TextWrapped = true
	label.Font = Enum.Font.Oswald
	label.Parent = gui
	local stroke = Instance.new("UIStroke")
	stroke.Color = AMBER
	stroke.Thickness = 2
	stroke.Parent = label
	return label
end

local function surfaceSign(facePart: BasePart, name: string, message: string): TextLabel
	local gui = Instance.new("SurfaceGui")
	gui.Name = name
	gui.Face = Enum.NormalId.Front
	gui.Adornee = facePart
	gui.CanvasSize = Vector2.new(640, 220)
	gui.LightInfluence = 0
	gui.Parent = facePart
	local label = Instance.new("TextLabel")
	label.Name = "Text"
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = message
	label.TextColor3 = IVORY
	label.TextScaled = true
	label.Font = Enum.Font.Oswald
	label.Parent = gui
	return label
end

local function fixture(
	parent: Instance,
	position: Vector3,
	color: Color3,
	brightness: number,
	range: number
): PointLight
	local housing =
		part(parent, "SpotlightHousing", Vector3.new(2.5, 0.7, 2.5), CFrame.new(position), BLUE, Enum.Material.Metal)
	local lens = part(
		parent,
		"SpotlightLens",
		Vector3.new(1.5, 0.15, 1.5),
		CFrame.new(position - Vector3.new(0, 0.4, 0)),
		color,
		Enum.Material.Neon
	)
	lens.Transparency = 0.25
	local light = Instance.new("PointLight")
	light.Color = color
	light.Brightness = brightness
	light.Range = range
	light.Shadows = false
	light.Parent = housing
	return light
end

local function createPortal(parent: Folder): (ProximityPrompt, TextLabel)
	local model = Instance.new("Model")
	model.Name = "BingoQueuePortal"
	model.Parent = parent
	part(model, "PortalStep", Vector3.new(15, 0.25, 5), CFrame.new(0, 1.13, -28), BLUE, Enum.Material.Marble, true)
	for _, x in { -5.7, 5.7 } do
		part(model, "DecoPillar", Vector3.new(1.2, 9, 1.2), CFrame.new(x, 5.8, -28), BLUE, Enum.Material.Metal, true)
		part(model, "AmberTrim", Vector3.new(0.16, 8, 0.16), CFrame.new(x, 5.8, -28.7), AMBER, Enum.Material.Neon)
	end
	local beam =
		part(model, "PortalBeam", Vector3.new(13, 1.5, 1.4), CFrame.new(0, 10, -28), MIDNIGHT, Enum.Material.Metal)
	part(model, "BeamTrim", Vector3.new(12, 0.15, 1.5), CFrame.new(0, 10.7, -28), AMBER, Enum.Material.Neon)
	local field =
		part(model, "QueueField", Vector3.new(8, 7, 0.25), CFrame.new(0, 5.5, -28), AMBER, Enum.Material.ForceField)
	field.Transparency = 0.8
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "QueuePrompt"
	prompt.ActionText = "Join / leave queue"
	prompt.ObjectText = "Bingo Noir"
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.GamepadKeyCode = Enum.KeyCode.ButtonX
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 12
	prompt.RequiresLineOfSight = false
	prompt.Parent = field
	local marquee =
		part(model, "PortalMarquee", Vector3.new(15, 2.4, 0.3), CFrame.new(0, 12, -28.8), INK, Enum.Material.Metal)
	return prompt, surfaceSign(marquee, "PortalSign", "BINGO NOIR  •  JOIN THE QUEUE")
end

local function createMC(parent: Folder): TextLabel
	local model = Instance.new("Model")
	model.Name = "BingoMC"
	model.Parent = parent
	local root = part(
		model,
		"HumanoidRootPart",
		Vector3.new(2, 2, 1),
		CFrame.new(MC_POSITION),
		MIDNIGHT,
		Enum.Material.SmoothPlastic
	)
	root.Transparency = 1
	part(
		model,
		"Jacket",
		Vector3.new(2.7, 3, 1.2),
		CFrame.new(MC_POSITION + Vector3.new(0, 2.2, 0)),
		MIDNIGHT,
		Enum.Material.Fabric
	)
	part(
		model,
		"Vest",
		Vector3.new(1.2, 2.2, 0.18),
		CFrame.new(MC_POSITION + Vector3.new(0, 2.2, -0.66)),
		BURGUNDY,
		Enum.Material.Fabric
	)
	part(
		model,
		"Tie",
		Vector3.new(0.27, 1.15, 0.14),
		CFrame.new(MC_POSITION + Vector3.new(0, 2.2, -0.79)),
		AMBER,
		Enum.Material.SmoothPlastic
	)
	local head = part(
		model,
		"Head",
		Vector3.new(1.65, 1.65, 1.65),
		CFrame.new(MC_POSITION + Vector3.new(0, 4.6, 0)),
		Color3.fromRGB(223, 177, 136),
		Enum.Material.SmoothPlastic
	)
	head.Shape = Enum.PartType.Ball
	part(
		model,
		"HatBrim",
		Vector3.new(2.5, 0.2, 2.2),
		CFrame.new(MC_POSITION + Vector3.new(0, 5.45, 0)),
		INK,
		Enum.Material.SmoothPlastic
	)
	part(
		model,
		"HatCrown",
		Vector3.new(1.75, 0.85, 1.7),
		CFrame.new(MC_POSITION + Vector3.new(0, 5.95, 0)),
		INK,
		Enum.Material.SmoothPlastic
	)
	part(
		model,
		"LeftSleeve",
		Vector3.new(0.7, 2.5, 0.7),
		CFrame.new(MC_POSITION + Vector3.new(-1.7, 2.2, 0)),
		MIDNIGHT,
		Enum.Material.Fabric
	)
	part(
		model,
		"RightSleeve",
		Vector3.new(0.7, 2.5, 0.7),
		CFrame.new(MC_POSITION + Vector3.new(1.7, 2.2, 0)),
		MIDNIGHT,
		Enum.Material.Fabric
	)
	for _, x in { -0.55, 0.55 } do
		part(
			model,
			"TrouserLeg",
			Vector3.new(0.85, 2.3, 0.85),
			CFrame.new(MC_POSITION + Vector3.new(x, -0.45, 0)),
			INK,
			Enum.Material.Fabric
		)
		local eye = part(
			model,
			"Eye",
			Vector3.new(0.13, 0.16, 0.08),
			CFrame.new(MC_POSITION + Vector3.new(x * 0.58, 4.68, -0.81)),
			INK,
			Enum.Material.SmoothPlastic
		)
		eye.Shape = Enum.PartType.Ball
	end
	part(
		model,
		"Smile",
		Vector3.new(0.4, 0.07, 0.06),
		CFrame.new(MC_POSITION + Vector3.new(0, 4.28, -0.82)),
		BURGUNDY,
		Enum.Material.SmoothPlastic
	)
	model.PrimaryPart = root
	return billboard(head, "MCDialogue", "Welcome to Bingo Noir!", 360, 92, Vector3.new(0, 1.6, 0))
end

local function buildWorld(): (Folder, ProximityPrompt, TextLabel, TextLabel, TextLabel, PointLight, { Seat })
	local existing = Workspace:FindFirstChild(WORLD_NAME)
	if existing then
		assert(existing:IsA("Folder"), "BingoWorld name is reserved for the generated folder")
		if existing:GetAttribute("Version") == WORLD_VERSION then
			local portal = existing:FindFirstChild("QueuePrompt", true)
			local sign = existing:FindFirstChild("PortalSign", true)
			local dialogue = existing:FindFirstChild("MCDialogue", true)
			local display = existing:FindFirstChild("CallDisplay", true)
			local lamp = existing:FindFirstChild("CallSpotlight", true)
			local seatFolder = existing:FindFirstChild("Stations")
			local signText = sign and sign:FindFirstChild("Text")
			local dialogueText = dialogue and dialogue:FindFirstChild("Text")
			local displayText = display and display:FindFirstChild("Text")
			local foundSeats: { Seat } = {}
			if seatFolder then
				for index = 1, 8 do
					local seat = seatFolder:FindFirstChild(`Station{index}`)
					if seat and seat:IsA("Seat") then
						table.insert(foundSeats, seat)
					end
				end
			end
			if
				portal
				and portal:IsA("ProximityPrompt")
				and signText
				and signText:IsA("TextLabel")
				and dialogueText
				and dialogueText:IsA("TextLabel")
				and displayText
				and displayText:IsA("TextLabel")
				and lamp
				and lamp:IsA("PointLight")
				and #foundSeats == 8
			then
				return existing, portal, dialogueText, signText, displayText, lamp, foundSeats
			end
		end
		existing:Destroy()
	end
	local folder = Instance.new("Folder")
	folder.Name = WORLD_NAME
	folder:SetAttribute("Version", WORLD_VERSION)
	folder.Parent = Workspace

	-- Backstage is enclosed so waiting players have a purposeful space and no studio sightline.
	part(
		folder,
		"BackstageFloor",
		Vector3.new(52, 1, 52),
		CFrame.new(0, 0.5, -42),
		MIDNIGHT,
		Enum.Material.Marble,
		true
	)
	part(folder, "BackstageCeiling", Vector3.new(52, 1, 52), CFrame.new(0, 15, -42), INK, Enum.Material.Metal, true)
	for _, x in { -26, 26 } do
		part(
			folder,
			"BackstageSideWall",
			Vector3.new(1, 15, 52),
			CFrame.new(x, 7.5, -42),
			BLUE,
			Enum.Material.Concrete,
			true
		)
	end
	for _, z in { -68, -16 } do
		part(
			folder,
			"BackstageEndWall",
			Vector3.new(52, 15, 1),
			CFrame.new(0, 7.5, z),
			BLUE,
			Enum.Material.Concrete,
			true
		)
	end
	for _, x in { -20, 20 } do
		part(
			folder,
			"BackstageGoldLine",
			Vector3.new(0.25, 0.06, 40),
			CFrame.new(x, 1.06, -42),
			AMBER,
			Enum.Material.Neon
		)
		fixture(folder, Vector3.new(x, 13.9, -43), AMBER, 1.1, 26)
	end
	part(folder, "BackstageCarpet", Vector3.new(10, 0.06, 29), CFrame.new(0, 1.06, -44), BURGUNDY, Enum.Material.Fabric)
	for _, x in { -5.2, 5.2 } do
		part(folder, "CarpetEdge", Vector3.new(0.18, 0.08, 29), CFrame.new(x, 1.1, -44), AMBER, Enum.Material.Metal)
	end
	for _, x in { -17, 17 } do
		local bench = part(
			folder,
			"WaitingBench",
			Vector3.new(9, 0.8, 2.6),
			CFrame.new(x, 1.6, -48),
			BURGUNDY,
			Enum.Material.Fabric,
			true
		)
		part(folder, "BenchBack", Vector3.new(9, 2.2, 0.5), CFrame.new(x, 2.7, -46.8), BLUE, Enum.Material.Fabric, true)
		part(
			folder,
			"BenchTrim",
			Vector3.new(9, 0.12, 0.2),
			bench.CFrame * CFrame.new(0, -0.45, -1.2),
			AMBER,
			Enum.Material.Metal
		)
	end
	local leftPoster =
		part(folder, "HowToPlayPoster", Vector3.new(12, 4.5, 0.3), CFrame.new(-15, 7.5, -32), INK, Enum.Material.Metal)
	surfaceSign(leftPoster, "HowToPlayGui", "1  WATCH THE CALL\n2  MARK YOUR CARD")
	local rightPoster =
		part(folder, "WinPoster", Vector3.new(12, 4.5, 0.3), CFrame.new(15, 7.5, -32), INK, Enum.Material.Metal)
	surfaceSign(rightPoster, "WinPosterGui", "FILL YOUR CARD\nWIN THE SHOW!")
	local entrance =
		part(folder, "BackstageTitle", Vector3.new(19, 2.5, 0.3), CFrame.new(0, 10, -17.1), INK, Enum.Material.Metal)
	surfaceSign(entrance, "BackstageTitleGui", "BINGO NOIR  •  BACKSTAGE")
	local prompt, sign = createPortal(folder)

	-- A separate enclosed studio in the same server keeps the existing queue and match flow.
	part(folder, "StudioFloor", Vector3.new(58, 1, 58), CFrame.new(0, 0.5, 87), MIDNIGHT, Enum.Material.Marble, true)
	part(folder, "StudioCeiling", Vector3.new(58, 1, 58), CFrame.new(0, 17, 87), INK, Enum.Material.Metal, true)
	for _, x in { -29, 29 } do
		part(
			folder,
			"StudioSideWall",
			Vector3.new(1, 17, 58),
			CFrame.new(x, 8.5, 87),
			BLUE,
			Enum.Material.Concrete,
			true
		)
	end
	for _, z in { 58, 116 } do
		part(folder, "StudioEndWall", Vector3.new(58, 17, 1), CFrame.new(0, 8.5, z), BLUE, Enum.Material.Concrete, true)
	end
	for _, x in { -23, -11, 11, 23 } do
		part(folder, "DecoColumn", Vector3.new(0.9, 12, 0.8), CFrame.new(x, 7, 114.9), INK, Enum.Material.Metal)
		part(folder, "DecoColumnTrim", Vector3.new(0.16, 10, 0.14), CFrame.new(x, 7, 114.4), AMBER, Enum.Material.Neon)
	end
	local stage =
		part(folder, "MCStage", Vector3.new(24, 1, 11), CFrame.new(0, 1.5, 104), BURGUNDY, Enum.Material.Marble, true)
	for _, x in { -11, 11 } do
		local launcher = part(
			folder,
			"CelebrationLauncher",
			Vector3.new(0.6, 0.6, 0.6),
			CFrame.new(x, 2.3, 99),
			AMBER,
			Enum.Material.Metal
		)
		local emitter = Instance.new("ParticleEmitter")
		emitter.Name = "BingoCelebration"
		emitter.Enabled = false
		emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		emitter.Color = ColorSequence.new(AMBER, IVORY)
		emitter.Lifetime = NumberRange.new(0.6, 1.1)
		emitter.Speed = NumberRange.new(6, 10)
		emitter.SpreadAngle = Vector2.new(45, 45)
		emitter.Rate = 0
		emitter.Parent = launcher
	end
	part(folder, "StageApron", Vector3.new(25, 0.25, 1), CFrame.new(0, 1.95, 98.4), AMBER, Enum.Material.Metal)
	part(folder, "CallersDesk", Vector3.new(11, 2.2, 2), CFrame.new(0, 3.4, 98), INK, Enum.Material.Wood)
	local board =
		part(folder, "CallBoard", Vector3.new(16, 4, 0.5), CFrame.new(0, 12.6, 114.2), INK, Enum.Material.Metal)
	local display = surfaceSign(board, "CallDisplay", "BINGO NOIR")
	local lamp = fixture(folder, Vector3.new(0, 15, 97), AMBER, 1.4, 34)
	lamp.Name = "CallSpotlight"
	for _, x in { -20, 20 } do
		fixture(folder, Vector3.new(x, 15, 94), AMBER, 1.1, 30)
	end
	for _, z in { 63, 109 } do
		part(folder, "StudioFloorTrim", Vector3.new(50, 0.06, 0.2), CFrame.new(0, 1.06, z), AMBER, Enum.Material.Neon)
	end

	local seatFolder = Instance.new("Folder")
	seatFolder.Name = "Stations"
	seatFolder.Parent = folder
	local seats: { Seat } = {}
	for index, position in STATION_POSITIONS do
		local cf = CFrame.lookAt(position, Vector3.new(0, position.Y, 101))
		local seat = Instance.new("Seat")
		seat.Name = `Station{index}`
		seat.Size = Vector3.new(3, 0.7, 3)
		seat.CFrame = cf
		seat.Color = BURGUNDY
		seat.Material = Enum.Material.Fabric
		seat.Anchored = true
		seat.CanCollide = true
		seat.CanTouch = true
		seat.Parent = seatFolder
		seats[index] = seat
		part(seatFolder, "SeatBack", Vector3.new(3, 3, 0.45), cf * CFrame.new(0, 1.6, 1.6), BLUE, Enum.Material.Fabric)
		part(seatFolder, "Desk", Vector3.new(4.3, 0.45, 2.2), cf * CFrame.new(0, 0.85, -3.5), IVORY, Enum.Material.Wood)
		local badge = part(
			seatFolder,
			"StationBadge",
			Vector3.new(2, 0.15, 0.7),
			cf * CFrame.new(0, 1.12, -3.45),
			AMBER,
			Enum.Material.Metal
		)
		badge.Transparency = 0.25
	end
	local dialogue = createMC(folder)
	return folder, prompt, dialogue, sign, display, lamp, seats
end

local WorldService = {}

local function pulse(brightness: number): ()
	local lamp = callLight
	if not lamp or not lamp.Parent then
		return
	end
	if lightTween then
		lightTween:Cancel()
		lightTween = nil
	end
	lamp.Brightness = brightness
	lightTween = TweenService:Create(
		lamp,
		TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{ Brightness = 1.4 }
	)
	lightTween:Play()
end

function WorldService.Start(): ProximityPrompt
	worldGeneration += 1
	local folder, prompt, dialogue, sign, display, lamp, foundSeats = buildWorld()
	portalPrompt, mcDialogue, portalStatus, callDisplay, callLight, stations =
		prompt, dialogue, sign, display, lamp, foundSeats
	local arm = folder:FindFirstChild("RightSleeve", true)
	mcArm = if arm and arm:IsA("BasePart") then arm else nil
	table.clear(celebrationEmitters)
	for _, descendant in folder:GetDescendants() do
		if descendant:IsA("ParticleEmitter") and descendant.Name == "BingoCelebration" then
			table.insert(celebrationEmitters, descendant)
		end
	end
	return prompt
end

function WorldService.GetLobbyCFrame(): CFrame
	return LOBBY_SPAWN
end

function WorldService.GetMatchCFrame(index: number): CFrame
	local seat = stations[index]
	if seat then
		return seat.CFrame * CFrame.new(0, 2.5, 0)
	end
	return LOBBY_SPAWN
end

function WorldService.PlacePlayer(player: Player, resolveSeat: () -> number?): ()
	WorldService.RemovePlayer(player)
	local generation = worldGeneration
	local token = (placementGeneration[player] or 0) + 1
	placementGeneration[player] = token
	placementTasks[player] = task.defer(function()
		local deadline = os.clock() + 10
		while
			os.clock() < deadline
			and player.Parent
			and generation == worldGeneration
			and placementGeneration[player] == token
		do
			local character = player.Character
			local root = character and character:FindFirstChild("HumanoidRootPart")
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if character and root and root:IsA("BasePart") and humanoid and character == player.Character then
				local seatIndex = resolveSeat()
				local seat = if seatIndex then stations[seatIndex] else nil
				if seat then
					character:PivotTo(WorldService.GetMatchCFrame(seatIndex :: number))
					seat:Sit(humanoid)
					seatConnections[player] = humanoid.Seated:Connect(function(active: boolean)
						if active then
							return
						end
						task.delay(0.1, function()
							if
								generation == worldGeneration
								and placementGeneration[player] == token
								and player.Character == character
								and resolveSeat() == seatIndex
								and humanoid.Health > 0
								and seat.Parent
							then
								character:PivotTo(WorldService.GetMatchCFrame(seatIndex :: number))
								seat:Sit(humanoid)
							end
						end)
					end)
				else
					humanoid.Sit = false
					character:PivotTo(LOBBY_SPAWN)
				end
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
	if pending then
		pcall(task.cancel, pending)
		placementTasks[player] = nil
	end
	local connection = seatConnections[player]
	if connection then
		connection:Disconnect()
		seatConnections[player] = nil
	end
	placementGeneration[player] = (placementGeneration[player] or 0) + 1
end

function WorldService.ForgetPlayer(player: Player): ()
	WorldService.RemovePlayer(player)
	placementGeneration[player] = nil
end

function WorldService.Destroy(): ()
	worldGeneration += 1
	local players: { Player } = {}
	for player in placementGeneration do
		table.insert(players, player)
	end
	for _, player in players do
		WorldService.RemovePlayer(player)
		placementGeneration[player] = nil
	end
	if lightTween then
		lightTween:Cancel()
		lightTween = nil
	end
	if armTween then
		armTween:Cancel()
		armTween = nil
	end
	portalPrompt, portalStatus, mcDialogue, callDisplay, callLight = nil, nil, nil, nil, nil
	mcArm = nil
	table.clear(celebrationEmitters)
	table.clear(stations)
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
	if portalStatus and portalStatus.Parent then
		portalStatus.Text = message
	end
end

function WorldService.SetMCDialogue(message: string): ()
	if mcDialogue and mcDialogue.Parent then
		mcDialogue.Text = message
	end
end

function WorldService.SetReady(): ()
	if callDisplay and callDisplay.Parent then
		callDisplay.Text = "BINGO NOIR"
	end
end

local function hostGesture(degrees: number): ()
	local arm = mcArm
	if not arm or not arm.Parent then
		return
	end
	if armTween then
		armTween:Cancel()
		armTween = nil
	end
	local neutral = CFrame.new(MC_POSITION + Vector3.new(1.7, 2.2, 0))
	arm.CFrame = neutral * CFrame.Angles(0, 0, math.rad(degrees))
	armTween = TweenService:Create(arm, TweenInfo.new(0.55, Enum.EasingStyle.Quad), { CFrame = neutral })
	armTween:Play()
end

function WorldService.SetCall(letter: string, number: number): ()
	if callDisplay and callDisplay.Parent then
		callDisplay.Text = `{letter}  •  {number}`
	end
	pulse(3.2)
	hostGesture(-35)
end

function WorldService.SetResult(message: string): ()
	if callDisplay and callDisplay.Parent then
		callDisplay.Text = message
	end
	pulse(5)
	hostGesture(-65)
	if message == "BINGO!" then
		for _, emitter in celebrationEmitters do
			if emitter.Parent then
				emitter:Emit(24)
			end
		end
	end
end

return WorldService
