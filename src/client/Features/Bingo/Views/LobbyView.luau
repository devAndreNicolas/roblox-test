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
	local panel = Surface.Panel(root, "LobbyStatus", Theme.Paper)
	local brand = Surface.Text(panel, "Brand", 14, Theme.Stage, Theme.Display)
	brand.Text = "BINGO NOIR • BACKSTAGE"
	local title = Surface.Text(panel, "Title", 24, Theme.Ink, Theme.Display)
	local detail = Surface.Text(panel, "Instructions", 16)
	local count = Surface.Text(panel, "Queue", 14, Theme.Muted, Theme.Bold)
	local button = Button.new(panel, "Try again", retry)
	button.Instance.Visible = false
	local view = { Instance = root }
	function view.Layout(width: number, _height: number, _touch: boolean): ()
		local w = math.min(480, width - 32)
		Surface.Rect(panel, if width >= 760 then 24 else (width - w) / 2, 12, w, 156)
		Surface.Rect(brand, 16, 12, w - 32, 20)
		Surface.Rect(title, 16, 38, w - 32, 32)
		Surface.Rect(detail, 16, 76, w - 32, 42)
		Surface.Rect(count, 16, 124, w - 152, 20)
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
