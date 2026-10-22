--!strict
local UI = script.Parent.Parent.Parent.Parent.UI
local Surface = require(UI.Surface)
local Theme = require(UI.Theme)
local StudioTemplate = require(UI.StudioTemplate)
local Types = require(game:GetService("ReplicatedStorage").Shared.Features.Bingo.BingoTypes)
local Catalog = require(game:GetService("ReplicatedStorage").Shared.Features.RewardsShop.RewardCatalog)
local TweenService = game:GetService("TweenService")
local Card = {}

function Card.VisualTheme(themeId: string): (Color3?, Color3?, string?)
	if themeId == "classic" then
		local card = StudioTemplate.Find("Content.MatchView.BingoCard")
		if card and card:IsA("Frame") then
			local header = card:FindFirstChild("ThemeHeader")
			local artwork = card:FindFirstChild("ThemeArtwork")
			return if header and header:IsA("Frame") then header.BackgroundColor3 else nil,
				card.BackgroundColor3,
				if artwork and artwork:IsA("ImageLabel") then artwork.Image else nil
		end
	end
	local preview = StudioTemplate.Find(`RewardsShop.ShopPanel.Catalog.{themeId}.Preview`)
	if preview and preview:IsA("Frame") then
		local paper = preview:FindFirstChild("Paper")
		local art = preview:FindFirstChild("ThemeArtwork")
		return preview.BackgroundColor3,
			if paper and paper:IsA("Frame") then paper.BackgroundColor3 else nil,
			if art and art:IsA("ImageLabel") then art.Image else nil
	end
	return nil, nil, nil
end

function Card.new(parent: Instance, intent: (number) -> (), templateRoot: Frame?)
	local root = templateRoot or Surface.Panel(parent, "BingoCard", Theme.Paper)
	local isStudioTemplate = templateRoot ~= nil
	local border: UIStroke
	local artwork: ImageLabel
	local headerBand: Frame
	local headers: Frame
	local grid: Frame
	local headerLayout: UIGridLayout
	if isStudioTemplate then
		border = root:FindFirstChildOfClass("UIStroke") :: UIStroke
		artwork = root:FindFirstChild("ThemeArtwork") :: ImageLabel
		headerBand = root:FindFirstChild("ThemeHeader") :: Frame
		headers = root:FindFirstChild("Columns") :: Frame
		grid = root:FindFirstChild("Cells") :: Frame
		headerLayout = headers:FindFirstChildOfClass("UIGridLayout") :: UIGridLayout
	else
		border = Instance.new("UIStroke")
		border.Color = Theme.Stage
		border.Thickness = 3
		border.Parent = root
		artwork = Instance.new("ImageLabel")
		artwork.Name = "ThemeArtwork"
		artwork.BackgroundTransparency = 1
		artwork.Size = UDim2.fromScale(1, 1)
		artwork.Visible = false
		artwork.Parent = root
		headerBand = Instance.new("Frame")
		headerBand.Name = "ThemeHeader"
		headerBand.BorderSizePixel = 0
		headerBand.Position = UDim2.fromOffset(4, 4)
		headerBand.Size = UDim2.new(1, -8, 0, 34)
		headerBand.BackgroundColor3 = Theme.Stage
		headerBand.Parent = root
		local bandCorner = Instance.new("UICorner")
		bandCorner.CornerRadius = UDim.new(0, 10)
		bandCorner.Parent = headerBand
		headers = Instance.new("Frame")
		headers.Name = "Columns"
		headers.BackgroundTransparency = 1
		headers.Position = UDim2.fromOffset(12, 8)
		headers.Size = UDim2.new(1, -24, 0, 28)
		headers.Parent = root
		headerLayout = Instance.new("UIGridLayout")
		headerLayout.CellSize = UDim2.new(0.2, -5, 1, 0)
		headerLayout.CellPadding = UDim2.fromOffset(6, 0)
		headerLayout.FillDirectionMaxCells = 5
		headerLayout.SortOrder = Enum.SortOrder.LayoutOrder
		headerLayout.Parent = headers
		grid = Instance.new("Frame")
		grid.Name = "Cells"
		grid.BackgroundTransparency = 1
		grid.Position = UDim2.fromOffset(12, 40)
		grid.Size = UDim2.new(1, -24, 1, -52)
		grid.Parent = root
	end
	local headerLabels: { TextLabel } = {}
	for index, letter in { "B", "I", "N", "G", "O" } do
		local label: TextLabel
		if isStudioTemplate then
			label = headers:FindFirstChild(letter) :: TextLabel
		else
			label = Surface.Text(headers, letter, 18, Theme.White, Theme.Display)
			label.Text = letter
			label.TextXAlignment = Enum.TextXAlignment.Center
			label.LayoutOrder = index
		end
		headerLabels[index] = label
	end
	local layout = grid:FindFirstChildOfClass("UIGridLayout") :: UIGridLayout?
	if not layout then
		layout = Instance.new("UIGridLayout")
		layout.CellSize = UDim2.new(0.2, -5, 0.2, -5)
		layout.CellPadding = UDim2.fromOffset(6, 6)
		layout.FillDirectionMaxCells = 5
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Parent = grid
	end
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
	local cellTemplate = StudioTemplate.Find("Components.CardCell")
	for index = 1, 25 do
		local existingButton = if isStudioTemplate then grid:FindFirstChild(`Cell{index}`) else nil
		local templateButton = if existingButton and existingButton:IsA("TextButton")
			then existingButton :: TextButton
			elseif cellTemplate and cellTemplate:IsA("TextButton") then cellTemplate:Clone()
			else nil
		local templateScale = templateButton and templateButton:FindFirstChildOfClass("UIScale")
		local templateFocus = templateButton and templateButton:FindFirstChildOfClass("UIStroke")
		local templateStamp = templateButton and templateButton:FindFirstChild("Stamp")
		local templateGlint = templateButton and templateButton:FindFirstChild("Glint")
		local validTemplate = templateButton ~= nil
			and templateScale ~= nil
			and templateFocus ~= nil
			and templateStamp ~= nil
			and templateStamp:IsA("TextLabel")
			and templateGlint ~= nil
			and templateGlint:IsA("TextLabel")
		if templateButton and not validTemplate then
			templateButton:Destroy()
		end
		local button = if validTemplate then templateButton :: TextButton else Instance.new("TextButton")
		button.Name = `Cell{index}`
		button.LayoutOrder = index
		button.AutoButtonColor = false
		local scale: UIScale
		local focus: UIStroke
		local stamp: TextLabel
		local glint: TextLabel
		if validTemplate then
			button:SetAttribute("StudioCellTemplate", true)
			scale = templateScale :: UIScale
			focus = templateFocus :: UIStroke
			stamp = templateStamp :: TextLabel
			glint = templateGlint :: TextLabel
		else
			button.BorderSizePixel = 0
			button.Font = Theme.Bold
			button.TextSize = 20
			button.TextColor3 = Theme.Ink
			button.BackgroundColor3 = Theme.White
			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, 8)
			corner.Parent = button
			scale = Instance.new("UIScale")
			scale.Parent = button
			focus = Instance.new("UIStroke")
			focus.Color = Theme.Stage
			focus.Thickness = 2
			focus.Parent = button
			stamp = Surface.Text(button, "Stamp", 14, Theme.White, Theme.Bold)
			stamp.Text = "✓"
			stamp.TextXAlignment = Enum.TextXAlignment.Right
			stamp.Position = UDim2.new(1, -16, 0, 0)
			stamp.Size = UDim2.fromOffset(14, 16)
			glint = Surface.Text(button, "Glint", 23, Theme.Spotlight, Theme.Bold)
			glint.Text = "✦"
			glint.TextXAlignment = Enum.TextXAlignment.Center
			glint.Size = UDim2.fromOffset(28, 28)
			glint.Position = UDim2.new(0.5, -14, 0.5, -14)
			glint.TextTransparency = 1
			glint.ZIndex = 5
		end
		scales[index] = scale
		focus.Enabled = false
		stamp.Visible = false
		glint.TextTransparency = 1
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
		artwork.Visible = artwork.Image ~= ""
		local useArtwork = artwork.Visible and artwork.IsLoaded and width >= 150
		border.Enabled = not useArtwork
		headerBand.Visible = not useArtwork
		if useArtwork then
			local inset = math.max(15, math.floor(width * 0.1))
			local headerY = math.floor(width * 0.2)
			local gridY = headerY + (if width < 240 then 22 else 34)
			local bottom = math.floor(width * (if width < 240 then 0.14 else 0.22))
			Surface.SetPosition(headers, UDim2.fromOffset(inset, headerY))
			Surface.SetSize(headers, UDim2.new(1, -inset * 2, 0, if width < 240 then 20 else 28))
			Surface.SetPosition(grid, UDim2.fromOffset(inset, gridY))
			Surface.SetSize(grid, UDim2.new(1, -inset * 2, 1, -gridY - bottom))
		else
			Surface.SetPosition(headers, UDim2.fromOffset(12, 8))
			Surface.SetSize(headers, UDim2.new(1, -24, 0, 28))
			Surface.SetPosition(grid, UDim2.fromOffset(12, 40))
			Surface.SetSize(grid, UDim2.new(1, -24, 1, -52))
		end
		for _, label in headerLabels do
			Surface.SetTextSize(label, if width < 240 then 12 else 18)
			label.TextColor3 = if useArtwork or theme.id == "on_air" then Theme.Ink else Theme.White
		end
	end
	function card.SetTheme(themeId: string): ()
		local theme = Catalog.FindTheme(themeId) or Catalog.FindTheme("classic")
		if not theme then
			return
		end
		currentThemeId = theme.id
		root:SetAttribute("CardThemeId", theme.id)
		local accent, paper, image = Card.VisualTheme(theme.id)
		root.BackgroundColor3 = paper or theme.paper
		border.Color = accent or theme.accent
		border.Thickness = if theme.id == "classic" then 3 else 5
		headerBand.BackgroundColor3 = accent or theme.accent
		artwork.Image = image or theme.image
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
			Surface.SetTextSize(button, if root.AbsoluteSize.X < 240 then 16 else 22)
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
