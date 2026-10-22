--!strict
local UI = script.Parent.Parent.Parent.Parent.UI
local Surface = require(UI.Surface)
local Theme = require(UI.Theme)
local Button = require(UI.ActionButton)
local StarterGui = game:GetService("StarterGui")
local State = require(script.Parent.Parent.PresentationState)
local View = {}
function View.new(parent: Instance, retry: () -> ())
	local design = StarterGui:FindFirstChild("BingoGuiDesign")
	local content = design and design:FindFirstChild("Content")
	local template = content and content:FindFirstChild("LobbyView")
	local templatePanel = template and template:FindFirstChild("LobbyStatus")
	local templateTicketEdge = templatePanel and templatePanel:FindFirstChild("TicketEdge")
	local templateBrand = templatePanel and templatePanel:FindFirstChild("Brand")
	local templateLive = templatePanel and templatePanel:FindFirstChild("Live")
	local templateTitle = templatePanel and templatePanel:FindFirstChild("Title")
	local templateInstructions = templatePanel and templatePanel:FindFirstChild("Instructions")
	local templateQueue = templatePanel and templatePanel:FindFirstChild("Queue")
	local templateAction = templatePanel and templatePanel:FindFirstChild("Action")
	local hasStudioTemplate = template ~= nil
		and template:IsA("Frame")
		and templatePanel ~= nil
		and templatePanel:IsA("Frame")
		and templateTicketEdge ~= nil
		and templateTicketEdge:IsA("Frame")
		and templateBrand ~= nil
		and templateBrand:IsA("TextLabel")
		and templateLive ~= nil
		and templateLive:IsA("TextLabel")
		and templateTitle ~= nil
		and templateTitle:IsA("TextLabel")
		and templateInstructions ~= nil
		and templateInstructions:IsA("TextLabel")
		and templateQueue ~= nil
		and templateQueue:IsA("TextLabel")
		and templateAction ~= nil
		and templateAction:IsA("TextButton")
	local root: Frame
	local panel: Frame
	local ticketEdge: Frame
	local brand: TextLabel
	local live: TextLabel
	local title: TextLabel
	local detail: TextLabel
	local count: TextLabel
	local actionButton: TextButton
	local actionController: any? = nil
	local actionConnection: RBXScriptConnection? = nil
	if hasStudioTemplate then
		root = (template :: Frame):Clone()
		root.Parent = parent
		panel = root:FindFirstChild("LobbyStatus") :: Frame
		ticketEdge = panel:FindFirstChild("TicketEdge") :: Frame
		brand = panel:FindFirstChild("Brand") :: TextLabel
		live = panel:FindFirstChild("Live") :: TextLabel
		title = panel:FindFirstChild("Title") :: TextLabel
		detail = panel:FindFirstChild("Instructions") :: TextLabel
		count = panel:FindFirstChild("Queue") :: TextLabel
		actionButton = panel:FindFirstChild("Action") :: TextButton
		actionConnection = actionButton.Activated:Connect(retry)
	else
		root = Instance.new("Frame")
		root.Name = "LobbyView"
		root.BackgroundTransparency = 1
		root.Size = UDim2.fromScale(1, 1)
		root.Parent = parent
		panel = Surface.Panel(root, "LobbyStatus", Theme.Midnight, 10)
		local border = Instance.new("UIStroke")
		border.Color = Theme.Spotlight
		border.Thickness = 2
		border.Parent = panel
		ticketEdge = Surface.Panel(panel, "TicketEdge", Theme.Spotlight, 0)
		brand = Surface.Text(panel, "Brand", 13, Theme.Spotlight, Theme.Bold)
		brand.Text = "BINGO NOIR  /  BACKSTAGE"
		live = Surface.Text(panel, "Live", 12, Theme.Spotlight, Theme.Bold)
		live.Text = "● LIVE"
		live.TextXAlignment = Enum.TextXAlignment.Right
		title = Surface.Text(panel, "Title", 27, Theme.Paper, Theme.Display)
		detail = Surface.Text(panel, "Instructions", 16, Theme.Paper)
		count = Surface.Text(panel, "Queue", 14, Theme.Spotlight, Theme.Bold)
		actionController = Button.new(panel, "Try again", retry)
		actionButton = actionController.Instance
		actionButton.Visible = false
	end
	local view = { Instance = root }
	function view.Layout(width: number, _height: number, _touch: boolean): ()
		local w = math.min(480, width - 32)
		Surface.Rect(panel, if width >= 760 then 24 else (width - w) / 2, 12, w, 166)
		Surface.Rect(ticketEdge, 0, 0, 6, 166)
		Surface.Rect(brand, 20, 12, w - 160, 20)
		Surface.Rect(live, w - 112, 12, 96, 20)
		Surface.Rect(title, 20, 40, w - 40, 36)
		Surface.Rect(detail, 20, 78, w - 40, 44)
		Surface.Rect(count, 20, 132, w - 152, 22)
		Surface.Rect(actionButton, w - 124, 108, 108, 44)
	end
	function view.Render(model: State.Model, retryVisible: boolean): ()
		title.Text = model.title
		detail.Text = model.detail
		count.Text = model.count
		actionButton.Visible = retryVisible
		if retryVisible then
			detail.Text = "Still connecting. You can try again."
			count.Text = "Connection delayed"
		end
	end
	function view.Destroy(): ()
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
