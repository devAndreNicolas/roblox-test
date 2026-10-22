--!strict
local UI = script.Parent.Parent.Parent.Parent.UI
local Surface = require(UI.Surface)
local Theme = require(UI.Theme)
local TweenService = game:GetService("TweenService")
local Ball = {}
function Ball.Format(number: number?): string
	return if number then `{({ "B", "I", "N", "G", "O" })[math.ceil(number / 15)]} · {number}` else "Ready?"
end
function Ball.new(parent: Instance, templateRoot: Frame?)
	local root = templateRoot or Surface.Panel(parent, "CallBall", Theme.Spotlight, 999)
	local scale = root:FindFirstChildOfClass("UIScale") :: UIScale?
	if not scale then
		scale = Instance.new("UIScale")
		scale.Parent = root
	end
	local lastNumber: number? = nil
	local pulse: Tween? = nil
	local letterChild = root:FindFirstChild("Letter")
	local letter = if letterChild and letterChild:IsA("TextLabel")
		then letterChild
		else Surface.Text(root, "Letter", 14, Theme.Ink, Theme.Bold)
	local numberChild = root:FindFirstChild("Number")
	local text = if numberChild and numberChild:IsA("TextLabel")
		then numberChild
		else Surface.Text(root, "Number", 36, Theme.Ink, Theme.Display)
	if not templateRoot then
		letter.TextXAlignment = Enum.TextXAlignment.Center
		letter.Position = UDim2.fromScale(0, 0.08)
		letter.Size = UDim2.fromScale(1, 0.25)
		text.TextXAlignment = Enum.TextXAlignment.Center
		text.Position = UDim2.fromScale(0, 0.3)
		text.Size = UDim2.fromScale(1, 0.62)
	end
	return {
		Instance = root,
		Render = function(number: number?)
			if number and number ~= lastNumber then
				if pulse then
					pulse:Cancel()
				end
				scale.Scale = 1.2
				pulse = TweenService:Create(
					scale,
					TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
					{ Scale = 1 }
				)
				pulse:Play()
			end
			lastNumber = number
			letter.Text = if number then ({ "B", "I", "N", "G", "O" })[math.ceil(number / 15)] else "MC"
			text.Text = if number then tostring(number) else "?"
			Surface.SetTextSize(text, if root.AbsoluteSize.Y < 80 then 28 else 36)
		end,
		Destroy = function()
			if pulse then
				pulse:Cancel()
			end
			root:Destroy()
		end,
	}
end
return Ball
