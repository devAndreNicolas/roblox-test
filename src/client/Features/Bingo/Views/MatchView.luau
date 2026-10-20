--!strict
local UI = script.Parent.Parent.Parent.Parent.UI
local Surface = require(UI.Surface)
local Theme = require(UI.Theme)
local Card = require(script.Parent.Parent.Components.BingoCard)
local Ball = require(script.Parent.Parent.Components.CallBall)
local Race = require(script.Parent.Parent.Components.BingoRace)
local Players = game:GetService("Players")
local State = require(script.Parent.Parent.PresentationState)
local View = {}
function View.new(parent: Instance, onMark: (number) -> ())
	local root = Instance.new("Frame"); root.Name = "MatchView"; root.BackgroundTransparency = 1
	root.Size = UDim2.fromScale(1, 1); root.Parent = parent
	local call = Surface.Panel(root, "Call", Theme.Ink)
	local ball = Ball.new(call)
	local caption = Surface.Text(call, "Caption", 14, Theme.Paper, Theme.Bold)
	caption.Text = "CALLED NUMBER"
	local timing = Surface.Text(call, "Timing", 16, Theme.White)
	local progressBack = Surface.Panel(call, "Track", Theme.Muted, 4)
	local progress = Surface.Panel(progressBack, "Progress", Theme.Spotlight, 4)
	local card = Card.new(root, onMark)
	local race = Race.new(root)
	local lastMatchId: number? = nil
	local history = Surface.Text(root, "History", 14, Theme.Paper, Theme.Bold)
	local reminder = Surface.Text(root, "Reminder", 16, Theme.Paper)
	local historyPanel = Surface.Panel(root, "HistorySurface", Theme.Ink, 12)
	history.Parent = historyPanel; reminder.Parent = historyPanel
	local view = {Instance = root}
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
			Surface.Rect(history, 12, 8, info - 24, 40)
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
			Surface.Rect(history, 10, 4, cw - 20, 20)
			Surface.Rect(reminder, 10, 25, cw - 20, 32)
			race.Layout(left, (if showHistory then 204 else 140) + cw, cw, 52, true, height)
		end
		local w, h = call.Size.X.Offset, call.Size.Y.Offset
		local diameter = h - 16
		Surface.Rect(ball.Instance, 8, 8, diameter, diameter)
		local x = diameter + 20
		Surface.Rect(caption, x, 10, w - x - 10, 20)
		Surface.Rect(timing, x, 32, w - x - 10, 26)
		Surface.Rect(progressBack, x, h - 14, w - x - 12, 4)
	end
	function view.Render(model: State.Model, pending: {[number]: number}): ()
		local snapshot = model.snapshot
		if not snapshot then return end
		if snapshot.matchId ~= lastMatchId then
			lastMatchId = snapshot.matchId
			ball.Render(nil)
			race.Collapse()
		end
		ball.Render(snapshot.lastCalledNumber)
		timing.Text = `Auto call in {model.seconds}s`
		progress.Size = UDim2.fromScale(math.clamp(snapshot.timeRemaining / math.max(0.1, snapshot.callIntervalSeconds), 0, 1), 1)
		local called: {[number]: boolean} = {}
		for _, number in snapshot.calledNumbers do called[number] = true end
		card.Render(snapshot.card, "play", pending, called)
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
	function view.CelebrateLead(): () race.CelebrateLead() end
	function view.Destroy(): () card.Destroy(); race.Destroy(); ball.Destroy(); root:Destroy() end
	return view
end
return View
