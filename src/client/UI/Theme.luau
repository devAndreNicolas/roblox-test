--!strict
local design = game:GetService("StarterGui"):FindFirstChild("BingoGuiDesign")
local visualStates = design and design:FindFirstChild("VisualStates")

local function color(name: string, fallback: Color3): Color3
	local value = visualStates and visualStates:FindFirstChild(name)
	return if value and value:IsA("Color3Value") then value.Value else fallback
end

return table.freeze({
	Stage = color("Stage", Color3.fromRGB(35, 59, 104)),
	Midnight = color("Midnight", Color3.fromRGB(16, 26, 51)),
	Paper = color("Paper", Color3.fromRGB(255, 244, 216)),
	Ink = color("Ink", Color3.fromRGB(23, 32, 51)),
	Mark = color("Mark", Color3.fromRGB(23, 119, 91)),
	Burgundy = color("Burgundy", Color3.fromRGB(125, 48, 72)),
	Spotlight = color("Spotlight", Color3.fromRGB(242, 184, 75)),
	Alert = color("Alert", Color3.fromRGB(214, 72, 92)),
	White = color("White", Color3.new(1, 1, 1)),
	Muted = color("Muted", Color3.fromRGB(86, 101, 122)),
	Disabled = color("Disabled", Color3.fromRGB(230, 225, 211)),
	Body = Enum.Font.Gotham,
	Bold = Enum.Font.GothamBold,
	Display = Enum.Font.Oswald,
})
