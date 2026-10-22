--!strict
local UI = script.Parent.Parent.Parent.Parent.UI
local Surface = require(UI.Surface)
local Theme = require(UI.Theme)
local Card = require(script.Parent.Parent.Components.BingoCard)
local Ball = require(script.Parent.Parent.Components.CallBall)
local Race = require(script.Parent.Parent.Components.BingoRace)
local Players = game:GetService("Players")
local StudioTemplate = require(UI.StudioTemplate)
local State = require(script.Parent.Parent.PresentationState)
local View = {}

local function getFrame(parent: Instance, name: string, color: Color3, radius: number?): Frame
	local child = parent:FindFirstChild(name)
	if child and child:IsA("Frame") then
		return child
	end
	return Surface.Panel(parent, name, color, radius)
end

local function getText(parent: Instance, name: string, size: number, color: Color3, font: Enum.Font?): TextLabel
	local child = parent:FindFirstChild(name)
	if child and child:IsA("TextLabel") then
		return child
	end
	return Surface.Text(parent, name, size, color, font)
end

function View.new(parent: Instance, onMark: (number) -> ())
	local templateRoot = StudioTemplate.Clone("Content.MatchView", parent, "Frame")
	local root: Frame
	if templateRoot and templateRoot:IsA("Frame") then
		root = templateRoot
	else
		root = Instance.new("Frame")
		root.Name = "MatchView"
		root.BackgroundTransparency = 1
		root.Size = UDim2.fromScale(1, 1)
		root.Parent = parent
	end
	local call = getFrame(root, "Call", Theme.Ink)
	if not call:FindFirstChildOfClass("UIStroke") then
		local callStroke = Instance.new("UIStroke")
		callStroke.Color = Theme.Spotlight
		callStroke.Thickness = 2
		callStroke.Transparency = 0.25
		callStroke.Parent = call
	end
	local ballTemplate = call:FindFirstChild("CallBall")
	local ball = Ball.new(call, if ballTemplate and ballTemplate:IsA("Frame") then ballTemplate else nil)
	local caption = getText(call, "Caption", 13, Theme.Spotlight, Theme.Bold)
	caption.Text = "● LIVE  /  CURRENT CALL"
	local timing = getText(call, "Timing", 16, Theme.White)
	local progressBack = getFrame(call, "Track", Theme.Muted, 4)
	local progress = getFrame(progressBack, "Progress", Theme.Spotlight, 4)
	local cardTemplate = root:FindFirstChild("BingoCard")
	local card = Card.new(root, onMark, if cardTemplate and cardTemplate:IsA("Frame") then cardTemplate else nil)
	local raceTemplate = root:FindFirstChild("BingoRace")
	local race = Race.new(root, if raceTemplate and raceTemplate:IsA("Frame") then raceTemplate else nil)
	local lastMatchId: number? = nil
	local historyPanel = getFrame(root, "HistorySurface", Theme.Ink, 12)
	local history = getText(historyPanel, "History", 14, Theme.Paper, Theme.Bold)
	local reminder = getText(historyPanel, "Reminder", 16, Theme.Paper)
	local historyAccent = getFrame(historyPanel, "GoldRule", Theme.Spotlight, 0)
	local subornPanel = getFrame(root, "SubornAnnouncement", Theme.Burgundy, 14)
	subornPanel.ZIndex = 12
	subornPanel.Visible = false
	local subornTitle = getText(subornPanel, "SubornTitle", 24, Theme.White, Theme.Display)
	subornTitle.ZIndex = 13
	subornTitle.TextXAlignment = Enum.TextXAlignment.Center
	local subornDetail = getText(subornPanel, "SubornDetail", 16, Theme.White, Theme.Bold)
	subornDetail.ZIndex = 13
	subornDetail.TextXAlignment = Enum.TextXAlignment.Center
	local view = { Instance = root }
	function view.Layout(width: number, height: number, touch: boolean): ()
		local horizontal = width > height or width >= 760
		if horizontal then
			historyPanel.Visible = height >= 460
			local right = if touch then 96 else 24
			local cw = math.max(270, math.min(400, height - 64, (width - right - 48) * 0.48))
			local left = 20
			local info = math.max(260, math.min(350, width - right - cw - 56))
			Surface.Rect(card.Instance, width - right - cw, math.max(12, (height - cw - 32) / 2), cw, cw + 32)
			Surface.Rect(call, left, 20, info, 108)
			Surface.Rect(historyPanel, left, math.max(140, height - 164), info, math.min(132, height - 196))
			race.Layout(left, 142, info, if height >= 460 then 150 else 118, false, height)
			Surface.Rect(historyAccent, 0, 0, info, 3)
			Surface.Rect(history, 12, 11, info - 24, 40)
			Surface.Rect(reminder, 12, 52, info - 24, 64)
		else
			local bottom = if touch then 114 else 80
			local showHistory = height >= 630
			historyPanel.Visible = showHistory
			local cw = math.max(220, math.min(380, width - 32, height - bottom - (if showHistory then 260 else 196)))
			local left = (width - cw) / 2
			Surface.Rect(call, left, 12, cw, 76)
			Surface.Rect(card.Instance, left, 100, cw, cw + 32)
			Surface.Rect(historyPanel, left, 140 + cw, cw, 60)
			Surface.Rect(historyAccent, 0, 0, cw, 3)
			Surface.Rect(history, 10, 6, cw - 20, 20)
			Surface.Rect(reminder, 10, 25, cw - 20, 32)
			race.Layout(left, (if showHistory then 204 else 140) + cw, cw, 52, true, height)
		end
		local w, h = call.Size.X.Offset, call.Size.Y.Offset
		local subornWidth = math.min(460, width - 32)
		Surface.Rect(subornPanel, (width - subornWidth) / 2, math.max(96, (height - 124) / 2), subornWidth, 124)
		Surface.Rect(subornTitle, 12, 12, subornWidth - 24, 36)
		Surface.Rect(subornDetail, 12, 52, subornWidth - 24, 60)
		local diameter = h - 16
		Surface.Rect(ball.Instance, 8, 8, diameter, diameter)
		local x = diameter + 20
		Surface.Rect(caption, x, 10, w - x - 10, 20)
		Surface.Rect(timing, x, 32, w - x - 10, 26)
		Surface.Rect(progressBack, x, h - 14, w - x - 12, 4)
	end
	function view.Render(model: State.Model, pending: { [number]: number }): ()
		local snapshot = model.snapshot
		if not snapshot then
			return
		end
		if snapshot.matchId ~= lastMatchId then
			lastMatchId = snapshot.matchId
			ball.Render(nil)
			race.Collapse()
		end
		local announcing = snapshot.phase == "SubornAnnouncement"
		subornPanel.Visible = announcing
		if announcing then
			local number = snapshot.subornNumber
			local letter = if number then ({ "B", "I", "N", "G", "O" })[math.ceil(number / 15)] else "?"
			subornTitle.Text = `O MC foi subornado! {letter}-{number or "?"}`
			subornDetail.Text =
				`{snapshot.subornBuyerName or "A player"} chose the next call. Everyone can mark it; nobody is marked automatically.`
		end
		ball.Render(if announcing then snapshot.subornNumber else snapshot.lastCalledNumber)
		timing.Text = if announcing then "Next call for everyone" else `Next call in {model.seconds}s`
		progress.Size =
			UDim2.fromScale(math.clamp(snapshot.timeRemaining / math.max(0.1, snapshot.callIntervalSeconds), 0, 1), 1)
		local called: { [number]: boolean } = {}
		for _, number in snapshot.calledNumbers do
			called[number] = true
		end
		card.Render(snapshot.card, if announcing then "preview" else "play", pending, called)
		race.Render(snapshot.standings, Players.LocalPlayer.UserId)
		local recent = {}
		for index = math.max(1, #snapshot.calledNumbers - 3), #snapshot.calledNumbers do
			table.insert(recent, Ball.Format(snapshot.calledNumbers[index]))
		end
		history.Text = "Recent: " .. table.concat(recent, "  ")
		reminder.Text = model.detail
	end
	function view.CelebrateMark(index: number): ()
		card.Celebrate(index)
		race.CelebrateOwn()
	end
	function view.CelebrateLead(): ()
		race.CelebrateLead()
	end
	function view.SetTheme(themeId: string): ()
		card.SetTheme(themeId)
	end
	function view.Destroy(): ()
		card.Destroy()
		race.Destroy()
		ball.Destroy()
		root:Destroy()
	end
	return view
end
return View
