--!strict
local UI = script.Parent.Parent.Parent.Parent.UI
local Surface = require(UI.Surface)
local Theme = require(UI.Theme)
local Types = require(game:GetService("ReplicatedStorage").Shared.Features.Bingo.BingoTypes)
local Catalog = require(game:GetService("ReplicatedStorage").Shared.Features.RewardsShop.RewardCatalog)
local TweenService = game:GetService("TweenService")
local Card = {}
function Card.new(parent: Instance, intent: (number) -> ())
	local root = Surface.Panel(parent, "BingoCard", Theme.Paper)
	local border = Instance.new("UIStroke")
	border.Color = Theme.Stage
	border.Thickness = 3
	border.Parent = root
	local artwork = Instance.new("ImageLabel")
	artwork.Name = "ThemeArtwork"
	artwork.BackgroundTransparency = 1
	artwork.Size = UDim2.fromScale(1, 1)
	artwork.Visible = false
	artwork.Parent = root
	local headerBand = Instance.new("Frame")
	headerBand.Name = "ThemeHeader"
	headerBand.BorderSizePixel = 0
	headerBand.Position = UDim2.fromOffset(4, 4)
	headerBand.Size = UDim2.new(1, -8, 0, 34)
	headerBand.BackgroundColor3 = Theme.Stage
	headerBand.Parent = root
	local bandCorner = Instance.new("UICorner")
	bandCorner.CornerRadius = UDim.new(0, 10)
	bandCorner.Parent = headerBand
	local headers = Instance.new("Frame")
	headers.Name = "Columns"
	headers.BackgroundTransparency = 1
	headers.Position = UDim2.fromOffset(12, 8)
	headers.Size = UDim2.new(1, -24, 0, 28)
	headers.Parent = root
	local headerLayout = Instance.new("UIGridLayout")
	headerLayout.CellSize = UDim2.new(0.2, -5, 1, 0)
	headerLayout.CellPadding = UDim2.fromOffset(6, 0)
	headerLayout.FillDirectionMaxCells = 5
	headerLayout.SortOrder = Enum.SortOrder.LayoutOrder
	headerLayout.Parent = headers
	local headerLabels: { TextLabel } = {}
	for index, letter in { "B", "I", "N", "G", "O" } do
		local label = Surface.Text(headers, letter, 18, Theme.White, Theme.Display)
		label.Text = letter
		label.TextXAlignment = Enum.TextXAlignment.Center
		label.LayoutOrder = index
		headerLabels[index] = label
	end
	local grid = Instance.new("Frame")
	grid.Name = "Cells"
	grid.BackgroundTransparency = 1
	grid.Position = UDim2.fromOffset(12, 40)
	grid.Size = UDim2.new(1, -24, 1, -52)
	grid.Parent = root
	local layout = Instance.new("UIGridLayout")
	layout.CellSize = UDim2.new(0.2, -5, 0.2, -5)
	layout.CellPadding = UDim2.fromOffset(6, 6)
	layout.FillDirectionMaxCells = 5
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = grid
	local buttons: { TextButton } = {}
	local stamps: { TextLabel } = {}
	local connections: { RBXScriptConnection } = {}
	local scales: { UIScale } = {}
	local markTweens: { [number]: Tween } = {}
	local glints: { TextLabel } = {}
	local glintTweens: { [number]: Tween } = {}
	local current: { Types.CardCell }? = nil
	local mode = "preview"
	local currentCalled: { [number]: boolean } = {}
	for index = 1, 25 do
		local button = Instance.new("TextButton")
		button.Name = `Cell{index}`
		button.LayoutOrder = index
		button.BorderSizePixel = 0
		button.Font = Theme.Bold
		button.TextSize = 20
		button.TextColor3 = Theme.Ink
		button.AutoButtonColor = false
		button.BackgroundColor3 = Theme.White
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 8)
		corner.Parent = button
		local scale = Instance.new("UIScale")
		scale.Parent = button
		scales[index] = scale
		local focus = Instance.new("UIStroke")
		focus.Color = Theme.Stage
		focus.Thickness = 2
		focus.Enabled = false
		focus.Parent = button
		local stamp = Surface.Text(button, "Stamp", 14, Theme.White, Theme.Bold)
		stamp.Text = "✓"
		stamp.TextXAlignment = Enum.TextXAlignment.Right
		stamp.Position = UDim2.new(1, -16, 0, 0)
		stamp.Size = UDim2.fromOffset(14, 16)
		stamp.Visible = false
		local glint = Surface.Text(button, "Glint", 23, Theme.Spotlight, Theme.Bold)
		glint.Text = "✦"
		glint.TextXAlignment = Enum.TextXAlignment.Center
		glint.Size = UDim2.fromOffset(28, 28)
		glint.Position = UDim2.new(0.5, -14, 0.5, -14)
		glint.TextTransparency = 1
		glint.ZIndex = 5
		glints[index] = glint
		button.Parent = grid
		buttons[index] = button
		stamps[index] = stamp
		table.insert(
			connections,
			button.Activated:Connect(function()
				local cell = current and current[index]
				if mode == "play" and cell and not cell.isMarked and currentCalled[cell.number] then
					intent(index)
				end
			end)
		)
		table.insert(
			connections,
			button.SelectionGained:Connect(function()
				focus.Enabled = true
			end)
		)
		table.insert(
			connections,
			button.SelectionLost:Connect(function()
				focus.Enabled = false
			end)
		)
	end
	local card = { Instance = root }
	local currentThemeId = "classic"
	function card.LayoutTheme(): ()
		local theme = Catalog.FindTheme(currentThemeId) or Catalog.FindTheme("classic")
		if not theme then
			return
		end
		local width = root.AbsoluteSize.X
		-- Hidden images may never load. Keep the asset visible while it loads,
		-- and keep the native frame until the image is ready.
		artwork.Visible = theme.image ~= ""
		local useArtwork = artwork.Visible and artwork.IsLoaded and width >= 150
		border.Enabled = not useArtwork
		headerBand.Visible = not useArtwork
		if useArtwork then
			local inset = math.max(15, math.floor(width * 0.1))
			local headerY = math.floor(width * 0.2)
			local gridY = headerY + (if width < 240 then 22 else 34)
			local bottom = math.floor(width * (if width < 240 then 0.14 else 0.22))
			headers.Position = UDim2.fromOffset(inset, headerY)
			headers.Size = UDim2.new(1, -inset * 2, 0, if width < 240 then 20 else 28)
			grid.Position = UDim2.fromOffset(inset, gridY)
			grid.Size = UDim2.new(1, -inset * 2, 1, -gridY - bottom)
		else
			headers.Position = UDim2.fromOffset(12, 8)
			headers.Size = UDim2.new(1, -24, 0, 28)
			grid.Position = UDim2.fromOffset(12, 40)
			grid.Size = UDim2.new(1, -24, 1, -52)
		end
		for _, label in headerLabels do
			label.TextSize = if width < 240 then 12 else 18
			label.TextColor3 = if useArtwork or theme.id == "on_air" then Theme.Ink else Theme.White
		end
	end
	function card.SetTheme(themeId: string): ()
		local theme = Catalog.FindTheme(themeId) or Catalog.FindTheme("classic")
		if not theme then
			return
		end
		currentThemeId = theme.id
		root.BackgroundColor3 = theme.paper
		border.Color = theme.accent
		border.Thickness = if theme.id == "classic" then 3 else 5
		headerBand.BackgroundColor3 = theme.accent
		artwork.Image = theme.image
		card.LayoutTheme()
	end
	card.SetTheme("classic")
	table.insert(connections, root:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		card.LayoutTheme()
	end))
	table.insert(
		connections,
		artwork:GetPropertyChangedSignal("IsLoaded"):Connect(function()
			card.LayoutTheme()
		end)
	)
	function card.Celebrate(index: number): ()
		local button = buttons[index]
		if not button then
			return
		end
		local oldMark = markTweens[index]
		if oldMark then
			oldMark:Cancel()
		end
		local oldGlint = glintTweens[index]
		if oldGlint then
			oldGlint:Cancel()
		end
		local scale = scales[index]
		scale.Scale = 1.14
		local markTween = TweenService:Create(
			scale,
			TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{ Scale = 1 }
		)
		markTweens[index] = markTween
		markTween:Play()
		local glint = glints[index]
		glint.Position = UDim2.new(0.5, -14, 0.5, -14)
		glint.TextTransparency = 0
		local glintTween = TweenService:Create(
			glint,
			TweenInfo.new(0.42, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ Position = UDim2.new(0.5, -14, 0, -12), TextTransparency = 1 }
		)
		glintTweens[index] = glintTween
		glintTween:Play()
	end
	function card.Render(
		values: { Types.CardCell }?,
		nextMode: string,
		pending: { [number]: number },
		called: { [number]: boolean }?
	): ()
		card.LayoutTheme()
		current, mode, currentCalled = values, nextMode, called or {}
		for index, button in buttons do
			local cell = values and values[index]
			local marked = cell ~= nil and cell.isMarked
			local free = cell ~= nil and cell.isFree
			local calledCell = mode ~= "play" or (cell ~= nil and currentCalled[cell.number] == true)
			button.Text = if free then "★" elseif cell then tostring(cell.number) else "·"
			button.TextSize = if root.AbsoluteSize.X < 240 then 16 else 22
			button.BackgroundColor3 = if free
				then Theme.Spotlight
				elseif marked then Theme.Mark
				elseif pending[index] then Theme.Spotlight
				elseif not calledCell then Theme.Disabled
				else Theme.White
			button.TextColor3 = if marked and not free
				then Theme.White
				elseif not calledCell and not free then Theme.Muted
				else Theme.Ink
			button.Active = mode == "play" and cell ~= nil and not marked and calledCell
			button.Selectable = button.Active
			stamps[index].Visible = marked and not free and root.AbsoluteSize.X >= 240
		end
	end
	function card.Destroy(): ()
		for _, tween in markTweens do
			tween:Cancel()
		end
		for _, tween in glintTweens do
			tween:Cancel()
		end
		for _, connection in connections do
			connection:Disconnect()
		end
		root:Destroy()
	end
	return card
end
return Card
