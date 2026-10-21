--!strict
local UI = script.Parent.Parent.Parent.Parent.UI
local Surface = require(UI.Surface)
local Theme = require(UI.Theme)
local Button = require(UI.ActionButton)
local State = require(script.Parent.Parent.PresentationState)
local View = {}
function View.new(parent: Instance, retry: () -> ())
	local root = Instance.new("Frame")
	root.Name = "LobbyView"
	root.BackgroundTransparency = 1
	root.Size = UDim2.fromScale(1, 1)
	root.Parent = parent
	local panel = Surface.Panel(root, "LobbyStatus", Theme.Midnight, 10)
	local border = Instance.new("UIStroke")
	border.Color = Theme.Spotlight
	border.Thickness = 2
	border.Parent = panel
	local ticketEdge = Surface.Panel(panel, "TicketEdge", Theme.Spotlight, 0)
	local brand = Surface.Text(panel, "Brand", 13, Theme.Spotlight, Theme.Bold)
	brand.Text = "BINGO NOIR  /  BACKSTAGE"
	local live = Surface.Text(panel, "Live", 12, Theme.Spotlight, Theme.Bold)
	live.Text = "● AO VIVO"
	live.TextXAlignment = Enum.TextXAlignment.Right
	local title = Surface.Text(panel, "Title", 27, Theme.Paper, Theme.Display)
	local detail = Surface.Text(panel, "Instructions", 16, Theme.Paper)
	local count = Surface.Text(panel, "Queue", 14, Theme.Spotlight, Theme.Bold)
	local button = Button.new(panel, "Try again", retry)
	button.Instance.Visible = false
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
		Surface.Rect(button.Instance, w - 124, 108, 108, 44)
	end
	function view.Render(model: State.Model, retryVisible: boolean): ()
		title.Text = model.title
		detail.Text = model.detail
		count.Text = model.count
		button.Instance.Visible = retryVisible
		if retryVisible then
			detail.Text = "Still connecting. You can try again."
			count.Text = "Connection delayed"
		end
	end
	function view.Destroy(): ()
		button.Destroy()
		root:Destroy()
	end
	return view
end
return View
