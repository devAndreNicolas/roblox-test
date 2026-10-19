--!strict
-- RoundService
-- Owns the lobby, Bingo match state, cards, calls, marks, and results.
-- Container: ServerScriptService/Server/Services

----- Services -----
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

----- Dependencies -----
local GameConfig = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("GameConfig"))

----- Types -----
type Phase = "LobbyWaiting" | "LobbyCountdown" | "CallingNumbers" | "RoundComplete"

type CardCell = {
	number: number,
	isFree: boolean,
	isMarked: boolean,
}

type Participant = {
	card: { CardCell },
}

type Result = {
	isDraw: boolean,
	winnerUserId: number?,
	winnerName: string?,
}

----- Constants -----
local BINGO_COLUMNS: { { minimum: number, maximum: number } } = {
	{ minimum = 1, maximum = 15 },
	{ minimum = 16, maximum = 30 },
	{ minimum = 31, maximum = 45 },
	{ minimum = 46, maximum = 60 },
	{ minimum = 61, maximum = 75 },
}

----- Remotes -----
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

	local remoteEvent = Instance.new("RemoteEvent")
	remoteEvent.Name = name
	remoteEvent.Parent = parent
	return remoteEvent
end

local remotesFolder = ensureFolder(ReplicatedStorage, "Remotes")
local roundUpdateRemote = ensureRemoteEvent(remotesFolder, "RoundUpdate")
local markCellRemote = ensureRemoteEvent(remotesFolder, "MarkCell")
local requestSnapshotRemote = ensureRemoteEvent(remotesFolder, "RequestSnapshot")

----- State -----
local phase: Phase = "LobbyWaiting"
local participants: { [number]: Participant } = {}
local calledNumbers: { number } = {}
local calledNumberSet: { [number]: boolean } = {}
local callDeck: { number } = {}
local result: Result? = nil
local phaseDeadline = 0
local matchId = 0
local countdownToken = 0
local resultToken = 0
local lastMarkRequest: { [Player]: number } = {}
local lastSnapshotRequest: { [Player]: number } = {}
local randomGenerator = Random.new()
local considerStartingCountdown: () -> ()

----- Private Functions -----
local function countWaitingPlayers(excludedPlayer: Player?): number
	local count = 0
	for _, player in Players:GetPlayers() do
		if player ~= excludedPlayer and participants[player.UserId] == nil then
			count += 1
		end
	end
	return count
end

local function minimumPlayerCount(): number
	if RunService:IsStudio() and GameConfig.SOLO_STUDIO_OVERRIDE then
		return 1
	end
	return GameConfig.MINIMUM_PLAYERS
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
		table.sort(selectedValues, function(left: number, right: number): boolean
			return left < right
	end)
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
		copy[index] = {
			number = cell.number,
			isFree = cell.isFree,
			isMarked = cell.isMarked,
		}
	end
	return copy
end

local function sendSnapshot(player: Player, notice: string?): ()
	local participant = participants[player.UserId]
	local timeRemaining = math.max(0, math.ceil(phaseDeadline - os.clock()))
	roundUpdateRemote:FireClient(player, {
		kind = "Snapshot",
		phase = phase,
		matchId = matchId,
		minimumPlayers = minimumPlayerCount(),
		waitingPlayers = countWaitingPlayers(),
		timeRemaining = timeRemaining,
		calledNumbers = table.clone(calledNumbers),
		lastCalledNumber = calledNumbers[#calledNumbers],
		card = if participant then copyCard(participant.card) else nil,
		isParticipant = participant ~= nil,
		result = result,
		notice = notice,
	})
end

local function broadcastSnapshots(noticeByUserId: { [number]: string }?): ()
	for _, player in Players:GetPlayers() do
		sendSnapshot(player, if noticeByUserId then noticeByUserId[player.UserId] else nil)
	end
end

local function resetToLobby(): ()
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

local function startCallLoop(thisMatchId: number): ()
	task.spawn(function()
		while phase == "CallingNumbers" and matchId == thisMatchId do
			task.wait(GameConfig.CALL_INTERVAL_SECONDS)
			if phase ~= "CallingNumbers" or matchId ~= thisMatchId then
				return
			end

			local nextNumber = table.remove(callDeck)
			if not nextNumber then
				finishMatch({ isDraw = true })
				return
			end

			table.insert(calledNumbers, nextNumber)
			calledNumberSet[nextNumber] = true
			broadcastSnapshots(nil)
		end
	end)
end

local function startMatch(): ()
	countdownToken += 1
	phase = "CallingNumbers"
	matchId += 1
	calledNumbers = {}
	calledNumberSet = {}
	callDeck = makeShuffledNumbers(1, 75)
	result = nil
	phaseDeadline = 0
	participants = {}
	for _, player in Players:GetPlayers() do
		participants[player.UserId] = { card = makeCard() }
	end

	broadcastSnapshots(nil)
	startCallLoop(matchId)
end

considerStartingCountdown = function(): ()
	if phase ~= "LobbyWaiting" then
		return
	end
	if countWaitingPlayers() < minimumPlayerCount() then
		broadcastSnapshots(nil)
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

local function onPlayerAdded(player: Player): ()
	sendSnapshot(player, nil)
	if phase == "LobbyWaiting" then
		considerStartingCountdown()
	else
		broadcastSnapshots(nil)
	end
end

local function onPlayerRemoving(player: Player): ()
	lastMarkRequest[player] = nil
	lastSnapshotRequest[player] = nil
	participants[player.UserId] = nil

	local remainingPlayerCount = 0
	for _, otherPlayer in Players:GetPlayers() do
		if otherPlayer ~= player then
			remainingPlayerCount += 1
		end
	end

	if remainingPlayerCount == 0 then
		countdownToken += 1
		resultToken += 1
		matchId += 1
		phase = "LobbyWaiting"
		participants = {}
		calledNumbers = {}
		calledNumberSet = {}
		callDeck = {}
		result = nil
		phaseDeadline = 0
		return
	end

	if phase == "CallingNumbers" and next(participants) == nil then
		matchId += 1
		phase = "LobbyWaiting"
		calledNumbers = {}
		calledNumberSet = {}
		callDeck = {}
		result = nil
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
	if not isFiniteNumber(cellIndex) or cellIndex ~= math.floor(cellIndex)
		or cellIndex < 1 or cellIndex > 25
	then
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
		finishMatch({
			isDraw = false,
			winnerUserId = player.UserId,
			winnerName = player.DisplayName,
		})
		return
	end
	sendSnapshot(player, "Marked!")
end

----- Public API -----
local RoundService = {}

function RoundService.Start(): ()
	markCellRemote.OnServerEvent:Connect(onMarkCell)
	requestSnapshotRemote.OnServerEvent:Connect(onRequestSnapshot)
	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(onPlayerRemoving)

	for _, player in Players:GetPlayers() do
		task.spawn(onPlayerAdded, player)
	end

	considerStartingCountdown()
	print("[RoundService] Bingo lobby is ready.")
end

return RoundService
