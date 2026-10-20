--!strict
local UI = script.Parent.Parent.Parent.Parent.UI
local Surface = require(UI.Surface)
local Theme = require(UI.Theme)
local Types = require(game:GetService("ReplicatedStorage").Shared.Features.Bingo.BingoTypes)
local TweenService = game:GetService("TweenService")
local Card = {}
function Card.new(parent: Instance, intent: (number) -> ())
	local root = Surface.Panel(parent, "BingoCard", Theme.Paper)
	local headers = Instance.new("Frame")
	headers.Name = "Columns"; headers.BackgroundTransparency = 1
	headers.Position = UDim2.fromOffset(12, 8); headers.Size = UDim2.new(1, -24, 0, 28); headers.Parent = root
	local headerLayout = Instance.new("UIGridLayout")
	headerLayout.CellSize = UDim2.new(0.2, -5, 1, 0); headerLayout.CellPadding = UDim2.fromOffset(6, 0)
	headerLayout.FillDirectionMaxCells = 5
	headerLayout.SortOrder = Enum.SortOrder.LayoutOrder; headerLayout.Parent = headers
	for index, letter in {"B", "I", "N", "G", "O"} do
		local label = Surface.Text(headers, letter, 18, Theme.Stage, Theme.Display)
		label.Text = letter; label.TextXAlignment = Enum.TextXAlignment.Center; label.LayoutOrder = index
	end
	local grid = Instance.new("Frame")
	grid.Name = "Cells"; grid.BackgroundTransparency = 1
	grid.Position = UDim2.fromOffset(12, 40); grid.Size = UDim2.new(1, -24, 1, -52); grid.Parent = root
	local layout = Instance.new("UIGridLayout")
	layout.CellSize = UDim2.new(0.2, -5, 0.2, -5); layout.CellPadding = UDim2.fromOffset(6, 6)
	layout.FillDirectionMaxCells = 5
	layout.SortOrder = Enum.SortOrder.LayoutOrder; layout.Parent = grid
	local buttons: {TextButton} = {}
	local stamps: {TextLabel} = {}
	local connections: {RBXScriptConnection} = {}
	local scales: {UIScale} = {}
	local markTweens: {[number]: Tween} = {}
	local lastMarked: {[number]: boolean} = {}
	local current: {Types.CardCell}? = nil
	local mode = "preview"
	local currentCalled: {[number]: boolean} = {}
	for index = 1, 25 do
		local button = Instance.new("TextButton")
		button.Name = `Cell{index}`; button.LayoutOrder = index; button.BorderSizePixel = 0
		button.Font = Theme.Bold; button.TextSize = 20; button.TextColor3 = Theme.Ink
		button.AutoButtonColor = false; button.BackgroundColor3 = Theme.White
		local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, 8); corner.Parent = button
		local scale = Instance.new("UIScale"); scale.Parent = button; scales[index] = scale
		local focus = Instance.new("UIStroke"); focus.Color = Theme.Stage; focus.Thickness = 2; focus.Enabled = false; focus.Parent = button
		local stamp = Surface.Text(button, "Stamp", 14, Theme.White, Theme.Bold)
		stamp.Text = "✓"; stamp.TextXAlignment = Enum.TextXAlignment.Right
		stamp.Position = UDim2.new(1, -16, 0, 0); stamp.Size = UDim2.fromOffset(14, 16); stamp.Visible = false
		button.Parent = grid
		buttons[index] = button; stamps[index] = stamp
		table.insert(connections, button.Activated:Connect(function()
			local cell = current and current[index]
			if mode == "play" and cell and not cell.isMarked and currentCalled[cell.number] then intent(index) end
		end))
		table.insert(connections, button.SelectionGained:Connect(function() focus.Enabled = true end))
		table.insert(connections, button.SelectionLost:Connect(function() focus.Enabled = false end))
	end
	local card = {Instance = root}
	function card.Render(values: {Types.CardCell}?, nextMode: string, pending: {[number]: number}, called: {[number]: boolean}?): ()
		current, mode, currentCalled = values, nextMode, called or {}
		for index, button in buttons do
			local cell = values and values[index]
			local marked = cell ~= nil and cell.isMarked
			local free = cell ~= nil and cell.isFree
			local calledCell = mode ~= "play" or (cell ~= nil and currentCalled[cell.number] == true)
			if marked and not free and not lastMarked[index] then
				local previous = markTweens[index]
				if previous then previous:Cancel() end
				local scale = scales[index]
				scale.Scale = 1.16
				local nextTween = TweenService:Create(scale, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1})
				markTweens[index] = nextTween
				nextTween:Play()
			end
			lastMarked[index] = marked
			button.Text = if free then "★" elseif cell then tostring(cell.number) else "·"
			button.TextSize = if root.AbsoluteSize.X < 240 then 16 else 22
			button.BackgroundColor3 = if free then Theme.Spotlight elseif marked then Theme.Mark elseif pending[index] then Theme.Spotlight elseif not calledCell then Theme.Disabled else Theme.White
			button.TextColor3 = if marked and not free then Theme.White elseif not calledCell and not free then Theme.Muted else Theme.Ink
			button.Active = mode == "play" and cell ~= nil and not marked and calledCell
			button.Selectable = button.Active
			stamps[index].Visible = marked and not free and root.AbsoluteSize.X >= 240
		end
	end
	function card.Destroy(): ()
		for _, tween in markTweens do tween:Cancel() end
		for _, connection in connections do connection:Disconnect() end
		root:Destroy()
	end
	return card
end
return Card
