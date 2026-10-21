--!strict
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local Types = require(game:GetService("ReplicatedStorage").Shared.Features.Bingo.BingoTypes)
local UI = script.Parent.Parent.Parent.UI
local Surface = require(UI.Surface)
local Status = require(UI.StatusMessage)
local State = require(script.Parent.PresentationState)
local RemoteClient = require(script.Parent.BingoRemoteClient)
local Scene = require(script.Parent.ScenePresenter)
local ShowAudio = require(script.Parent.ShowAudio)
local Lobby = require(script.Parent.Views.LobbyView)
local Intro = require(script.Parent.Views.IntroView)
local Match = require(script.Parent.Views.MatchView)
local Results = require(script.Parent.Views.ResultsView)
local RewardsShop = require(script.Parent.Parent.RewardsShop.RewardShopController)
local Controller = {}
local cleanup: (() -> ())? = nil
local SEATED_JUMP_ACTION = "BingoSeatedJump"

function Controller.Start(): ()
	if cleanup then
		return
	end
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local gui = Instance.new("ScreenGui")
	gui.Name = "BingoGui"
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 10
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
	local root = Instance.new("Frame")
	root.Name = "Content"
	root.BackgroundTransparency = 1
	root.Size = UDim2.fromScale(1, 1)
	root.Parent = gui
	local feedbackLayer = Instance.new("Frame")
	feedbackLayer.Name = "FeedbackLayer"
	feedbackLayer.BackgroundTransparency = 1
	feedbackLayer.Size = UDim2.fromScale(1, 1)
	feedbackLayer.ZIndex = 20
	feedbackLayer.Parent = gui
	local status = Status.new(feedbackLayer)
	local audio = ShowAudio.new(gui)
	local jumpBlocked = false
	local function setJumpBlocked(value: boolean): ()
		if value == jumpBlocked then
			return
		end
		jumpBlocked = value
		if value then
			ContextActionService:BindActionAtPriority(SEATED_JUMP_ACTION, function()
				return Enum.ContextActionResult.Sink
			end, false, 3000, Enum.PlayerActions.CharacterJump)
		else
			ContextActionService:UnbindAction(SEATED_JUMP_ACTION)
		end
	end
	local current: Types.Snapshot? = nil
	local receivedAt = os.clock()
	local loadingSince = os.clock()
	local lastRetry = -math.huge
	local activeScene: string? = nil
	local completed: { [string]: boolean } = {}
	local pending: { [number]: number } = {}
	local previousView = ""
	local alive = true
	local scene = Scene.new()
	local render: () -> ()
	local remote
	local function skip(): ()
		if not current or not activeScene then
			return
		end
		completed[activeScene] = true
		if current.phase == "MatchIntro" then
			remote.SkipIntro(current.matchId)
		end
		scene.Stop(true)
		render()
	end
	local lobby = Lobby.new(root, function()
		if os.clock() - lastRetry < 0.6 then
			return
		end
		lastRetry = os.clock()
		loadingSince = os.clock()
		remote.RequestSnapshot()
	end)
	local intro = Intro.new(root, skip)
	local match = Match.new(root, function(index: number)
		local snapshot = current
		if not snapshot or not snapshot.isParticipant or snapshot.phase ~= "CallingNumbers" or pending[index] then
			return
		end
		local cell = snapshot.card and snapshot.card[index]
		if not cell or cell.isMarked then
			return
		end
		pending[index] = os.clock() + 2
		remote.MarkCell(snapshot.matchId, index)
		render()
	end)
	local results = Results.new(root, skip)
	local rewardMenu = RewardsShop.new(gui, function(themeId: string)
		intro.SetTheme(themeId)
		match.SetTheme(themeId)
	end)
	local roots = { Lobby = lobby.Instance, Intro = intro.Instance, Match = match.Instance, Results = results.Instance }
	render = function(): ()
		if not alive then
			return
		end
		local snapshot = if current then table.clone(current) else nil
		if snapshot then
			snapshot.timeRemaining = math.max(0, snapshot.timeRemaining - (os.clock() - receivedAt))
		end
		local model = State.Derive(snapshot, completed)
		rewardMenu.SetContext(snapshot)
		local key = model.sceneKey
		if activeScene ~= key then
			if activeScene then
				completed[activeScene] = true
			end
			scene.Stop(false)
			activeScene = key
			if key and model.sceneActive then
				local sceneKey = key
				scene.Play(model.sceneDuration, function()
					if not alive then
						return
					end
					completed[sceneKey] = true
					render()
				end)
			end
		end
		scene.SetParticipant(snapshot ~= nil and snapshot.isParticipant)
		local isParticipant = snapshot ~= nil and snapshot.isParticipant
		audio.SetParticipant(isParticipant)
		setJumpBlocked(isParticipant)
		for name, viewRoot in roots do
			viewRoot.Visible = name == model.view
		end
		if previousView ~= model.view then
			if previousView == "Intro" then
				intro.Exit()
			end
			if model.view == "Intro" then
				intro.Enter()
			end
			previousView = model.view
		end
		local size = root.AbsoluteSize
		local width, height = size.X, size.Y
		if width <= 0 or height <= 0 then
			return
		end
		local touch = UserInputService.TouchEnabled
		audio.Layout(width, height, touch, model.view)
		for index, expires in pending do
			if
				os.clock() >= expires
				or not snapshot
				or snapshot.phase ~= "CallingNumbers"
				or (snapshot.card and snapshot.card[index] and snapshot.card[index].isMarked)
			then
				pending[index] = nil
			end
		end
		if model.view == "Lobby" then
			lobby.Layout(width, height, touch)
			lobby.Render(model, snapshot == nil and os.clock() - loadingSince >= 5)
		elseif model.view == "Intro" then
			intro.Layout(width, height, touch)
			intro.Render(model)
		elseif model.view == "Match" then
			match.Layout(width, height, touch)
			match.Render(model, pending)
		elseif model.view == "Results" then
			results.Layout(width, height, touch)
			results.Render(model)
		end
		local horizontal = width > height or width >= 760
		local noticeWidth = math.min(if horizontal then width * 0.4 else width - 32, 400)
		local x = if horizontal and model.view == "Match" then 16 else (width - noticeWidth) / 2
		local y = if model.view == "Lobby"
			then 176
			elseif horizontal then height - 36
			elseif model.view == "Match" then height - (if touch then 106 else 78)
			else height - (if touch then 106 else 36)
		Surface.Rect(status.Instance, x, y, noticeWidth, 30)
		status.Tick()
	end
	remote = RemoteClient.new(function(snapshot: Types.Snapshot)
		if not alive then
			return
		end
		local previous = current
		local newSession = not previous or previous.sessionId ~= snapshot.sessionId
		if current and not newSession and snapshot.matchId < current.matchId then
			return
		end
		if previous and not newSession and snapshot.matchId == previous.matchId and previous.card and snapshot.card then
			for index, cell in previous.card do
				local nextCell = snapshot.card[index]
				if cell.isMarked and nextCell and not nextCell.isMarked then
					return
				end
			end
		end
		local sameMatch = previous ~= nil and not newSession and previous.matchId == snapshot.matchId
		local confirmedIndex: number? = nil
		local leadMilestone = false
		local oneAway = false
		local resultStarted = previous ~= nil
			and sameMatch
			and previous.phase ~= "RoundComplete"
			and snapshot.phase == "RoundComplete"
		if previous and sameMatch and previous.card and snapshot.card then
			for index, cell in snapshot.card do
				local oldCell = previous.card[index]
				if oldCell and not oldCell.isMarked and cell.isMarked and not cell.isFree then
					confirmedIndex = index
				end
			end
		end
		if
			previous
			and sameMatch
			and previous.standings
			and snapshot.standings
			and snapshot.phase == "CallingNumbers"
		then
			local oldLeader = previous.standings[1]
			local nextLeader = snapshot.standings[1]
			if oldLeader and nextLeader then
				leadMilestone = (oldLeader.remaining > 3 and nextLeader.remaining <= 3)
					or (oldLeader.remaining > 1 and nextLeader.remaining == 1)
				oneAway = nextLeader.remaining == 1
			end
		end
		if newSession then
			scene.Stop(false)
			activeScene = nil
			status.Clear()
		end
		if newSession or (current and snapshot.matchId ~= current.matchId) then
			table.clear(pending)
			table.clear(completed)
		end
		if snapshot.notice and snapshot.notice.kind == "error" then
			table.clear(pending)
		end
		current = snapshot
		receivedAt = os.clock()
		status.Update(snapshot.notice, snapshot.matchId)
		render()
		if confirmedIndex and snapshot.phase == "CallingNumbers" then
			match.CelebrateMark(confirmedIndex)
			if not leadMilestone then
				audio.PlayMark()
			end
		end
		if leadMilestone then
			match.CelebrateLead()
			audio.PlayNearWin(oneAway)
		end
		if resultStarted and snapshot.result and not snapshot.result.isDraw then
			audio.PlayWin()
		end
	end)
	gui.Parent = playerGui
	local accumulated = 0
	local heartbeat = RunService.Heartbeat:Connect(function(delta: number)
		accumulated += delta
		if accumulated < 0.1 then
			return
		end
		accumulated = 0
		if not current and os.clock() - loadingSince < 5 and os.clock() - lastRetry >= 1 then
			lastRetry = os.clock()
			remote.RequestSnapshot()
		end
		render()
	end)
	cleanup = function()
		alive = false
		heartbeat:Disconnect()
		remote.Destroy()
		scene.Destroy()
		setJumpBlocked(false)
		audio.Destroy()
		rewardMenu.Destroy()
		lobby.Destroy()
		intro.Destroy()
		match.Destroy()
		results.Destroy()
		status.Destroy()
		gui:Destroy()
	end
	render()
	remote.RequestSnapshot()
end
function Controller.Destroy(): ()
	if cleanup then
		cleanup()
		cleanup = nil
	end
end
return Controller
