--!strict
local UI = script.Parent.Parent.Parent.Parent.UI
local Surface = require(UI.Surface)
local Theme = require(UI.Theme)
local Ball = {}
function Ball.Format(number: number?): string
	return if number then `{({"B", "I", "N", "G", "O"})[math.ceil(number / 15)]} · {number}` else "Ready?"
end
function Ball.new(parent: Instance)
	local root = Surface.Panel(parent, "CallBall", Theme.Spotlight, 999)
	local letter = Surface.Text(root, "Letter", 14, Theme.Ink, Theme.Bold)
	letter.TextXAlignment = Enum.TextXAlignment.Center
	letter.Position = UDim2.fromScale(0, 0.08); letter.Size = UDim2.fromScale(1, 0.25)
	local text = Surface.Text(root, "Number", 36, Theme.Ink, Theme.Display)
	text.TextXAlignment = Enum.TextXAlignment.Center
	text.Position = UDim2.fromScale(0, 0.3); text.Size = UDim2.fromScale(1, 0.62)
	return {
		Instance = root,
		Render = function(number: number?)
			letter.Text = if number then ({"B", "I", "N", "G", "O"})[math.ceil(number / 15)] else "MC"
			text.Text = if number then tostring(number) else "?"
			text.TextSize = if root.AbsoluteSize.Y < 80 then 28 else 36
		end,
		Destroy = function() root:Destroy() end,
	}
end
return Ball
