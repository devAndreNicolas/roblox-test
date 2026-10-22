--!strict
local Players = game:GetService("Players")
local UI = script.Parent.Parent.Parent.Parent.UI
local Surface = require(UI.Surface)
local Theme = require(UI.Theme)
local Button = require(UI.ActionButton)
local StarterGui = game:GetService("StarterGui")
local State = require(script.Parent.Parent.PresentationState)
local TweenService = game:GetService("TweenService")
local View = {}
function View.new(parent: Instance, skip: () -> ())
	local design = StarterGui:FindFirstChild("BingoGuiDesign")
	local content = design and design:FindFirstChild("Content")
	local template = content and content:FindFirstChild("ResultsView")
	local templatePanel = template and template:FindFirstChild("Outcome")
	local templateEyebrow = templatePanel and templatePanel:FindFirstChild("Eyebrow")
	local templateTitle = templatePanel and templatePanel:FindFirstChild("Title")
	local templateDetail = templatePanel and templatePanel:FindFirstChild("Detail")
	local templateAction = templatePanel and templatePanel:FindFirstChild("Action")
	local templateScale = templatePanel and templatePanel:FindFirstChildOfClass("UIScale")
	local hasStudioTemplate = template ~= nil
		and template:IsA("Frame")
		and templatePanel ~= nil
		and templatePanel:IsA("Frame")
		and templateEyebrow ~= nil
		and templateEyebrow:IsA("TextLabel")
		and templateTitle ~= nil
		and templateTitle:IsA("TextLabel")
		and templateDetail ~= nil
		and templateDetail:IsA("TextLabel")
		and templateAction ~= nil
		and templateAction:IsA("TextButton")
		and templateScale ~= nil
	local root: Frame
	local panel: Frame
	local scale: UIScale
	local eyebrow: TextLabel
	local title: TextLabel
	local detail: TextLabel
	local actionButton: TextButton
	local actionController: any? = nil
	local actionConnection: RBXScriptConnection? = nil
	if hasStudioTemplate then
		root = (template :: Frame):Clone()
		root.Parent = parent
		panel = root:FindFirstChild("Outcome") :: Frame
		scale = panel:FindFirstChildOfClass("UIScale") :: UIScale
		eyebrow = panel:FindFirstChild("Eyebrow") :: TextLabel
		title = panel:FindFirstChild("Title") :: TextLabel
		detail = panel:FindFirstChild("Detail") :: TextLabel
		actionButton = panel:FindFirstChild("Action") :: TextButton
		actionConnection = actionButton.Activated:Connect(skip)
	else
		root = Instance.new("Frame")
		root.Name = "ResultsView"
		root.BackgroundTransparency = 1
		root.Size = UDim2.fromScale(1, 1)
		root.Parent = parent
		panel = Surface.Panel(root, "Outcome", Theme.Midnight, 12)
		local border = Instance.new("UIStroke")
		border.Color = Theme.Spotlight
		border.Thickness = 3
		border.Parent = panel
		scale = Instance.new("UIScale")
		scale.Parent = panel
		eyebrow = Surface.Text(panel, "Eyebrow", 14, Theme.Spotlight, Theme.Bold)
		title = Surface.Text(panel, "Title", 30, Theme.Paper, Theme.Display)
		detail = Surface.Text(panel, "Detail", 16, Theme.Paper)
		actionController = Button.new(panel, "Skip scene", skip)
		actionButton = actionController.Instance
	end
	local reveal: Tween? = nil
	local lastMatchId: number? = nil
	local view = { Instance = root }
	function view.Layout(width: number, height: number, touch: boolean): ()
		local w = math.min(500, width - 32)
		local bottom = if touch and width < height then 110 else 20
		local h = math.min(232, height - bottom - 28)
		Surface.Rect(panel, (width - w) / 2, height - bottom - h, w, h)
		Surface.Rect(eyebrow, 16, 12, w - 32, 22)
		Surface.Rect(title, 16, 40, w - 32, 80)
		title.TextTruncate = Enum.TextTruncate.AtEnd
		Surface.Rect(detail, 16, 128, w - 32, 30)
		Surface.Rect(actionButton, w - 128, h - 56, 112, 44)
	end
	function view.Render(model: State.Model): ()
		local snapshot = model.snapshot
		if not snapshot then
			return
		end
		if snapshot.matchId ~= lastMatchId then
			lastMatchId = snapshot.matchId
			if reveal then
				reveal:Cancel()
			end
			scale.Scale = 0.82
			reveal = TweenService:Create(
				scale,
				TweenInfo.new(0.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
				{ Scale = 1 }
			)
			reveal:Play()
		end
		local result = snapshot.result
		local ownWin = result and result.winnerUserId == Players.LocalPlayer.UserId
		eyebrow.Text = if ownWin
			then "★ FULL CARD! ★"
			elseif result and result.isDraw then "ROUND COMPLETE"
			else "WE HAVE A WINNER"
		title.Text = if result and result.isDraw
			then "No full card this time"
			elseif ownWin then "BINGO! You won!"
			else (if result then result.winnerName or "A player" else "A player") .. " got Bingo!"
		title.TextColor3 = if ownWin then Theme.Spotlight else Theme.Paper
		detail.Text = model.detail
		actionButton.Visible = model.sceneActive
	end
	function view.Destroy(): ()
		if reveal then
			reveal:Cancel()
		end
		if actionConnection then
			actionConnection:Disconnect()
		end
		if actionController then
			actionController.Destroy()
		end
		root:Destroy()
	end
	return view
end
return View
