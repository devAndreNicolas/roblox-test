--!strict
-- Shared surface and text styling, not feature state or generic instance construction.
local Theme = require(script.Parent.Theme)
local Surface = {}
function Surface.Panel(parent: Instance, name: string, color: Color3, radius: number?): Frame
	local frame = Instance.new("Frame")
	frame.Name = name; frame.BorderSizePixel = 0; frame.BackgroundColor3 = color
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 16); corner.Parent = frame
	frame.Parent = parent
	return frame
end
function Surface.Text(parent: Instance, name: string, size: number, color: Color3?, font: Enum.Font?): TextLabel
	local label = Instance.new("TextLabel")
	label.Name = name; label.BackgroundTransparency = 1; label.BorderSizePixel = 0
	label.Text = ""; label.TextSize = size; label.Font = font or Theme.Body
	label.TextColor3 = color or Theme.Ink; label.TextWrapped = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = parent
	return label
end
function Surface.Rect(object: GuiObject, x: number, y: number, width: number, height: number): ()
	object.Position = UDim2.fromOffset(math.floor(x), math.floor(y))
	object.Size = UDim2.fromOffset(math.floor(width), math.floor(height))
end
return Surface
