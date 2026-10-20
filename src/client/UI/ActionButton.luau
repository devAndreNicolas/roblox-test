--!strict
local Theme = require(script.Parent.Theme)
local Button = {}
function Button.new(parent: Instance, text: string, action: () -> ())
	local button = Instance.new("TextButton")
	button.Name = "Action"; button.Text = text; button.TextSize = 16; button.Font = Theme.Bold
	button.TextColor3 = Theme.White; button.BackgroundColor3 = Theme.Stage
	button.BorderSizePixel = 0; button.AutoButtonColor = true; button.Selectable = true
	button.Size = UDim2.fromOffset(112, 44)
	local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, 12); corner.Parent = button
	local stroke = Instance.new("UIStroke"); stroke.Color = Theme.Spotlight; stroke.Thickness = 3; stroke.Enabled = false; stroke.Parent = button
	button.Parent = parent
	local connections = {
		button.Activated:Connect(action),
		button.SelectionGained:Connect(function() stroke.Enabled = true end),
		button.SelectionLost:Connect(function() stroke.Enabled = false end),
	}
	return {
		Instance = button,
		Destroy = function()
			for _, connection in connections do connection:Disconnect() end
			button:Destroy()
		end,
	}
end
return Button
