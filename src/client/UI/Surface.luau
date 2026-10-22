--!strict
-- Shared surface and text styling, not feature state or generic instance construction.
local Theme = require(script.Parent.Theme)
local Surface = {}
type LayoutOverride = { Position: boolean, Size: boolean, TextSize: boolean }
local studioOverrides = setmetatable({}, { __mode = "k" }) :: { [GuiObject]: LayoutOverride }

function Surface.BindStudioOverrides(root: Instance): ()
	local function bind(object: Instance): ()
		if not object:IsA("GuiObject") then
			return
		end
		local position = object:GetAttribute("BaselinePosition")
		local size = object:GetAttribute("BaselineSize")
		local textSize = object:GetAttribute("BaselineTextSize")
		local textObject = object :: GuiObject
		local currentTextSize: number? = nil
		if object:IsA("TextLabel") then
			currentTextSize = object.TextSize
		elseif object:IsA("TextButton") then
			currentTextSize = object.TextSize
		end
		studioOverrides[textObject] = {
			Position = typeof(position) == "UDim2" and textObject.Position ~= position,
			Size = typeof(size) == "UDim2" and textObject.Size ~= size,
			TextSize = typeof(currentTextSize) == "number"
				and typeof(textSize) == "number"
				and currentTextSize ~= textSize,
		}
	end

	bind(root)
	for _, descendant in root:GetDescendants() do
		bind(descendant)
	end
end

function Surface.SetPosition(object: GuiObject, position: UDim2): ()
	local override = studioOverrides[object]
	if not override or not override.Position then
		object.Position = position
	end
end

function Surface.SetSize(object: GuiObject, size: UDim2): ()
	local override = studioOverrides[object]
	if not override or not override.Size then
		object.Size = size
	end
end

function Surface.SetTextSize(object: TextLabel | TextButton, size: number): ()
	local override = studioOverrides[object]
	if not override or not override.TextSize then
		object.TextSize = size
	end
end

function Surface.Panel(parent: Instance, name: string, color: Color3, radius: number?): Frame
	local frame = Instance.new("Frame")
	frame.Name = name
	frame.BorderSizePixel = 0
	frame.BackgroundColor3 = color
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 16)
	corner.Parent = frame
	frame.Parent = parent
	return frame
end
function Surface.Text(parent: Instance, name: string, size: number, color: Color3?, font: Enum.Font?): TextLabel
	local label = Instance.new("TextLabel")
	label.Name = name
	label.BackgroundTransparency = 1
	label.BorderSizePixel = 0
	label.Text = ""
	label.TextSize = size
	label.Font = font or Theme.Body
	label.TextColor3 = color or Theme.Ink
	label.TextWrapped = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = parent
	return label
end
function Surface.Rect(object: GuiObject, x: number, y: number, width: number, height: number): ()
	local override = studioOverrides[object]
	if not override or not override.Position then
		Surface.SetPosition(object, UDim2.fromOffset(math.floor(x), math.floor(y)))
	end
	if not override or not override.Size then
		Surface.SetSize(object, UDim2.fromOffset(math.floor(width), math.floor(height)))
	end
end
return Surface
