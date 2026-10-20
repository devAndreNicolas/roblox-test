--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Shared = game:GetService("ReplicatedStorage").Shared.Features.Bingo
local Config = require(Shared.BingoConfig)
local Types = require(Shared.BingoTypes)
local Rules = require(script.Parent.BingoRules)
local Queue = require(script.Parent.BingoQueue)
local Transport = require(script.Parent.BingoTransport)
local World = require(script.Parent.BingoWorld)
type Participant = {card: {Types.CardCell}, first: boolean, seat: number}
local Service = {}
local stop: (() -> ())? = nil
local readSnapshot: ((Player) -> Types.Snapshot)? = nil

function Service.Start(): ()
	if stop then return end
	local alive = true
	local sessionId = HttpService:GenerateGUID(false)
	local queue = Queue.new()
	local random = Random.new()
	local phase: Types.Phase = "LobbyWaiting"
	local matchId, deadline, duration = 0, 0, 0
	local noticeId = 0
	local participants: {[number]: Participant} = {}
	local seen: {[number]: boolean} = {}
	local skipped: {[number]: boolean} = {}
	local calls: {number} = {}
	local called: {[number]: boolean} = {}
	local deck: {number} = {}
	local result: Types.Result? = nil
	local connections: {RBXScriptConnection} = {}
	local characters: {[Player]: RBXScriptConnection} = {}
	local portalTimes: {[Player]: number} = {}
	local minimum = if RunService:IsStudio() and Config.SOLO_STUDIO_OVERRIDE then 1 else Config.MINIMUM_PLAYERS

	local function setPhase(nextPhase: Types.Phase, seconds: number): ()
		phase, duration = nextPhase, seconds
		deadline = if seconds > 0 then os.clock() + seconds else 0
	end
	local function snapshot(player: Player, notice: Types.Notice?): Types.Snapshot
		local participant = participants[player.UserId]
		return {
			kind = "Snapshot", sessionId = sessionId, phase = phase, matchId = matchId,
			minimumPlayers = minimum, maximumPlayers = Config.MAXIMUM_PLAYERS_PER_MATCH, waitingPlayers = queue.Count(),
			timeRemaining = math.max(0, deadline - os.clock()), phaseDurationSeconds = duration,
			callIntervalSeconds = Config.CALL_INTERVAL_SECONDS,
			isParticipant = participant ~= nil, isQueued = queue.Contains(player.UserId),
			isQueuedForCurrentMatch = queue.IsInFirst(player.UserId, Config.MAXIMUM_PLAYERS_PER_MATCH),
			isFirstMatch = if participant then participant.first else false,
			card = if participant then Rules.CopyCard(participant.card) else nil,
			calledNumbers = table.clone(calls), lastCalledNumber = calls[#calls], result = result, notice = notice,
		}
	end
	local transport: Transport.Connection
	local function send(player: Player, text: string?, kind: Types.NoticeKind?): ()
		local notice: Types.Notice? = nil
		if text then
			noticeId += 1
			notice = {id = noticeId, kind = kind or "info", text = text}
		end
		transport.Send(player, snapshot(player, notice))
	end
	local function broadcast(): ()
		local count = queue.Count()
		local message = if phase == "LobbyCountdown" then `BINGO NOIR • {math.ceil(math.max(0, deadline - os.clock()))}s\n{count} QUEUED • MAX {Config.MAXIMUM_PLAYERS_PER_MATCH}`
			elseif phase == "LobbyWaiting" then `BINGO NOIR\n{count} QUEUED • {minimum} TO START\nMAX {Config.MAXIMUM_PLAYERS_PER_MATCH} PER MATCH`
			else `BINGO NOIR\n{count} WAITING FOR NEXT MATCH`
		World.SetQueueStatus(message)
		for _, player in Players:GetPlayers() do send(player) end
	end
	local function place(player: Player): ()
		World.PlacePlayer(player, function()
			local participant = participants[player.UserId]
			return if participant then participant.seat else nil
		end)
	end
	local function considerCountdown(): ()
		if phase == "LobbyWaiting" and queue.Count() >= minimum then
			setPhase("LobbyCountdown", Config.LOBBY_COUNTDOWN_SECONDS)
		elseif phase == "LobbyCountdown" and queue.Count() < minimum then
			setPhase("LobbyWaiting", 0)
		end
	end
	local function reset(): ()
		local previous = participants
		participants, calls, called, deck, skipped = {}, {}, {}, {}, {}
		result = nil
		setPhase("LobbyWaiting", 0)
		for _, player in Players:GetPlayers() do if previous[player.UserId] then place(player) end end
		World.SetMCDialogue("Ready for another round? Join at the portal!")
		World.SetReady()
		considerCountdown()
	end
	local function finish(outcome: Types.Result): ()
		if phase ~= "CallingNumbers" then return end
		result = outcome
		setPhase("RoundComplete", Config.RESULT_DURATION_SECONDS)
		World.SetMCDialogue(if outcome.isDraw then "No full card this time!" else `{outcome.winnerName or "A player"} got Bingo!`)
		World.SetResult(if outcome.isDraw then "ROUND COMPLETE" else "BINGO!")
	end
	local function nextCall(): ()
		local number = table.remove(deck)
		if not number then finish({isDraw = true}); return end
		table.insert(calls, number); called[number] = true
		setPhase("CallingNumbers", Config.CALL_INTERVAL_SECONDS)
		local letter = ({"B", "I", "N", "G", "O"})[math.ceil(number / 15)]
		World.SetMCDialogue(`{letter} — {number}!`)
		World.SetCall(letter, number)
	end
	local function startMatch(): ()
		matchId += 1
		calls, called, skipped, participants = {}, {}, {}, {}
		deck = Rules.Shuffle(random, 1, 75)
		result = nil
		local intro = Config.REPEAT_INTRO_SECONDS
		for _, id in queue.TakeEligible(Config.MAXIMUM_PLAYERS_PER_MATCH) do
			local player = Players:GetPlayerByUserId(id)
			if player then
				local first = not seen[id]
				local seat = 1
				for _ in participants do seat += 1 end
				participants[id] = {card = Rules.GenerateCard(random), first = first, seat = seat}
				if first then intro = Config.INTRO_CUTSCENE_SECONDS end
				seen[id] = true
				place(player)
			end
		end
		if not next(participants) then reset(); return end
		setPhase("MatchIntro", intro)
		World.SetMCDialogue("Find my number. Tap your card. Fill it to win!")
		World.SetReady()
	end
	local function allSkipped(): boolean
		if not next(participants) then return false end
		for id in participants do if not skipped[id] then return false end end
		return true
	end
	transport = Transport.new({
		snapshot = function(player: Player) send(player) end,
		skip = function(player: Player, requested: number)
			if phase == "MatchIntro" and requested == matchId and participants[player.UserId] then
				skipped[player.UserId] = true
			end
		end,
		mark = function(player: Player, requested: number, index: number)
			local participant = participants[player.UserId]
			if requested ~= matchId or phase ~= "CallingNumbers" or not participant then
				send(player, "Wait for your match to start.", "info"); return
			end
			local rejection = Rules.ValidateMark(participant.card, called, index)
			if rejection then send(player, rejection, "error"); return end
			participant.card[index].isMarked = true
			if Rules.IsComplete(participant.card) then
				finish({isDraw = false, winnerUserId = player.UserId, winnerName = player.DisplayName})
				broadcast()
			else send(player, "Marked!", "success") end
		end,
	})
	local prompt = World.Start()
	table.insert(connections, prompt.Triggered:Connect(function(player: Player)
		local now = os.clock()
		if portalTimes[player] and now - portalTimes[player] < 0.75 then return end
		portalTimes[player] = now
		if not World.IsNearQueuePortal(player) or participants[player.UserId] then return end
		local leaving = queue.Contains(player.UserId)
		if leaving then queue.Leave(player.UserId) else queue.Join(player.UserId) end
		considerCountdown()
		broadcast()
		send(player, if leaving then "You left the queue." else "You're in the Bingo queue!", "info")
	end))
	local function added(player: Player): ()
		if characters[player] then return end
		characters[player] = player.CharacterAdded:Connect(function() place(player) end)
		place(player); send(player)
	end
	table.insert(connections, Players.PlayerAdded:Connect(added))
	table.insert(connections, Players.PlayerRemoving:Connect(function(player: Player)
		queue.Leave(player.UserId); participants[player.UserId] = nil
		seen[player.UserId] = nil; skipped[player.UserId] = nil; portalTimes[player] = nil
		if characters[player] then characters[player]:Disconnect(); characters[player] = nil end
		World.ForgetPlayer(player); transport.RemovePlayer(player)
		if not next(participants) and (phase == "MatchIntro" or phase == "CallingNumbers") then reset() end
		considerCountdown()
		for _, other in Players:GetPlayers() do if other ~= player then send(other) end end
	end))
	local lastBroadcast = 0
	table.insert(connections, RunService.Heartbeat:Connect(function()
		if not alive then return end
		local now = os.clock()
		local previous = phase
		local previousCallCount = #calls
		if phase == "MatchIntro" and (allSkipped() or now >= deadline) then nextCall()
		elseif deadline > 0 and now >= deadline then
			if phase == "LobbyCountdown" then
				considerCountdown()
				if phase == "LobbyCountdown" then startMatch() end
			elseif phase == "CallingNumbers" then nextCall()
			elseif phase == "RoundComplete" then reset() end
		end
		if phase ~= previous or #calls ~= previousCallCount or now - lastBroadcast >= 1 then lastBroadcast = now; broadcast() end
	end))
	readSnapshot = function(player: Player): Types.Snapshot return snapshot(player) end
	stop = function()
		alive = false
		for _, connection in connections do connection:Disconnect() end
		for _, connection in characters do connection:Disconnect() end
		transport.Destroy(); World.Destroy(); queue.Clear()
		readSnapshot = nil
	end
	for _, player in Players:GetPlayers() do added(player) end
	broadcast()
end

function Service.GetSnapshot(player: Player): Types.Snapshot?
	return if readSnapshot then readSnapshot(player) else nil
end
function Service.Destroy(): ()
	if stop then stop(); stop = nil end
end
return Service
