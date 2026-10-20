--!strict
local Players = game:GetService("Players")
local UI = script.Parent.Parent.Parent.Parent.UI
local Surface = require(UI.Surface)
local Theme = require(UI.Theme)
local Button = require(UI.ActionButton)
local State = require(script.Parent.Parent.PresentationState)
local TweenService = game:GetService("TweenService")
local View = {}
function View.new(parent: Instance, skip: () -> ())
	local root = Instance.new("Frame"); root.Name = "ResultsView"; root.BackgroundTransparency = 1
	root.Size = UDim2.fromScale(1, 1); root.Parent = parent
	local panel = Surface.Panel(root, "Outcome", Theme.Paper)
	local scale = Instance.new("UIScale"); scale.Parent = panel
	local reveal: Tween? = nil
	local lastMatchId: number? = nil
	local eyebrow = Surface.Text(panel, "Eyebrow", 14, Theme.Stage, Theme.Bold)
	local title = Surface.Text(panel, "Title", 30, Theme.Ink, Theme.Display)
	local detail = Surface.Text(panel, "Detail", 16)
	local action = Button.new(panel, "Skip scene", skip)
	local view = {Instance = root}
	function view.Layout(width: number, height: number, touch: boolean): ()
		local w = math.min(500, width - 32)
		local bottom = if touch and width < height then 110 else 20
		local h = math.min(232, height - bottom - 28)
		Surface.Rect(panel, (width - w) / 2, height - bottom - h, w, h)
		Surface.Rect(eyebrow, 16, 12, w - 32, 22)
		Surface.Rect(title, 16, 40, w - 32, 80)
		title.TextTruncate = Enum.TextTruncate.AtEnd
		Surface.Rect(detail, 16, 128, w - 32, 30)
		Surface.Rect(action.Instance, w - 128, h - 56, 112, 44)
	end
	function view.Render(model: State.Model): ()
		local snapshot = model.snapshot
		if not snapshot then return end
		if snapshot.matchId ~= lastMatchId then
			lastMatchId = snapshot.matchId
			if reveal then reveal:Cancel() end
			scale.Scale = 0.82
			reveal = TweenService:Create(scale, TweenInfo.new(0.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1})
			reveal:Play()
		end
		local result = snapshot.result
		local ownWin = result and result.winnerUserId == Players.LocalPlayer.UserId
		eyebrow.Text = if ownWin then "★ FULL CARD! ★" elseif result and result.isDraw then "ROUND COMPLETE" else "WE HAVE A WINNER"
		title.Text = if result and result.isDraw then "No full card this time"
			elseif ownWin then "BINGO! You won!"
			else (if result then result.winnerName or "A player" else "A player") .. " got Bingo!"
		title.TextColor3 = if ownWin then Theme.Mark else Theme.Ink
		detail.Text = model.detail
		action.Instance.Visible = model.sceneActive
	end
	function view.Destroy(): () if reveal then reveal:Cancel() end; action.Destroy(); root:Destroy() end
	return view
end
return View
