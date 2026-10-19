--!strict
-- BingoController
-- Builds the responsive player UI and sends mark intent to the server.
-- Container: StarterPlayer/StarterPlayerScripts/Client/Controllers

----- Services -----
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

----- Types -----
type CardCell = {
	number: number,
	isFree: boolean,
	isMarked: boolean,
}

type MatchResult = {
	isDraw: boolean,
	winnerUserId: number?,
	winnerName: string?,
}

type Snapshot = {
	kind: string,
	phase: string,
	matchId: number,
	minimumPlayers: number,
	waitingPlayers: number,
	timeRemaining: number,
	calledNumbers: { number },
	lastCalledNumber: number?,
	card: { CardCell }?,
	isParticipant: boolean,
	isQueued: boolean,
	isFirstMatch: boolean,
	result: MatchResult?,
	notice: string?,
}

----- Constants -----
local COLORS = {
	background = Color3.fromRGB(15, 24, 40),
	panel = Color3.fromRGB(25, 38, 59),
	panelLight = Color3.fromRGB(35, 51, 75),
	cream = Color3.fromRGB(246, 241, 222),
	ink = Color3.fromRGB(25, 39, 57),
	muted = Color3.fromRGB(165, 181, 199),
	teal = Color3.fromRGB(60, 208, 181),
	tealDark = Color3.fromRGB(25, 113, 105),
	yellow = Color3.fromRGB(255, 195, 91),
	white = Color3.fromRGB(255, 255, 255),
	error = Color3.fromRGB(255, 136, 128),
}

----- Dependencies -----
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local roundUpdateRemote = remotes:WaitForChild("RoundUpdate") :: RemoteEvent
local markCellRemote = remotes:WaitForChild("MarkCell") :: RemoteEvent
local requestSnapshotRemote = remotes:WaitForChild("RequestSnapshot") :: RemoteEvent
local skipSceneRemote = remotes:WaitForChild("SkipScene") :: RemoteEvent

----- UI Helpers -----
local function addCorner(parent: GuiObject, radius: number): UICorner
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = parent
	return corner
end

local function addStroke(parent: GuiObject, color: Color3, thickness: number, transparency: number): UIStroke
	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Thickness = thickness
	stroke.Transparency = transparency
	stroke.Parent = parent
	return stroke
end

local function makeFrame(
	name: string,
	parent: Instance,
	position: UDim2,
	size: UDim2,
	color: Color3,
	transparency: number?
): Frame
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.Position = position
	frame.Size = size
	frame.BackgroundColor3 = color
	frame.BackgroundTransparency = transparency or 0
	frame.BorderSizePixel = 0
	frame.Parent = parent
	return frame
end

local function makeLabel(
	name: string,
	parent: Instance,
	position: UDim2,
	size: UDim2,
	text: string,
	textSize: number,
	color: Color3,
	font: Enum.Font?
): TextLabel
	local label = Instance.new("TextLabel")
	label.Name = name
	label.Position = position
	label.Size = size
	label.BackgroundTransparency = 1
	label.BorderSizePixel = 0
	label.Text = text
	label.TextColor3 = color
	label.TextSize = textSize
	label.Font = font or Enum.Font.GothamMedium
	label.TextWrapped = true
	label.Parent = parent
	return label
end

local function makePill(parent: Instance, name: string, text: string, position: UDim2, size: UDim2): TextLabel
	local pill = makeLabel(name, parent, position, size, text, 13, COLORS.teal, Enum.Font.GothamBold)
	pill.BackgroundColor3 = COLORS.panelLight
	pill.BackgroundTransparency = 0
	addCorner(pill, 12)
	return pill
end

----- Build UI -----
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BingoGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = false
screenGui.DisplayOrder = 10
screenGui.Parent = playerGui

local root = makeFrame("Background", screenGui, UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), COLORS.background, 1)

local header = makeFrame("Header", root, UDim2.fromScale(0, 0), UDim2.new(1, 0, 0, 60), COLORS.background)
local titleLabel = makeLabel(
	"Brand",
	header,
	UDim2.new(0, 22, 0, 0),
	UDim2.new(0.55, 0, 1, 0),
	"BINGO CLUB",
	20,
	COLORS.white,
	Enum.Font.GothamBlack
)
titleLabel.TextXAlignment = Enum.TextXAlignment.Left

local phasePill = makePill(header, "Phase", "LOBBY", UDim2.new(1, -148, 0, 13), UDim2.fromOffset(128, 34))

local lobbyPanel = makeFrame(
	"LobbyPanel",
	root,
	UDim2.new(0.5, 0, 0.53, 0),
	UDim2.new(0.88, 0, 0.5, 0),
	COLORS.panel
)
lobbyPanel.Visible = false
lobbyPanel.AnchorPoint = Vector2.new(0.5, 0.5)
addCorner(lobbyPanel, 24)
addStroke(lobbyPanel, COLORS.panelLight, 2, 0.15)
local lobbySize = Instance.new("UISizeConstraint")
lobbySize.MaxSize = Vector2.new(520, 380)
lobbySize.MinSize = Vector2.new(280, 300)
lobbySize.Parent = lobbyPanel

local lobbyEyebrow = makeLabel(
	"LobbyEyebrow",
	lobbyPanel,
	UDim2.new(0.08, 0, 0.12, 0),
	UDim2.new(0.84, 0, 0, 26),
	"BINGO CLUB",
	13,
	COLORS.teal,
	Enum.Font.GothamBold
)
lobbyEyebrow.TextXAlignment = Enum.TextXAlignment.Left

local lobbyTitle = makeLabel(
	"LobbyTitle",
	lobbyPanel,
	UDim2.new(0.08, 0, 0.23, 0),
	UDim2.new(0.84, 0, 0, 58),
	"Ready to play Bingo?",
	30,
	COLORS.white,
	Enum.Font.GothamBlack
)
lobbyTitle.TextXAlignment = Enum.TextXAlignment.Left

local lobbyStatus = makeLabel(
	"LobbyStatus",
	lobbyPanel,
	UDim2.new(0.08, 0, 0.43, 0),
	UDim2.new(0.84, 0, 0, 56),
	"Walk to the glowing portal and press E or tap it to join.",
	19,
	COLORS.yellow,
	Enum.Font.GothamBold
)
lobbyStatus.TextXAlignment = Enum.TextXAlignment.Left

local lobbyCount = makeLabel(
	"LobbyCount",
	lobbyPanel,
	UDim2.new(0.08, 0, 0.61, 0),
	UDim2.new(0.84, 0, 0, 30),
	"0 / 2 players waiting",
	16,
	COLORS.muted,
	Enum.Font.GothamMedium
)
lobbyCount.TextXAlignment = Enum.TextXAlignment.Left

local lobbyInstructions = makeLabel(
	"LobbyInstructions",
	lobbyPanel,
	UDim2.new(0.08, 0, 0.75, 0),
	UDim2.new(0.84, 0, 0, 54),
	"Join at the Bingo portal. When the match starts, the MC will show you what to do.",
	15,
	COLORS.muted,
	Enum.Font.Gotham
)
lobbyInstructions.TextXAlignment = Enum.TextXAlignment.Left

local gamePanel = makeFrame("GamePanel", root, UDim2.new(0.5, 0, 0.53, 0), UDim2.new(0.94, 0, 0.77, 0), COLORS.background, 1)
gamePanel.AnchorPoint = Vector2.new(0.5, 0.5)
gamePanel.Visible = false
local gameSize = Instance.new("UISizeConstraint")
gameSize.MaxSize = Vector2.new(540, 560)
gameSize.MinSize = Vector2.new(290, 430)
gameSize.Parent = gamePanel

local callPanel = makeFrame("CallPanel", gamePanel, UDim2.fromScale(0, 0), UDim2.new(1, 0, 0, 86), COLORS.panel)
addCorner(callPanel, 18)
local callCaption = makeLabel(
	"CallCaption",
	callPanel,
	UDim2.new(0, 18, 0, 8),
	UDim2.new(0.6, 0, 0, 22),
	"LATEST CALL",
	12,
	COLORS.teal,
	Enum.Font.GothamBold
)
callCaption.TextXAlignment = Enum.TextXAlignment.Left
local currentCall = makeLabel(
	"CurrentCall",
	callPanel,
	UDim2.new(0, 16, 0, 27),
	UDim2.new(0.6, 0, 0, 52),
	"Ready?",
	34,
	COLORS.white,
	Enum.Font.GothamBlack
)
currentCall.TextXAlignment = Enum.TextXAlignment.Left
local callSubtext = makeLabel(
	"CallSubtext",
	callPanel,
	UDim2.new(0.63, 0, 0, 18),
	UDim2.new(0.33, -10, 0, 50),
	"The caller is warming up",
	13,
	COLORS.muted,
	Enum.Font.Gotham
)
callSubtext.TextSize = 11

local sceneSkipButton = Instance.new("TextButton")
sceneSkipButton.Name = "SkipScene"
sceneSkipButton.AnchorPoint = Vector2.new(1, 0)
sceneSkipButton.Position = UDim2.new(1, -12, 0, 10)
sceneSkipButton.Size = UDim2.fromOffset(92, 30)
sceneSkipButton.BackgroundColor3 = COLORS.panelLight
sceneSkipButton.BorderSizePixel = 0
sceneSkipButton.Text = "Skip scene"
sceneSkipButton.TextColor3 = COLORS.white
sceneSkipButton.TextSize = 12
sceneSkipButton.Font = Enum.Font.GothamBold
sceneSkipButton.Visible = false
sceneSkipButton.Parent = callPanel
addCorner(sceneSkipButton, 10)

local callProgressBack = makeFrame(
	"CallProgressBack",
	callPanel,
	UDim2.new(0.04, 0, 1, -8),
	UDim2.new(0.92, 0, 0, 4),
	COLORS.panelLight
)
local callProgress = makeFrame("CallProgress", callProgressBack, UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), COLORS.teal)

local cardPanel = makeFrame("CardPanel", gamePanel, UDim2.new(0, 0, 0, 96), UDim2.new(1, 0, 0, 360), COLORS.cream)
addCorner(cardPanel, 18)
local columnHeader = makeFrame("ColumnHeader", cardPanel, UDim2.new(0, 12, 0, 8), UDim2.new(1, -24, 0, 30), COLORS.cream, 1)
local headerGrid = Instance.new("UIGridLayout")
headerGrid.CellSize = UDim2.new(0.2, -4, 1, 0)
headerGrid.CellPadding = UDim2.fromOffset(5, 0)
headerGrid.SortOrder = Enum.SortOrder.LayoutOrder
headerGrid.Parent = columnHeader

for columnIndex, letter in { "B", "I", "N", "G", "O" } do
	local letterLabel = makeLabel(
		`Column{letter}`,
		columnHeader,
		UDim2.new(),
		UDim2.new(1, 0, 1, 0),
		letter,
		16,
		COLORS.ink,
		Enum.Font.GothamBlack
	)
	letterLabel.LayoutOrder = columnIndex
end

local cardGrid = makeFrame("CardGrid", cardPanel, UDim2.new(0, 12, 0, 44), UDim2.new(1, -24, 0, 300), COLORS.cream, 1)
local cardLayout = Instance.new("UIGridLayout")
cardLayout.CellSize = UDim2.new(0.2, -4, 0, 54)
cardLayout.CellPadding = UDim2.fromOffset(5, 4)
cardLayout.SortOrder = Enum.SortOrder.LayoutOrder
cardLayout.Parent = cardGrid

local recentCalls = makeLabel(
	"RecentCalls",
	gamePanel,
	UDim2.new(0, 4, 1, -40),
	UDim2.new(1, -8, 0, 32),
	"Recent: —",
	13,
	COLORS.muted,
	Enum.Font.GothamMedium
)

local resultBanner = makeFrame("ResultBanner", gamePanel, UDim2.fromScale(0.04, 0.28), UDim2.new(0.92, 0, 0, 110), COLORS.tealDark)
resultBanner.Visible = false
addCorner(resultBanner, 18)
addStroke(resultBanner, COLORS.teal, 2, 0.1)
local resultTitle = makeLabel(
	"ResultTitle",
	resultBanner,
	UDim2.new(0.05, 0, 0.12, 0),
	UDim2.new(0.9, 0, 0, 40),
	"BINGO!",
	26,
	COLORS.white,
	Enum.Font.GothamBlack
)
local resultDetail = makeLabel(
	"ResultDetail",
	resultBanner,
	UDim2.new(0.05, 0, 0.53, 0),
	UDim2.new(0.9, 0, 0, 32),
	"Next match soon",
	15,
	COLORS.cream,
	Enum.Font.GothamBold
)

local toast = makeLabel(
	"Toast",
	root,
	UDim2.new(0.05, 0, 1, -46),
	UDim2.new(0.9, 0, 0, 28),
	"",
	14,
	COLORS.teal,
	Enum.Font.GothamBold
)

local loadingLabel = makeLabel(
	"Loading",
	root,
	UDim2.new(0, 0, 0.5, -20),
	UDim2.new(1, 0, 0, 40),
	"Finding your game...",
	16,
	COLORS.muted,
	Enum.Font.GothamMedium
)

local currentSnapshot: Snapshot? = nil
local cellButtons: { [number]: TextButton } = {}
local activeSceneKey = ""
local skippedSceneKey = ""
local revealedCardMatchId = -1
local sceneToken = 0
local cameraTween: Tween? = nil

local function restoreGameplayCamera(): ()
	sceneToken += 1
	if cameraTween then
		cameraTween:Cancel()
		cameraTween = nil
	end
	local camera = Workspace.CurrentCamera
	if not camera then
		return
	end
	camera.CameraType = Enum.CameraType.Custom
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		camera.CameraSubject = humanoid
	end
end

local function playCameraScene(sceneKey: string, duration: number): ()
	if activeSceneKey == sceneKey then
		return
	end
	activeSceneKey = sceneKey
	skippedSceneKey = ""
	sceneToken += 1
	local thisSceneToken = sceneToken
	local camera = Workspace.CurrentCamera
	local world = Workspace:FindFirstChild("BingoWorld")
	local mc = world and world:FindFirstChild("BingoMC")
	local head = mc and mc:FindFirstChild("Head")
	if camera and head and head:IsA("BasePart") then
		camera.CameraType = Enum.CameraType.Scriptable
		local focus = head.Position
		local target = CFrame.lookAt(focus + Vector3.new(0, 1.5, -10), focus)
		local tweenDuration = math.min(0.8, math.max(0.2, duration))
		cameraTween = TweenService:Create(
			camera,
			TweenInfo.new(tweenDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ CFrame = target }
		)
		cameraTween:Play()
	end
	task.delay(math.max(0.1, duration), function()
		if sceneToken == thisSceneToken then
			restoreGameplayCamera()
		end
	end)
end

for cellIndex = 1, 25 do
	local button = Instance.new("TextButton")
	button.Name = `Cell{cellIndex}`
	button.LayoutOrder = cellIndex
	button.BackgroundColor3 = COLORS.white
	button.BorderSizePixel = 0
	button.AutoButtonColor = false
	button.Font = Enum.Font.GothamBold
	button.Text = ""
	button.TextColor3 = COLORS.ink
	button.TextScaled = true
	button.Parent = cardGrid
	addCorner(button, 9)
	cellButtons[cellIndex] = button

	local sizeConstraint = Instance.new("UITextSizeConstraint")
	sizeConstraint.MinTextSize = 16
	sizeConstraint.MaxTextSize = 26
	sizeConstraint.Parent = button

	button.Activated:Connect(function()
		local snapshot = currentSnapshot
		if not snapshot or not snapshot.isParticipant or snapshot.phase ~= "CallingNumbers" then
			return
		end
		markCellRemote:FireServer(snapshot.matchId, cellIndex)
	end)
end

sceneSkipButton.Activated:Connect(function()
	local snapshot = currentSnapshot
	if not snapshot then
		return
	end
	skippedSceneKey = activeSceneKey
	sceneSkipButton.Visible = false
	if snapshot.phase == "MatchIntro" and snapshot.isParticipant then
		skipSceneRemote:FireServer(snapshot.matchId)
	end
	restoreGameplayCamera()
end)

----- State Rendering -----
local function formatCall(number: number?): string
	if not number then
		return "Ready?"
	end
	local columnIndex = math.clamp(math.ceil(number / 15), 1, 5)
	local letters = { "B", "I", "N", "G", "O" }
	return `{letters[columnIndex]} — {number}`
end

local function renderCard(card: { CardCell }?)
	for cellIndex, button in cellButtons do
		local cell = if card then card[cellIndex] else nil
		if not cell then
			button.Text = ""
			button.BackgroundColor3 = COLORS.white
			button.TextColor3 = COLORS.ink
			button.Active = false
			continue
		end

		button.Text = if cell.isFree then "FREE" else tostring(cell.number)
		button.BackgroundColor3 = if cell.isFree then COLORS.yellow else if cell.isMarked then COLORS.teal else COLORS.white
		button.TextColor3 = COLORS.ink
		button.Active = not cell.isMarked
	end
end

local function render(snapshot: Snapshot)
	currentSnapshot = snapshot
	loadingLabel.Visible = false
	local isActiveParticipant = snapshot.isParticipant
	local isPlaying = isActiveParticipant and (
		snapshot.phase == "MatchIntro" or snapshot.phase == "CallingNumbers" or snapshot.phase == "RoundComplete"
	)
	lobbyPanel.Visible = not isPlaying
	gamePanel.Visible = isPlaying
	phasePill.Text = if snapshot.phase == "MatchIntro" and isActiveParticipant then "MEET THE MC"
		elseif snapshot.phase == "CallingNumbers" and isActiveParticipant then "IN GAME"
		elseif snapshot.phase == "RoundComplete" and isActiveParticipant then "RESULTS"
		elseif snapshot.phase == "LobbyCountdown" then "STARTING"
		else "LOBBY"

	local playersNeeded = math.max(0, snapshot.minimumPlayers - snapshot.waitingPlayers)
	if snapshot.phase == "LobbyCountdown" then
		lobbyStatus.Text = if snapshot.isQueued
			then `Match starts in {snapshot.timeRemaining}...`
			else "A match is starting. Use the portal to join the next one."
		lobbyStatus.TextColor3 = COLORS.teal
	elseif snapshot.phase == "MatchIntro" or snapshot.phase == "CallingNumbers" or snapshot.phase == "RoundComplete" then
		lobbyStatus.Text = if snapshot.isQueued then "You're queued for the next match." else "A match is in progress. Use the portal to join next."
		lobbyStatus.TextColor3 = COLORS.yellow
	elseif playersNeeded > 0 then
		lobbyStatus.Text = if snapshot.isQueued
			then `In line! Waiting for {playersNeeded} more player{if playersNeeded == 1 then "" else "s"}...`
			else "Walk to the glowing portal and press E or tap it to join."
		lobbyStatus.TextColor3 = COLORS.yellow
	else
		lobbyStatus.Text = "Getting the next match ready..."
		lobbyStatus.TextColor3 = COLORS.teal
	end
	lobbyCount.Text = `{snapshot.waitingPlayers} / {snapshot.minimumPlayers} players in the queue`
	lobbyInstructions.Text = if snapshot.isQueued
		then "You're in line. Use the glowing portal again to leave the queue."
		else "Walk to the glowing Bingo portal and press E or tap the prompt to join."
	if snapshot.phase == "LobbyWaiting" or snapshot.phase == "LobbyCountdown" then
		lobbyTitle.Text = if snapshot.isQueued then "You're in the queue" else "Ready to play Bingo?"
	elseif not isActiveParticipant then
		lobbyTitle.Text = "You're up next"
	end

	if isPlaying then
		local isIntro = snapshot.phase == "MatchIntro"
		local isResults = snapshot.phase == "RoundComplete"
		if isIntro then
			callCaption.Text = if snapshot.isFirstMatch then "WELCOME TO BINGO!" else "WELCOME BACK!"
			currentCall.Text = if snapshot.isFirstMatch
				then "Find my number. Tap it to mark it."
				else "Watch for my number. Tap it to mark it."
			currentCall.TextSize = 18
			callSubtext.Text = "Fill your card to win. Center is FREE."
			callProgress.Size = UDim2.fromScale(0, 1)
			local sceneKey = `{snapshot.matchId}:intro`
			playCameraScene(sceneKey, math.max(snapshot.timeRemaining, 1))
			if revealedCardMatchId ~= snapshot.matchId then
				revealedCardMatchId = snapshot.matchId
				cardPanel.ClipsDescendants = true
				cardPanel.Size = UDim2.new(1, 0, 0, 0)
				TweenService:Create(
					cardPanel,
					TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
					{ Size = UDim2.new(1, 0, 0, 360) }
				):Play()
			end
		elseif isResults then
			callCaption.Text = "MC ANNOUNCES"
			currentCall.Text = formatCall(snapshot.lastCalledNumber)
			currentCall.TextSize = 34
			callSubtext.Text = if snapshot.result and snapshot.result.isDraw
				then "MC: No winner this time."
				else `MC: {if snapshot.result then snapshot.result.winnerName or "A player" else "A player"} got Bingo!`
			callProgress.Size = UDim2.fromScale(0, 1)
			playCameraScene(`{snapshot.matchId}:result`, 3)
		else
			callCaption.Text = `NEXT CALL IN {snapshot.timeRemaining}s`
			currentCall.Text = formatCall(snapshot.lastCalledNumber)
			currentCall.TextSize = 34
			callSubtext.Text = "MC: Tap it. Fill your card to win."
			callProgress.Size = UDim2.fromScale(math.clamp(snapshot.timeRemaining / 5, 0, 1), 1)
		end
		local currentSceneKey = if isIntro then `{snapshot.matchId}:intro` elseif isResults then `{snapshot.matchId}:result` else ""
		sceneSkipButton.Visible = currentSceneKey ~= "" and currentSceneKey ~= skippedSceneKey
		sceneSkipButton.Text = if isResults then "Continue" else "Skip scene"
		renderCard(snapshot.card)
		local recent: { string } = {}
		local startIndex = math.max(1, #snapshot.calledNumbers - 4)
		for index = startIndex, #snapshot.calledNumbers do
			table.insert(recent, formatCall(snapshot.calledNumbers[index]))
		end
		recentCalls.Text = `Recent: {if #recent > 0 then table.concat(recent, "   ·   ") else "—"}`

		resultBanner.Visible = isResults
		if isResults and snapshot.result then
			if snapshot.result.isDraw then
				resultTitle.Text = "NO BINGO THIS TIME"
				resultDetail.Text = `All numbers called · Lobby in {snapshot.timeRemaining}s`
			else
				resultTitle.Text = if snapshot.result.winnerUserId == player.UserId
					then "BINGO! YOU WON!"
					else `{snapshot.result.winnerName or "A player"} GOT BINGO!`
				resultDetail.Text = `{snapshot.result.winnerName or "A player"} wins · Lobby in {snapshot.timeRemaining}s`
			end
		end
	else
		sceneSkipButton.Visible = false
	end

	toast.Text = snapshot.notice or ""
	toast.TextColor3 = if snapshot.notice and string.find(snapshot.notice, "not") then COLORS.error else COLORS.teal
end

local function onRoundUpdate(payload: unknown)
	if typeof(payload) ~= "table" then
		return
	end
	local snapshot = payload :: Snapshot
	if snapshot.kind ~= "Snapshot" then
		return
	end
	render(snapshot)
end

----- Initialization -----
local BingoController = {}

function BingoController.Start(): ()
	roundUpdateRemote.OnClientEvent:Connect(onRoundUpdate)
	requestSnapshotRemote:FireServer()
end

return BingoController
