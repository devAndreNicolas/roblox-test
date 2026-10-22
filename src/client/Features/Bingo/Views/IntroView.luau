--!strict
local UI = script.Parent.Parent.Parent.Parent.UI
local Surface = require(UI.Surface)
local Theme = require(UI.Theme)
local Button = require(UI.ActionButton)
local StarterGui = game:GetService("StarterGui")
local Card = require(script.Parent.Parent.Components.BingoCard)
local State = require(script.Parent.Parent.PresentationState)
local TweenService = game:GetService("TweenService")
local View = {}
function View.new(parent: Instance, skip: () -> ())
	local design = StarterGui:FindFirstChild("BingoGuiDesign")
	local content = design and design:FindFirstChild("Content")
	local template = content and content:FindFirstChild("IntroView")
	local templateCaption = template and template:FindFirstChild("Caption")
	local templateSpeaker = templateCaption and templateCaption:FindFirstChild("Speaker")
	local templateInstruction = templateCaption and templateCaption:FindFirstChild("Instruction")
	local templateAction = templateCaption and templateCaption:FindFirstChild("Action")
	local templateWaiting = templateCaption and templateCaption:FindFirstChild("Waiting")
	local templateCard = template and template:FindFirstChild("BingoCard")
	local hasStudioTemplate = template ~= nil
		and template:IsA("Frame")
		and templateCaption ~= nil
		and templateCaption:IsA("Frame")
		and templateSpeaker ~= nil
		and templateSpeaker:IsA("TextLabel")
		and templateInstruction ~= nil
		and templateInstruction:IsA("TextLabel")
		and templateAction ~= nil
		and templateAction:IsA("TextButton")
		and templateWaiting ~= nil
		and templateWaiting:IsA("TextLabel")
		and templateCard ~= nil
		and templateCard:IsA("Frame")
	local root: Frame
	local caption: Frame
	local speaker: TextLabel
	local instruction: TextLabel
	local actionButton: TextButton
	local waiting: TextLabel
	local actionController: any? = nil
	local actionConnection: RBXScriptConnection? = nil
	if hasStudioTemplate then
		root = (template :: Frame):Clone()
		local cardPlaceholder = root:FindFirstChild("BingoCard")
		if cardPlaceholder then
			cardPlaceholder:Destroy()
		end
		root.Parent = parent
		caption = root:FindFirstChild("Caption") :: Frame
		speaker = caption:FindFirstChild("Speaker") :: TextLabel
		instruction = caption:FindFirstChild("Instruction") :: TextLabel
		actionButton = caption:FindFirstChild("Action") :: TextButton
		waiting = caption:FindFirstChild("Waiting") :: TextLabel
		actionConnection = actionButton.Activated:Connect(skip)
	else
		root = Instance.new("Frame")
		root.Name = "IntroView"
		root.BackgroundTransparency = 1
		root.Size = UDim2.fromScale(1, 1)
		root.Parent = parent
		caption = Surface.Panel(root, "Caption", Theme.Midnight, 10)
		local captionStroke = Instance.new("UIStroke")
		captionStroke.Color = Theme.Spotlight
		captionStroke.Thickness = 2
		captionStroke.Parent = caption
		speaker = Surface.Text(caption, "Speaker", 14, Theme.Spotlight, Theme.Bold)
		instruction = Surface.Text(caption, "Instruction", 16, Theme.Paper)
		waiting = Surface.Text(caption, "Waiting", 14, Theme.Spotlight, Theme.Bold)
		actionController = Button.new(caption, "Skip scene", skip)
		actionButton = actionController.Instance
	end
	local card = Card.new(root, function(_index: number) end)
	local scale = Instance.new("UIScale")
	scale.Parent = card.Instance
	local reveal: Tween? = nil
	local view = { Instance = root }
	function view.Layout(width: number, height: number, touch: boolean): ()
		local portrait = width < height and width < 760
		local bottom = if touch and portrait then 110 else 16
		local captionW = math.min(740, width - 32)
		local captionH = if portrait then 124 else 92
		local y = height - bottom - captionH
		Surface.Rect(caption, (width - captionW) / 2, y, captionW, captionH)
		Surface.Rect(speaker, 14, 8, captionW - 28, 20)
		Surface.Rect(instruction, 14, 30, captionW - 144, captionH - 42)
		Surface.Rect(actionButton, captionW - 120, captionH - 58, 106, 44)
		Surface.Rect(waiting, captionW - 120, 30, 106, captionH - 40)
		local cw = if portrait
			then math.min(190, math.max(140, y - 172))
			else math.min(260, height - captionH - bottom - 72)
		local cx = if portrait then (width - cw) / 2 else math.min(width - cw - 32, width * 0.68)
		Surface.Rect(card.Instance, cx, math.max(16, y - cw - 44), cw, cw + 32)
	end
	function view.Enter(): ()
		if reveal then
			reveal:Cancel()
		end
		scale.Scale = 0.9
		local nextReveal = TweenService:Create(scale, TweenInfo.new(0.35, Enum.EasingStyle.Quad), { Scale = 1 })
		reveal = nextReveal
		nextReveal:Play()
	end
	function view.Exit(): ()
		if reveal then
			reveal:Cancel()
			reveal = nil
		end
		scale.Scale = 1
	end
	function view.Render(model: State.Model): ()
		local snapshot = model.snapshot
		if not snapshot then
			return
		end
		speaker.Text = if model.sceneActive then "BINGO MC · " .. model.title else "YOUR CARD IS READY"
		instruction.Text = model.detail
		actionButton.Visible = model.sceneActive
		waiting.Visible = not model.sceneActive
		waiting.Text = `Starting soon…\n{model.seconds}s`
		card.Render(snapshot.card, "preview", {})
	end
	function view.SetTheme(themeId: string): ()
		card.SetTheme(themeId)
	end
	function view.Destroy(): ()
		view.Exit()
		if actionConnection then
			actionConnection:Disconnect()
		end
		if actionController then
			actionController.Destroy()
		end
		card.Destroy()
		root:Destroy()
	end
	return view
end
return View
