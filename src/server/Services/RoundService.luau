--!strict
-- Owns queue enrollment, Bingo match state, cards, calls, marks, and results.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local GameConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("GameConfig"))
local LobbyWorldService = require(script.Parent:WaitForChild("LobbyWorldService"))

type Phase = "LobbyWaiting" | "LobbyCountdown" | "MatchIntro" | "CallingNumbers" | "RoundComplete"
type CardCell = { number: number, isFree: boolean, isMarked: boolean }
type Participant = { card: { CardCell }, isFirstMatch: boolean }
type Result = { isDraw: boolean, winnerUserId: number?, winnerName: string? }

local BINGO_COLUMNS: { { minimum: number, maximum: number } } = {
	{ minimum = 1, maximum = 15 },
	{ minimum = 16, maximum = 30 },
	{ minimum = 31, maximum = 45 },
	{ minimum = 46, maximum = 60 },
	{ minimum = 61, maximum = 75 },
}

local function ensureFolder(parent: Instance, name: string): Folder
	local existing = parent:FindFirstChild(name)
	if existing then
		assert(existing:IsA("Folder"), `{existing:GetFullName()} must be a Folder`)
		return existing
	end
	local folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = parent
	return folder
end

local function ensureRemoteEvent(parent: Instance, name: string): RemoteEvent
	local existing = parent:FindFirstChild(name)
	if existing then
		assert(existing:IsA("RemoteEvent"), `{existing:GetFullName()} must be a RemoteEvent`)
		return existing
	end
	local remote = Instance.new("RemoteEvent")
	remote.Name = name
	remote.Parent = parent
	return remote
end

local remotes = ensureFolder(ReplicatedStorage, "Remotes")
local roundUpdateRemote = ensureRemoteEvent(remotes, "RoundUpdate")
local markCellRemote = ensureRemoteEvent(remotes, "MarkCell")
local requestSnapshotRemote = ensureRemoteEvent(remotes, "RequestSnapshot")
local skipSceneRemote = ensureRemoteEvent(remotes, "SkipScene")

local phase: Phase = "LobbyWaiting"
local participants: { [number]: Participant } = {}
local queuedPlayerIds: { [number]: boolean } = {}
local tutorialSeenUserIds: { [number]: boolean } = {}
local calledNumbers: { number } = {}
local calledNumberSet: { [number]: boolean } = {}
local callDeck: { number } = {}
local result: Result? = nil
local skippedIntroByUserId: { [number]: boolean } = {}
local phaseDeadline = 0
local matchId = 0
local countdownToken = 0
local resultToken = 0
local lastMarkRequest: { [Player]: number } = {}
local lastSnapshotRequest: { [Player]: number } = {}
local lastQueueInteraction: { [Player]: number } = {}
local characterConnections: { [Player]: RBXScriptConnection } = {}
local randomGenerator = Random.new()
local considerStartingCountdown: () -> ()

local function minimumPlayerCount(): number
	if RunService:IsStudio() and GameConfig.SOLO_STUDIO_OVERRIDE then
		return 1
	end
	return GameConfig.MINIMUM_PLAYERS
end

local function countWaitingPlayers(excludedPlayer: Player?): number
	local count = 0
	for userId in queuedPlayerIds do
		local player = Players:GetPlayerByUserId(userId)
		if player and player ~= excludedPlayer and participants[userId] == nil then
			count += 1
		end
	end
	return count
end

local function isFiniteNumber(value: unknown): boolean
	if typeof(value) ~= "number" then
		return false
	end
	local numberValue = value :: number
	return numberValue == numberValue and math.abs(numberValue) ~= math.huge
end

local function makeShuffledNumbers(minimum: number, maximum: number): { number }
	local numbers: { number } = {}
	for value = minimum, maximum do
		table.insert(numbers, value)
	end
	for index = #numbers, 2, -1 do
		local swapIndex = randomGenerator:NextInteger(1, index)
		numbers[index], numbers[swapIndex] = numbers[swapIndex], numbers[index]
	end
	return numbers
end

local function makeCard(): { CardCell }
	local columns: { { number } } = {}
	for columnIndex, range in BINGO_COLUMNS do
		local values = makeShuffledNumbers(range.minimum, range.maximum)
		local selectedValues: { number } = {}
		for rowIndex = 1, 5 do
			selectedValues[rowIndex] = values[rowIndex]
		end
		table.sort(selectedValues)
		columns[columnIndex] = selectedValues
	end

	local card: { CardCell } = {}
	for rowIndex = 1, 5 do
		for columnIndex = 1, 5 do
			local cellIndex = (rowIndex - 1) * 5 + columnIndex
			local isFree = cellIndex == 13
			table.insert(card, {
				number = if isFree then 0 else columns[columnIndex][rowIndex],
				isFree = isFree,
				isMarked = isFree,
			})
		end
	end
	return card
end

local function isFullCard(card: { CardCell }): boolean
	for _, cell in card do
		if not cell.isMarked then
			return false
		end
	end
	return true
end

local function copyCard(card: { CardCell }?): { CardCell }?
	if not card then
		return nil
	end
	local copy: { CardCell } = {}
	for index, cell in card do
		copy[index] = { number = cell.number, isFree = cell.isFree, isMarked = cell.isMarked }
	end
	return copy
end

local function movePlayer(player: Player, destination: CFrame): ()
	task.spawn(function()
		local character = player.Character or player.CharacterAdded:Wait()
		local root = character:WaitForChild("HumanoidRootPart", 10)
		if root and root:IsA("BasePart") and player.Parent == Players then
			root.CFrame = destination
		end
	end)
end

local function sendSnapshot(player: Player, notice: string?): ()
	local participant = participants[player.UserId]
	roundUpdateRemote:FireClient(player, {
		kind = "Snapshot",
		phase = phase,
		matchId = matchId,
		minimumPlayers = minimumPlayerCount(),
		waitingPlayers = countWaitingPlayers(),
		isQueued = queuedPlayerIds[player.UserId] == true,
		isFirstMatch = if participant then participant.isFirstMatch else false,
		timeRemaining = math.max(0, math.ceil(phaseDeadline - os.clock())),
		calledNumbers = table.clone(calledNumbers),
		lastCalledNumber = calledNumbers[#calledNumbers],
		card = if participant then copyCard(participant.card) else nil,
		isParticipant = participant ~= nil,
		result = result,
		notice = notice,
	})
end

local function broadcastSnapshots(noticeByUserId: { [number]: string }?): ()
	local waitingPlayers = countWaitingPlayers()
	if phase == "LobbyCountdown" then
		LobbyWorldService.SetQueueStatus(`BINGO\nSTARTING IN {math.max(0, math.ceil(phaseDeadline - os.clock()))}\n{waitingPlayers}/{minimumPlayerCount()} PLAYERS`)
	elseif phase == "MatchIntro" or phase == "CallingNumbers" or phase == "RoundComplete" then
		LobbyWorldService.SetQueueStatus(`MATCH IN PROGRESS\n{waitingPlayers} WAITING FOR NEXT MATCH`)
	else
		LobbyWorldService.SetQueueStatus(`BINGO\n{waitingPlayers}/{minimumPlayerCount()} WAITING\nUSE PORTAL TO JOIN`)
	end
	for _, player in Players:GetPlayers() do
		sendSnapshot(player, if noticeByUserId then noticeByUserId[player.UserId] else nil)
	end
end

local function returnParticipantsToLobby(): ()
	for _, player in Players:GetPlayers() do
		if participants[player.UserId] then
			movePlayer(player, LobbyWorldService.GetLobbyCFrame())
		end
	end
end

local function resetToLobby(): ()
	returnParticipantsToLobby()
	phase = "LobbyWaiting"
	participants = {}
	calledNumbers = {}
	calledNumberSet = {}
	callDeck = {}
	result = nil
	phaseDeadline = 0
	broadcastSnapshots(nil)
	considerStartingCountdown()
end

local function finishMatch(matchResult: Result): ()
	if phase ~= "CallingNumbers" then
		return
	end
	phase = "RoundComplete"
	result = matchResult
	resultToken += 1
	local thisResultToken = resultToken
	phaseDeadline = os.clock() + GameConfig.RESULT_DURATION_SECONDS
	LobbyWorldService.SetMCDialogue(if matchResult.isDraw then "No Bingo this time!" else `{matchResult.winnerName} got Bingo!`)
	broadcastSnapshots(nil)

	task.spawn(function()
		for secondsRemaining = GameConfig.RESULT_DURATION_SECONDS - 1, 0, -1 do
			task.wait(1)
			if resultToken ~= thisResultToken or phase ~= "RoundComplete" then
				return
			end
			phaseDeadline = os.clock() + secondsRemaining
			broadcastSnapshots(nil)
		end
		if resultToken == thisResultToken and phase == "RoundComplete" then
			resetToLobby()
		end
	end)
end

local function allParticipantsSkippedIntro(): boolean
	for userId in participants do
		if not skippedIntroByUserId[userId] then
			return false
		end
	end
	return next(participants) ~= nil
end

local function callNextNumber(thisMatchId: number): boolean
	if phase ~= "CallingNumbers" or matchId ~= thisMatchId then
		return false
	end
	local nextNumber = table.remove(callDeck)
	if not nextNumber then
		finishMatch({ isDraw = true })
		return false
	end
	table.insert(calledNumbers, nextNumber)
	calledNumberSet[nextNumber] = true
	local columnIndex = math.clamp(math.ceil(nextNumber / 15), 1, 5)
	local letters = { "B", "I", "N", "G", "O" }
	LobbyWorldService.SetMCDialogue(`{letters[columnIndex]} — {nextNumber}! Find it on your card!`)
	phaseDeadline = os.clock() + GameConfig.CALL_INTERVAL_SECONDS
	broadcastSnapshots(nil)
	return true
end

local function startCallLoop(thisMatchId: number): ()
	if not callNextNumber(thisMatchId) then
		return
	end
	task.spawn(function()
		while phase == "CallingNumbers" and matchId == thisMatchId do
			task.wait(1)
			if phase ~= "CallingNumbers" or matchId ~= thisMatchId then
				return
			end
			if os.clock() >= phaseDeadline then
				if not callNextNumber(thisMatchId) then
					return
				end
			else
				broadcastSnapshots(nil)
			end
		end
	end)
end

local function startMatch(): ()
	countdownToken += 1
	phase = "MatchIntro"
	matchId += 1
	calledNumbers = {}
	calledNumberSet = {}
	callDeck = makeShuffledNumbers(1, 75)
	result = nil
	skippedIntroByUserId = {}
	participants = {}
	local queuedIds: { number } = {}
	for userId in queuedPlayerIds do
		table.insert(queuedIds, userId)
	end
	queuedPlayerIds = {}
	local seatIndex = 0
	local introDuration = GameConfig.REPEAT_INTRO_SECONDS
	local hasFirstMatchPlayer = false
	for _, userId in queuedIds do
		local player = Players:GetPlayerByUserId(userId)
		if player then
			seatIndex += 1
			local isFirstMatch = tutorialSeenUserIds[userId] ~= true
			participants[userId] = { card = makeCard(), isFirstMatch = isFirstMatch }
			if isFirstMatch then
				introDuration = GameConfig.INTRO_CUTSCENE_SECONDS
				hasFirstMatchPlayer = true
				tutorialSeenUserIds[userId] = true
			end
			movePlayer(player, LobbyWorldService.GetMatchCFrame(seatIndex))
		end
	end
	phaseDeadline = os.clock() + introDuration
	LobbyWorldService.SetMCDialogue(if hasFirstMatchPlayer
		then "Welcome to Bingo! Let me show you how to play."
		else "Welcome back! Get ready to play!"
	)
	broadcastSnapshots(nil)

	local thisMatchId = matchId
	task.spawn(function()
		while phase == "MatchIntro" and matchId == thisMatchId and os.clock() < phaseDeadline
			and not allParticipantsSkippedIntro()
		do
			task.wait(1)
			broadcastSnapshots(nil)
		end
		if phase == "MatchIntro" and matchId == thisMatchId then
			phase = "CallingNumbers"
			startCallLoop(thisMatchId)
		end
	end)
end

considerStartingCountdown = function(): ()
	if phase ~= "LobbyWaiting" or countWaitingPlayers() < minimumPlayerCount() then
		if phase == "LobbyWaiting" then
			broadcastSnapshots(nil)
		end
		return
	end
	phase = "LobbyCountdown"
	countdownToken += 1
	local thisCountdownToken = countdownToken
	phaseDeadline = os.clock() + GameConfig.LOBBY_COUNTDOWN_SECONDS
	broadcastSnapshots(nil)
	task.spawn(function()
		for secondsRemaining = GameConfig.LOBBY_COUNTDOWN_SECONDS - 1, 0, -1 do
			task.wait(1)
			if countdownToken ~= thisCountdownToken or phase ~= "LobbyCountdown" then
				return
			end
			if countWaitingPlayers() < minimumPlayerCount() then
				phase = "LobbyWaiting"
				phaseDeadline = 0
				countdownToken += 1
				broadcastSnapshots(nil)
				return
			end
			phaseDeadline = os.clock() + secondsRemaining
			broadcastSnapshots(nil)
		end
		if countdownToken == thisCountdownToken and phase == "LobbyCountdown"
			and countWaitingPlayers() >= minimumPlayerCount()
		then
			startMatch()
		end
	end)
end

local function onPortalTriggered(player: Player): ()
	local now = os.clock()
	local previousInteraction = lastQueueInteraction[player]
	if previousInteraction and now - previousInteraction < 0.75 then
		return
	end
	lastQueueInteraction[player] = now
	if not LobbyWorldService.IsNearQueuePortal(player) then
		return
	end
	if participants[player.UserId] then
		sendSnapshot(player, "You're already in this match.")
		return
	end
	if queuedPlayerIds[player.UserId] then
		queuedPlayerIds[player.UserId] = nil
		sendSnapshot(player, "You left the Bingo queue. Use the portal to join again.")
		if phase == "LobbyCountdown" and countWaitingPlayers() < minimumPlayerCount() then
			countdownToken += 1
			phase = "LobbyWaiting"
			phaseDeadline = 0
		end
	else
		queuedPlayerIds[player.UserId] = true
	end
	if phase == "LobbyWaiting" then
		considerStartingCountdown()
	else
		broadcastSnapshots(nil)
	end
end

local function onPlayerAdded(player: Player): ()
	local oldConnection = characterConnections[player]
	if oldConnection then
		oldConnection:Disconnect()
	end
	characterConnections[player] = player.CharacterAdded:Connect(function()
		task.defer(function()
			local participant = participants[player.UserId]
			if participant then
				local participantIndex = 1
				for userId in participants do
					if userId == player.UserId then
						break
					end
					participantIndex += 1
				end
				movePlayer(player, LobbyWorldService.GetMatchCFrame(participantIndex))
			else
				movePlayer(player, LobbyWorldService.GetLobbyCFrame())
			end
		end)
	end)
	if player.Character then
		movePlayer(player, LobbyWorldService.GetLobbyCFrame())
	end
	sendSnapshot(player, "Walk to the glowing portal and press E or tap it to join Bingo.")
end

local function onPlayerRemoving(player: Player): ()
	lastMarkRequest[player] = nil
	lastSnapshotRequest[player] = nil
	lastQueueInteraction[player] = nil
	queuedPlayerIds[player.UserId] = nil
	tutorialSeenUserIds[player.UserId] = nil
	participants[player.UserId] = nil
	local connection = characterConnections[player]
	if connection then
		connection:Disconnect()
		characterConnections[player] = nil
	end
	if next(participants) == nil and (phase == "MatchIntro" or phase == "CallingNumbers") then
		matchId += 1
		phase = "LobbyWaiting"
		calledNumbers = {}
		calledNumberSet = {}
		callDeck = {}
		phaseDeadline = 0
	end
	if phase == "LobbyCountdown" and countWaitingPlayers(player) < minimumPlayerCount() then
		countdownToken += 1
		phase = "LobbyWaiting"
		phaseDeadline = 0
	end
	task.defer(function()
		broadcastSnapshots(nil)
		if phase == "LobbyWaiting" then
			considerStartingCountdown()
		end
	end)
end

local function onRequestSnapshot(player: Player): ()
	local now = os.clock()
	local previousRequest = lastSnapshotRequest[player]
	if previousRequest and now - previousRequest < 0.5 then
		return
	end
	lastSnapshotRequest[player] = now
	sendSnapshot(player, nil)
end

local function onSkipScene(player: Player, requestedMatchId: unknown): ()
	if typeof(requestedMatchId) ~= "number" or not isFiniteNumber(requestedMatchId)
		or requestedMatchId ~= matchId or phase ~= "MatchIntro"
		or participants[player.UserId] == nil
	then
		return
	end
	skippedIntroByUserId[player.UserId] = true
end

local function onMarkCell(player: Player, matchIdValue: unknown, cellIndexValue: unknown): ()
	local now = os.clock()
	local previousRequest = lastMarkRequest[player]
	if previousRequest and now - previousRequest < GameConfig.MARK_REQUEST_INTERVAL_SECONDS then
		return
	end
	lastMarkRequest[player] = now
	if typeof(matchIdValue) ~= "number" then
		sendSnapshot(player, "That match is no longer active.")
		return
	end
	local requestedMatchId = matchIdValue :: number
	if not isFiniteNumber(requestedMatchId) or requestedMatchId ~= matchId or phase ~= "CallingNumbers" then
		sendSnapshot(player, "That match is no longer active.")
		return
	end
	if typeof(cellIndexValue) ~= "number" then
		sendSnapshot(player, "That square is not valid.")
		return
	end
	local cellIndex = cellIndexValue :: number
	if not isFiniteNumber(cellIndex) or cellIndex ~= math.floor(cellIndex) or cellIndex < 1 or cellIndex > 25 then
		sendSnapshot(player, "That square is not valid.")
		return
	end
	local participant = participants[player.UserId]
	if not participant then
		sendSnapshot(player, "You are waiting for the next match.")
		return
	end
	local cell = participant.card[cellIndex]
	if not cell or cell.isMarked then
		return
	end
	if not cell.isFree and not calledNumberSet[cell.number] then
		sendSnapshot(player, "That number has not been called yet.")
		return
	end
	cell.isMarked = true
	if isFullCard(participant.card) then
		finishMatch({ isDraw = false, winnerUserId = player.UserId, winnerName = player.DisplayName })
		return
	end
	sendSnapshot(player, "Marked!")
end

local RoundService = {}

function RoundService.Start(): ()
	local queuePrompt = LobbyWorldService.Start()
	queuePrompt.Triggered:Connect(onPortalTriggered)
	markCellRemote.OnServerEvent:Connect(onMarkCell)
	requestSnapshotRemote.OnServerEvent:Connect(onRequestSnapshot)
	skipSceneRemote.OnServerEvent:Connect(onSkipScene)
	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(onPlayerRemoving)
	for _, player in Players:GetPlayers() do
		task.spawn(onPlayerAdded, player)
	end
	print("[RoundService] Bingo portal and queue are ready.")
end

return RoundService
