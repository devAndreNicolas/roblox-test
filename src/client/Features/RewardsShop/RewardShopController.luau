--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Catalog = require(ReplicatedStorage.Shared.Features.RewardsShop.RewardCatalog)
local Types = require(ReplicatedStorage.Shared.Features.Bingo.BingoTypes)
local BingoCard = require(script.Parent.Parent.Bingo.Components.BingoCard)
local PlatformAdapter = require(script.Parent.RewardShopPlatformAdapter)
local UI = script.Parent.Parent.Parent.UI
local StudioTemplate = require(UI.StudioTemplate)
local Surface = require(UI.Surface)
local Theme = require(UI.Theme)
local ActionButton = require(UI.ActionButton)

local Controller = {}
local SOFT_GOLD = Color3.fromRGB(255, 224, 150)
local DEEP_BLUE = Color3.fromRGB(27, 43, 78)
local PREVIEW_NUMBERS =
	{ 7, 18, 33, 47, 62, 11, 24, 38, 52, 67, 4, 27, 0, 49, 70, 13, 21, 42, 58, 73, 2, 29, 44, 55, 65 }

local function panel(parent: Instance, name: string, color: Color3, radius: number, z: number): Frame
	local existing = parent:FindFirstChild(name)
	if existing and existing:IsA("Frame") then
		return existing
	end
	local frame = Surface.Panel(parent, name, color, radius)
	frame.ZIndex = z
	return frame
end

local function label(
	parent: Instance,
	name: string,
	value: string,
	size: number,
	color: Color3,
	font: Enum.Font,
	z: number
): TextLabel
	local existing = parent:FindFirstChild(name)
	if existing and existing:IsA("TextLabel") then
		return existing
	end
	local object = Surface.Text(parent, name, size, color, font)
	object.Text = value
	object.ZIndex = z
	object.TextYAlignment = Enum.TextYAlignment.Center
	return object
end

local function outline(object: GuiObject, color: Color3, thickness: number): ()
	if object:FindFirstChildOfClass("UIStroke") then
		return
	end
	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Thickness = thickness
	stroke.Parent = object
end

function Controller.new(gui: ScreenGui, onTheme: (string) -> ())
	local root = Instance.new("Frame")
	root.Name = "RewardsShop"
	root.BackgroundTransparency = 1
	root.Size = UDim2.fromScale(1, 1)
	root.ZIndex = 30
	root.Parent = gui

	local connections: { RBXScriptConnection } = {}
	local buttons: { any } = {}
	local reward: any = nil
	local bingo: Types.Snapshot? = nil
	local selectedTab = "Fichas"
	local menuOpen = false
	local message: (string) -> ()
	local lastRequest = -math.huge
	local lastSize = Vector2.zero
	local alive = true
	local render: () -> ()
	local layout: (number, number) -> ()
	local platform = PlatformAdapter.new(function(payload: any)
		reward = payload
		if typeof(payload.message) == "string" and payload.message ~= "" then message(payload.message) end
		if payload.ready and typeof(payload.equippedTheme) == "string" then onTheme(payload.equippedTheme) end
		render()
	end, function() render() end)
	local prices = platform.Prices
	local templateShop = StudioTemplate.Find("RewardsShop.ShopPanel")
	local studioV2 = templateShop ~= nil and templateShop:IsA("Frame")
		and templateShop:FindFirstChild("Spec007Marker") ~= nil
	if studioV2 then
		local required = {
			Header = "Frame", ["Header.Title"] = "TextLabel", ["Header.CloseShop"] = "TextButton",
			Rail = "Frame", ["Rail.Balance"] = "TextLabel", ["Rail.Daily"] = "TextLabel",
			Categories = "Frame", ["Categories.Fichas"] = "TextButton",
			["Categories.Cartelas"] = "TextButton", ["Categories.Poderes"] = "TextButton",
			["Categories.Convites"] = "TextButton", Catalog = "ScrollingFrame",
			Notice = "Frame", ["Notice.Text"] = "TextLabel",
			["Catalog.theme_showcase.BingoCard"] = "Frame",
		}
		for path, className in required do
			local item = StudioTemplate.Find(`RewardsShop.ShopPanel.{path}`)
			if not item or not item:IsA(className) then studioV2 = false end
		end
	end
	if studioV2 then
		local catalog = (templateShop :: Frame):FindFirstChild("Catalog") :: Instance
		for _, pack in Catalog.FICHA_PACKS do
			if not catalog:FindFirstChild(pack.id) then studioV2 = false end
		end
		for _, theme in Catalog.THEMES do
			if theme.id ~= "classic" and not catalog:FindFirstChild(theme.id) then studioV2 = false end
		end
		if not catalog:FindFirstChild("theme_showcase") or not catalog:FindFirstChild("suborn")
			or not catalog:FindFirstChild("invite") or not catalog:FindFirstChild("earn") then
			studioV2 = false
		end
	end
	local function fire(verb: string, itemId: string?): ()
		platform.Fire(verb, itemId)
	end

	local function button(
		parent: Instance,
		name: string,
		value: string,
		action: () -> (),
		color: Color3,
		z: number
	): TextButton
		local existing = parent:FindFirstChild(name)
		if existing and existing:IsA("TextButton") then
			if not studioV2 then existing.Text = value end
			table.insert(connections, existing.Activated:Connect(action))
			return existing
		end
		local component = ActionButton.new(parent, value, action)
		table.insert(buttons, component)
		local object = component.Instance
		object.Name = name
		object.ZIndex = z
		object.BackgroundColor3 = color
		object.TextColor3 = if color == Theme.Spotlight or color == Theme.Paper then Theme.Ink else Theme.White
		object.TextSize = 15
		return object
	end

	local function image(parent: Instance, name: string, asset: string, z: number): ImageLabel
		local existing = parent:FindFirstChild(name)
		if existing and existing:IsA("ImageLabel") then
			return existing
		end
		local object = Instance.new("ImageLabel")
		object.Name = name
		object.Image = asset
		object.BackgroundTransparency = 1
		object.ScaleType = Enum.ScaleType.Fit
		object.ZIndex = z
		object.Parent = parent
		return object
	end

	local hud: Frame
	local hudBalance: TextLabel
	local hudDaily: TextLabel
	local hudOpen: TextButton
	local designHud = StudioTemplate.Find("RewardsShop.RewardsHud")
	local designBalance = designHud and designHud:FindFirstChild("Fichas")
	local designDaily = designHud and designHud:FindFirstChild("NextReward")
	local designOpen = designHud and designHud:FindFirstChild("OpenShop")
	local hasStudioHud = designHud ~= nil
		and designHud:IsA("Frame")
		and designBalance ~= nil
		and designBalance:IsA("TextLabel")
		and designDaily ~= nil
		and designDaily:IsA("TextLabel")
		and designOpen ~= nil
		and designOpen:IsA("TextButton")
	local clonedHud = if hasStudioHud then StudioTemplate.Clone("RewardsShop.RewardsHud", root, "Frame") else nil
	if clonedHud and clonedHud:IsA("Frame") then
		hud = clonedHud
		hudBalance = hud:FindFirstChild("Fichas") :: TextLabel
		hudDaily = hud:FindFirstChild("NextReward") :: TextLabel
		hudOpen = hud:FindFirstChild("OpenShop") :: TextButton
		table.insert(connections, hudOpen.Activated:Connect(function()
			menuOpen = true
			render()
		end))
	else
		hud = panel(root, "RewardsHud", DEEP_BLUE, 14, 31)
		outline(hud, Theme.Spotlight, 2)
		hudBalance = label(hud, "Fichas", "0 TICKETS", 18, Theme.Paper, Theme.Display, 32)
		hudDaily = label(hud, "NextReward", "NEXT MILESTONE", 11, SOFT_GOLD, Theme.Body, 32)
		hudOpen = button(hud, "OpenShop", "OPEN SHOP", function()
			menuOpen = true
			render()
		end, Theme.Spotlight, 32)
	end
	local ticketBalance = if studioV2 then StudioTemplate.Clone("RewardsShop.TicketBalance", root, "Frame") :: Frame? else nil
	local milestoneProgress = if studioV2 then StudioTemplate.Clone("RewardsShop.MilestoneProgress", root, "Frame") :: Frame? else nil
	local openShopButton = if studioV2 then StudioTemplate.Clone("RewardsShop.OpenShopButton", root, "TextButton") :: TextButton? else nil
	local separatedHud = studioV2
		and ticketBalance ~= nil and ticketBalance:FindFirstChild("Fichas") ~= nil
		and milestoneProgress ~= nil and milestoneProgress:FindFirstChild("NextReward") ~= nil
		and openShopButton ~= nil
	if separatedHud then
		table.insert(connections, (openShopButton :: TextButton).Activated:Connect(function()
			menuOpen = true
			render()
		end))
	elseif studioV2 then
		if ticketBalance then ticketBalance:Destroy() end
		if milestoneProgress then milestoneProgress:Destroy() end
		if openShopButton then openShopButton:Destroy() end
		warn("[RewardShop] Spec 007 HUD template incomplete; using legacy HUD")
	end

	local function activateSuborn(): ()
		if
			reward
			and reward.ready
			and bingo
			and bingo.phase == "CallingNumbers"
			and reward.suborns > 0
			and not bingo.hasUsedSuborn
			and bingo.subornsUsed < 2
		then
			fire("Activate")
		end
	end
	local designPower = StudioTemplate.Find("RewardsShop.UseSuborn")
	local power: TextButton
	local clonedPower = if designPower and designPower:IsA("TextButton")
		then StudioTemplate.Clone("RewardsShop.UseSuborn", root, "TextButton")
		else nil
	if clonedPower and clonedPower:IsA("TextButton") then
		power = clonedPower
		table.insert(connections, power.Activated:Connect(activateSuborn))
	else
		power = button(root, "UseSuborn", "BRIBE THE MC", activateSuborn, Theme.Burgundy, 32)
	end

	local shade = StudioTemplate.Clone("RewardsShop.ShopShade", root, "TextButton") :: TextButton?
	if not shade then
		shade = Instance.new("TextButton")
		shade.Name = "ShopShade"
		shade.Text = ""
		shade.BackgroundColor3 = Theme.Midnight
		shade.BackgroundTransparency = 0.16
		shade.BorderSizePixel = 0
		shade.Size = UDim2.fromScale(1, 1)
		shade.ZIndex = 40
		shade.Visible = false
		shade.Parent = root
	end

	local shop = panel(root, "ShopPanel", Theme.Midnight, 18, 41)
	outline(shop, Theme.Spotlight, 2)
	if shop.Parent == root and shop:GetAttribute("StudioTemplate") == nil then
		local templateShop = StudioTemplate.Find("RewardsShop.ShopPanel")
		if templateShop and templateShop:IsA("Frame")
			and (studioV2 or templateShop:FindFirstChild("Spec007Marker") == nil) then
			shop:Destroy()
			shop = StudioTemplate.Clone("RewardsShop.ShopPanel", root, "Frame") :: Frame
			shop:SetAttribute("StudioTemplate", true)
		end
	end
	shop.ClipsDescendants = true
	shop.Visible = false
	local header = panel(shop, "Header", Theme.Stage, 0, 42)
	local accent = panel(header, "GoldRule", Theme.Spotlight, 0, 43)
	local masthead = label(header, "Masthead", "BINGO NOIR  /  SHOP", 14, SOFT_GOLD, Theme.Display, 44)
	local title = label(header, "Title", "THE STAGE SHOP", 29, Theme.Paper, Theme.Display, 44)
	local close = button(header, "CloseShop", "CLOSE  ×", function()
		menuOpen = false
		render()
	end, DEEP_BLUE, 44)

	local rail = panel(shop, "Rail", Theme.Paper, 12, 42)
	local balanceKicker = label(rail, "BalanceKicker", "YOUR BALANCE", 13, Theme.Burgundy, Theme.Bold, 43)
	local balance = label(rail, "Balance", "0", 44, Theme.Ink, Theme.Display, 43)
	local balanceUnit = label(rail, "BalanceUnit", "TICKETS", 16, Theme.Stage, Theme.Display, 43)
	local dailyKicker = label(rail, "DailyKicker", "NEXT MILESTONE", 13, Theme.Burgundy, Theme.Bold, 43)
	local daily = label(rail, "Daily", "Play a match today", 17, Theme.Ink, Theme.Bold, 43)
	local dailyNote = label(rail, "DailyNote", "7 milestones · keep your progress", 12, Theme.Muted, Theme.Body, 43)
	local dots: { Frame } = {}
	for index = 1, 7 do
		local dot = panel(rail, `DailyDot{index}`, Theme.Disabled, 4, 43)
		dots[index] = dot
	end
	local demoNote = label(rail, "DemoNote", "", 11, Theme.Muted, Theme.Body, 43)

	local scroll: ScrollingFrame
	local templateScroll = shop:FindFirstChild("Catalog")
	if templateScroll and templateScroll:IsA("ScrollingFrame") then
		scroll = templateScroll
	else
		scroll = Instance.new("ScrollingFrame")
		scroll.Name = "Catalog"
		scroll.BackgroundTransparency = 1
		scroll.BorderSizePixel = 0
		scroll.ScrollBarThickness = 5
		scroll.ScrollBarImageColor3 = Theme.Spotlight
		scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
		scroll.CanvasSize = UDim2.fromOffset(0, 0)
		scroll.ZIndex = 43
		scroll.Parent = shop
	end
	local existingNav = shop:FindFirstChild("Categories")
	local nav: Frame
	if existingNav and existingNav:IsA("Frame") then
		nav = existingNav
	else
		nav = Instance.new("Frame")
		nav.Name = "Categories"
		nav.BackgroundTransparency = 1
		nav.ZIndex = 43
		nav.Parent = shop
	end
	local tabs: { [string]: TextButton } = {}
	local tabLabels = { Fichas = "TICKETS", Cartelas = "CARDS", Poderes = "BOOSTS", Convites = "INVITE" }
	for _, tab in { "Fichas", "Cartelas", "Poderes", "Convites" } do
		tabs[tab] = button(nav, tab, tabLabels[tab], function()
			selectedTab = tab
			scroll.CanvasPosition = Vector2.zero
			render()
		end, Theme.Stage, 44)
	end

	local sectionTitle = label(shop, "SectionTitle", "TICKETS", 30, Theme.Paper, Theme.Display, 43)
	local sectionCopy = label(shop, "SectionCopy", "Earn them by playing or pick a pack.", 14, SOFT_GOLD, Theme.Body, 43)
	local commerceNote = label(
		shop,
		"CommerceNote",
		"Estimated prices; Robux purchases are not available yet.",
		12,
		Theme.Paper,
		Theme.Body,
		43
	)
	local list = scroll:FindFirstChildOfClass("UIListLayout")
	if not list then
		list = Instance.new("UIListLayout")
		list.Parent = scroll
	end
	if not studioV2 then list.Padding = UDim.new(0, 10) end
	list.SortOrder = Enum.SortOrder.LayoutOrder
	local padding = scroll:FindFirstChildOfClass("UIPadding")
	if not padding then
		padding = Instance.new("UIPadding")
		padding.Parent = scroll
	end
	if not studioV2 then
		padding.PaddingRight = UDim.new(0, 8)
		padding.PaddingBottom = UDim.new(0, 8)
	end

	local notice = panel(shop, "Notice", Theme.Burgundy, 8, 48)
	notice.Visible = false
	local noticeText = label(notice, "Text", "", 14, Theme.White, Theme.Bold, 49)
	noticeText.TextXAlignment = Enum.TextXAlignment.Center
	local noticeSerial = 0
	message = function(value: string): ()
		if value == "" then
			return
		end
		noticeSerial += 1
		local serial = noticeSerial
		noticeText.Text = value
		notice.Visible = true
		task.delay(4, function()
			if alive and noticeSerial == serial then
				notice.Visible = false
			end
		end)
	end

	local function promptProduct(productId: number): ()
		message(platform.PromptProduct(productId, reward) or "")
	end
	local function promptPass(theme: any): ()
		message(platform.PromptPass(theme, reward) or "")
	end
	local function purchaseStyle(object: TextButton, color: Color3, active: boolean): ()
		if not studioV2 then return end
		object.BackgroundColor3 = if active then color else Theme.Stage
		object.BackgroundTransparency = if active then 0 else 0.55
		object.TextColor3 = if active and color == Theme.Spotlight then Theme.Midnight else Theme.Paper
		object.TextTransparency = if active then 0 else 0.35
	end

	local entries: { [string]: any } = {}
	local previewArt: { ImageLabel } = {}
	local function entry(tab: string, id: string, order: number, height: number, fill: Color3): any
		local frame = panel(scroll, id, fill, 12, 44)
		frame.LayoutOrder = order
		if not studioV2 then frame.Size = UDim2.new(1, 0, 0, height) end
		local result = { frame = frame, tab = tab, height = height }
		entries[id] = result
		return result
	end

	for index, pack in Catalog.FICHA_PACKS do
		local row = entry("Fichas", pack.id, index, 116, Theme.Paper)
		row.icon = image(row.frame, "OfferIcon", pack.icon, 45)
		row.kicker = label(row.frame, "Kicker", string.upper(pack.name), 13, Theme.Burgundy, Theme.Bold, 45)
		row.amount = label(row.frame, "Amount", `+{pack.amount} TICKETS`, 29, Theme.Ink, Theme.Display, 45)
		row.detail =
			label(row.frame, "Detail", "Added to your balance after purchase.", 12, Theme.Muted, Theme.Body, 45)
		row.buy = button(row.frame, "BuyRobux", "COMING SOON", function()
			promptProduct(pack.productId)
		end, Theme.Stage, 45)
		row.productId = pack.productId
	end
	local earn = entry("Fichas", "earn", 4, 112, DEEP_BLUE)
	earn.title = label(earn.frame, "Title", "EARN ON STAGE", 24, Theme.Paper, Theme.Display, 45)
	earn.detail = label(
		earn.frame,
		"Detail",
		"+5 Tickets per match · +2 for a win. Your first match each day advances the reward track.",
		14,
		SOFT_GOLD,
		Theme.Body,
		45
	)

	-- The showcase uses the same card module as the match. A theme shown here
	-- therefore has the same frame, numbers and marked states in play.
	local showcase = entry("Cartelas", "theme_showcase", 0, 238, DEEP_BLUE)
	outline(showcase.frame, Theme.Spotlight, 2)
	local templateCard = showcase.frame:FindFirstChild("BingoCard")
	if templateCard and not studioV2 then
		templateCard:Destroy()
	end
	local showcaseCard = BingoCard.new(showcase.frame, function(_index: number) end,
		if studioV2 and templateCard and templateCard:IsA("Frame") then templateCard else nil)
	local sampleCells: { Types.CardCell } = {}
	for index, number in PREVIEW_NUMBERS do
		sampleCells[index] = { number = number, isFree = number == 0, isMarked = index == 2 or index == 9 }
	end
	showcaseCard.Render(sampleCells, "preview", {})
	local showcaseEyebrow = label(showcase.frame, "Eyebrow", "IN GAME PREVIEW", 12, SOFT_GOLD, Theme.Bold, 45)
	local showcaseName = label(showcase.frame, "Name", "", 29, Theme.Paper, Theme.Display, 45)
	local showcaseCopy = label(showcase.frame, "Copy", "The exact match frame. Numbers change every round.", 16, Theme.Paper, Theme.Body, 45)
	local showcaseStatus = label(showcase.frame, "Status", "", 13, SOFT_GOLD, Theme.Bold, 45)
	local showcaseAccent = panel(showcase.frame, "Accent", Theme.Spotlight, 0, 44)
	local selectedThemeId = "dossier_blue"
	local function showTheme(themeId: string): ()
		local theme = Catalog.FindTheme(themeId)
		if not theme then return end
		selectedThemeId = themeId
		showcaseCard.SetTheme(themeId)
		showcaseName.Text = theme.name
		local visualAccent = BingoCard.VisualTheme(themeId)
		showcaseAccent.BackgroundColor3 = visualAccent or theme.accent
		if render then render() end
	end
	showTheme(selectedThemeId)
	local showcaseFichas = button(showcase.frame, "BuyFichas", "", function()
		fire("BuyFichas", selectedThemeId)
	end, Theme.Spotlight, 45)
	local showcaseRobux = button(showcase.frame, "BuyRobux", "", function()
		local theme = Catalog.FindTheme(selectedThemeId)
		if theme then promptPass(theme) end
	end, Theme.Burgundy, 45)
	local showcaseEquip = button(showcase.frame, "Equip", "EQUIP", function()
		fire("Equip", selectedThemeId)
	end, Theme.Mark, 45)

	for index, theme in Catalog.THEMES do
		if theme.id == "classic" then
			continue
		end
		local row = entry("Cartelas", theme.id, index, 154, Theme.Paper)
		row.theme = theme
		row.swatch = panel(row.frame, "Preview", theme.accent, 9, 45)
		row.swatchPaper = panel(row.swatch, "Paper", theme.paper, 5, 46)
		row.swatchText = label(row.swatchPaper, "Letters", "B I N G O", 10, theme.accent, Theme.Bold, 47)
		row.swatchText.TextXAlignment = Enum.TextXAlignment.Center
		row.sample = panel(row.swatchPaper, "SampleNumbers", Theme.Paper, 0, 47)
		row.sample.BackgroundTransparency = 1
		local sampleLayout = row.sample:FindFirstChildOfClass("UIGridLayout")
		if not sampleLayout then
			sampleLayout = Instance.new("UIGridLayout")
			sampleLayout.Parent = row.sample
		end
		sampleLayout.CellSize = UDim2.new(0.2, -1, 0.2, -1)
		sampleLayout.CellPadding = UDim2.fromOffset(1, 1)
		sampleLayout.FillDirectionMaxCells = 5
		for cellIndex, number in PREVIEW_NUMBERS do
			local digit = label(
				row.sample,
				`Number{cellIndex}`,
				if number == 0 then "★" else tostring(number),
				8,
				theme.accent,
				Theme.Bold,
				47
			)
			digit.TextXAlignment = Enum.TextXAlignment.Center
			digit.LayoutOrder = cellIndex
		end
		row.art = image(row.swatch, "ThemeArtwork", theme.image, 48)
		table.insert(previewArt, row.art)
		row.name = label(row.frame, "Name", theme.name, 20, Theme.Ink, Theme.Bold, 45)
		row.detail = label(row.frame, "Detail", "Permanent card theme", 12, Theme.Muted, Theme.Body, 45)
		row.inspect = button(row.frame, "Inspect", "SEE IN GAME  ›", function()
			showTheme(theme.id)
			scroll.CanvasPosition = Vector2.zero
		end, Theme.Paper, 45)
		row.fichas = button(row.frame, "BuyFichas", "", function()
			showTheme(theme.id)
			fire("BuyFichas", theme.id)
		end, Theme.Stage, 45)
		row.robux = button(row.frame, "BuyRobux", "", function()
			showTheme(theme.id)
			promptPass(theme)
		end, Theme.Burgundy, 45)
		row.equip = button(row.frame, "Equip", "EQUIP", function()
			showTheme(theme.id)
			fire("Equip", theme.id)
		end, Theme.Mark, 45)
	end

	local powerRow = entry("Poderes", "suborn", 1, 232, Theme.Paper)
	local powerMark = image(powerRow.frame, "OfferIcon", Catalog.SUBORN_ICON, 45)
	powerRow.name = label(powerRow.frame, "Name", "BRIBE THE MC", 26, Theme.Ink, Theme.Display, 45)
	powerRow.detail = label(
		powerRow.frame,
		"Detail",
		"The MC calls a number from your card next, for everyone. You still need to mark it yourself.",
		14,
		Theme.Ink,
		Theme.Body,
		45
	)
	powerRow.limit =
		label(powerRow.frame, "Limit", "1 use per player · 2 per match", 13, Theme.Burgundy, Theme.Bold, 45)
	powerRow.stock = label(powerRow.frame, "Stock", "IN STOCK: 0", 13, Theme.Stage, Theme.Bold, 45)
	powerRow.fichas = button(powerRow.frame, "BuyFichas", "650 TICKETS", function()
		fire("BuyFichas", "suborn")
	end, Theme.Stage, 45)
	powerRow.robux = button(powerRow.frame, "BuyRobux", "COMING SOON", function()
		promptProduct(Catalog.SUBORN_PRODUCT_ID)
	end, Theme.Burgundy, 45)

	local inviteRow = entry("Convites", "invite", 1, 232, Theme.Paper)
	inviteRow.kicker = label(inviteRow.frame, "Kicker", "ONE INVITE, TWO REWARDS", 14, Theme.Burgundy, Theme.Bold, 45)
	inviteRow.name = label(inviteRow.frame, "Name", "CLUB SEAL", 29, Theme.Ink, Theme.Display, 45)
	inviteRow.detail = label(
		inviteRow.frame,
		"Detail",
		"Invite a friend through Roblox. When they finish their first match, you both get the Club Seal card theme. If you already own it, you get 50 Tickets.",
		14,
		Theme.Ink,
		Theme.Body,
		45
	)
	inviteRow.button = button(inviteRow.frame, "SendInvite", "INVITE A FRIEND", function()
		platform.Invite(message)
	end, Theme.Burgundy, 45)

	layout = function(width: number, height: number): ()
		lastSize = Vector2.new(width, height)
		if studioV2 then
			Surface.Rect(power, if width < 760 then (width - 232) / 2 else 20, height - (if width < 760 then 70 else 62), 232, 44)
			showcaseCard.LayoutTheme()
			return
		end
		local portrait = width < 760
		local hudWidth = if portrait then math.min(270, width - 24) else 282
		Surface.Rect(hud, if portrait then 12 else 20, if portrait then 216 else 236, hudWidth, 52)
		Surface.Rect(hudBalance, 13, 3, hudWidth - 133, 28)
		Surface.Rect(hudDaily, 13, 28, hudWidth - 133, 17)
		Surface.Rect(hudOpen, hudWidth - 116, 6, 110, 40)
		Surface.Rect(power, if portrait then (width - 232) / 2 else 20, height - (if portrait then 70 else 62), 232, 44)
		local w = math.min(960, width - 20)
		local h = math.min(650, height - 20)
		Surface.Rect(shop, (width - w) / 2, (height - h) / 2, w, h)
		Surface.Rect(header, 0, 0, w, 66)
		Surface.Rect(accent, 0, 62, w, 4)
		Surface.Rect(masthead, 18, 7, w - 132, 20)
		Surface.Rect(title, 18, 23, w - 132, 38)
		Surface.Rect(close, w - 108, 12, 92, 40)
		Surface.Rect(rail, 16, 76, w - 32, 80)
		local summaryWidth = w - 32
		local half = math.floor(summaryWidth / 2)
		balanceUnit.Visible = false
		Surface.Rect(balanceKicker, 18, 7, half - 24, 18)
		Surface.Rect(balance, 18, 25, half - 24, 40)
		Surface.SetTextSize(balance, if portrait then 29 else 35)
		Surface.Rect(dailyKicker, half + 6, 7, half - 24, 18)
		Surface.Rect(daily, half + 6, 26, half - 24, 24)
		Surface.SetTextSize(daily, if portrait then 13 else 17)
		Surface.Rect(dailyNote, half + 6, 50, half - 24, 19)
		Surface.Rect(demoNote, 18, 67, half - 24, 17)
		for index, dot in dots do
			dot.Visible = not portrait
			if not portrait then
				Surface.Rect(dot, half + 6 + (index - 1) * 26, 74, 19, 7)
			end
		end
		Surface.Rect(nav, 16, 165, w - 32, 40)
		local tabWidth = math.floor((w - 32 - 12) / 4)
		for index, name in { "Fichas", "Cartelas", "Poderes", "Convites" } do
			Surface.Rect(tabs[name], (index - 1) * (tabWidth + 4), 0, tabWidth, 40)
			Surface.SetTextSize(tabs[name], if portrait then 11 else 15)
		end
		Surface.Rect(sectionTitle, 20, 211, w - 40, 32)
		Surface.Rect(sectionCopy, 20, 241, w - 40, 19)
		Surface.Rect(commerceNote, 20, 260, w - 40, 18)
		Surface.Rect(scroll, 16, 283, w - 32, h - 297)
		Surface.Rect(notice, 18, h - 56, w - 36, 42)
		Surface.Rect(noticeText, 8, 2, w - 52, 38)
		local cardWidth = w - 40
		for _, row in entries do
			row.frame.Size = UDim2.new(1, 0, 0, row.height)
		end
		local narrowShowcase = cardWidth < 480
		local showcaseWidth = if narrowShowcase then 154 else 194
		showcase.frame.Size = UDim2.new(1, 0, 0, if narrowShowcase then 402 else 264)
		Surface.Rect(showcaseAccent, cardWidth - 8, 0, 8, if narrowShowcase then 402 else 264)
		Surface.Rect(showcaseCard.Instance, if narrowShowcase then (cardWidth - showcaseWidth) / 2 else 16,
			if narrowShowcase then 8 else 13, showcaseWidth, showcaseWidth + 32)
		local showcaseTextX = if narrowShowcase then 16 else showcaseWidth + 36
		local showcaseTextY = if narrowShowcase then 198 else 30
		Surface.Rect(showcaseEyebrow, showcaseTextX, showcaseTextY, cardWidth - showcaseTextX - 14, 19)
		Surface.Rect(showcaseName, showcaseTextX, showcaseTextY + 24, cardWidth - showcaseTextX - 14, 40)
		Surface.Rect(showcaseCopy, showcaseTextX, showcaseTextY + 69, cardWidth - showcaseTextX - 14, 45)
		Surface.Rect(showcaseStatus, showcaseTextX, showcaseTextY + 116, cardWidth - showcaseTextX - 14, 25)
		local actionY = if narrowShowcase then 348 else 185
		local actionWidth = cardWidth - showcaseTextX - 16
		Surface.Rect(showcaseFichas, showcaseTextX, actionY, (actionWidth - 8) / 2, 42)
		Surface.Rect(showcaseRobux, showcaseTextX + (actionWidth + 8) / 2, actionY, (actionWidth - 8) / 2, 42)
		Surface.Rect(showcaseEquip, showcaseTextX, actionY, actionWidth, 42)
		showcaseCard.LayoutTheme()
		for _, pack in Catalog.FICHA_PACKS do
			local row = entries[pack.id]
			row.frame.Size = UDim2.new(1, 0, 0, if portrait then 148 else 126)
			Surface.Rect(row.icon, 14, 17, if portrait then 55 else 82, if portrait then 55 else 82)
			Surface.Rect(
				row.kicker,
				if portrait then 76 else 110,
				if portrait then 12 else 22,
				cardWidth - (if portrait then 94 else 280),
				20
			)
			Surface.Rect(
				row.amount,
				if portrait then 76 else 110,
				if portrait then 34 else 45,
				cardWidth - (if portrait then 94 else 280),
				38
			)
			row.amount.TextSize = if portrait then 23 else 29
			Surface.Rect(
				row.detail,
				if portrait then 18 else 110,
				if portrait then 73 else 87,
				cardWidth - (if portrait then 36 else 280),
				25
			)
			Surface.Rect(
				row.buy,
				if portrait then 18 else cardWidth - 154,
				if portrait then 103 else 39,
				if portrait then cardWidth - 36 else 136,
				if portrait then 35 else 46
			)
		end
		Surface.Rect(earn.title, 18, 10, cardWidth - 36, 36)
		Surface.Rect(earn.detail, 18, 47, cardWidth - 36, 55)
		for _, theme in Catalog.THEMES do
			local row = entries[theme.id]
			if not row then
				continue
			end
			local preview = if portrait then 88 else 126
			row.frame.Size = UDim2.new(1, 0, 0, if portrait then 150 else 148)
			Surface.Rect(row.swatch, 10, 10, preview, preview)
			Surface.Rect(row.swatchPaper, 5, 5, preview - 10, preview - 10)
			Surface.Rect(row.swatchText, 8, 14, preview - 26, 24)
			Surface.Rect(row.sample, 12, if portrait then 33 else 41, preview - 34, if portrait then 42 else 66)
			Surface.Rect(row.art, 0, 0, preview, preview)
			local contentX = preview + 22
			Surface.Rect(row.name, contentX, 10, cardWidth - contentX - 10, 30)
			Surface.Rect(row.detail, contentX, 42, cardWidth - contentX - 10, 25)
			Surface.Rect(row.inspect, contentX, 66, cardWidth - contentX - 12, 20)
			local buyWidth = math.floor((cardWidth - contentX - 18) / 2)
			Surface.Rect(row.fichas, contentX, if portrait then 95 else 87, buyWidth, 43)
			Surface.Rect(row.robux, contentX + buyWidth + 6, if portrait then 95 else 87, buyWidth, 43)
			Surface.Rect(row.equip, contentX, if portrait then 95 else 87, cardWidth - contentX - 12, 43)
		end
		Surface.Rect(powerMark, 18, 16, 62, 62)
		Surface.Rect(powerRow.name, 94, 17, cardWidth - 110, 48)
		Surface.Rect(powerRow.detail, 18, 89, cardWidth - 36, 65)
		Surface.Rect(powerRow.limit, 18, 155, cardWidth - 36, 25)
		Surface.Rect(powerRow.stock, 18, 178, cardWidth - 36, 20)
		Surface.Rect(powerRow.fichas, 18, 198, (cardWidth - 46) / 2, 30)
		Surface.Rect(powerRow.robux, 28 + (cardWidth - 46) / 2, 198, (cardWidth - 46) / 2, 30)
		Surface.Rect(inviteRow.kicker, 18, 14, cardWidth - 36, 24)
		Surface.Rect(inviteRow.name, 18, 40, cardWidth - 36, 46)
		Surface.Rect(inviteRow.detail, 18, 92, cardWidth - 36, 86)
		Surface.Rect(inviteRow.button, 18, 185, cardWidth - 36, 40)
	end

	render = function(): ()
		if not alive then
			return
		end
		local isLobby = bingo == nil or not bingo.isParticipant
		hud.Visible = isLobby and not separatedHud
		if separatedHud then
			(ticketBalance :: Frame).Visible = isLobby
			(milestoneProgress :: Frame).Visible = isLobby
			(openShopButton :: TextButton).Visible = isLobby
		end
		power.Visible = bingo ~= nil and bingo.isParticipant and bingo.phase == "CallingNumbers"
		if not isLobby then
			menuOpen = false
		end
		shade.Visible = menuOpen
		shop.Visible = menuOpen
		local ready = reward and reward.ready == true
		local purchaseMode = if ready and typeof(reward.purchaseMode) == "string"
			then reward.purchaseMode
			else "disabled"
		local canPurchase = ready and purchaseMode ~= "disabled"
		local fichas = if ready then reward.fichas else 0
		local selectedTheme = Catalog.FindTheme(selectedThemeId)
		local showcaseOwned = selectedTheme ~= nil and ready and reward.ownedThemes[selectedThemeId] == true
		showcaseFichas.Visible = selectedTheme ~= nil and selectedTheme.fichas >= 0 and not showcaseOwned
		showcaseFichas.Text = if selectedTheme then `{selectedTheme.fichas} TICKETS` else ""
		showcaseFichas.Active = selectedTheme ~= nil and ready and fichas >= selectedTheme.fichas
		showcaseFichas.BackgroundColor3 = if showcaseFichas.Active then Theme.Spotlight else (if studioV2 then Theme.Stage else Theme.Disabled)
		purchaseStyle(showcaseFichas, Theme.Spotlight, showcaseFichas.Active)
		showcaseRobux.Visible = not showcaseOwned
		showcaseRobux.Text = if selectedTheme then `{prices[selectedTheme.passId] or selectedTheme.targetRobux} ROBUX{if prices[selectedTheme.passId] then "" else "*"}` else ""
		showcaseRobux.Active = selectedTheme ~= nil and canPurchase and selectedTheme.passId > 0
			and prices[selectedTheme.passId] ~= nil and (purchaseMode ~= "simulated" or platform.HasSimulatedPass())
		showcaseRobux.BackgroundColor3 = if showcaseRobux.Active then (if studioV2 then Theme.Spotlight else Theme.Burgundy) else (if studioV2 then Theme.Stage else Theme.Disabled)
		showcaseRobux.TextColor3 = if studioV2 then Theme.Midnight else (if showcaseRobux.Active then Theme.White else Theme.Muted)
		purchaseStyle(showcaseRobux, Theme.Spotlight, showcaseRobux.Active)
		showcaseEquip.Visible = showcaseOwned
		showcaseEquip.Text = if ready and reward.equippedTheme == selectedThemeId then "EQUIPPED FOR MATCH" else "EQUIP FOR MATCH"
		showcaseEquip.Active = showcaseOwned and reward.equippedTheme ~= selectedThemeId
		showcaseStatus.Text = if ready and reward.equippedTheme == selectedThemeId
			then "EQUIPPED FOR YOUR NEXT MATCH"
			elseif ready and reward.ownedThemes[selectedThemeId] then "IN YOUR COLLECTION · TAP EQUIP"
			else "CHOOSE THIS CARD FOR THE STAGE"
		if studioV2 and selectedTheme and not showcaseOwned then
			showcaseStatus.Text = if selectedTheme.fichas < 0 then "ROBUX EXCLUSIVE"
				elseif ready and fichas < selectedTheme.fichas then `NEED {selectedTheme.fichas - fichas} MORE TICKETS`
				else "READY TO BUY"
		end
		hudBalance.Text = if ready then `{fichas} TICKETS` else "LOADING"
		hudDaily.Text = if ready
			then `MILESTONE {reward.dailyIndex + 1}/7 · +{Catalog.DAILY_FICHAS[reward.dailyIndex + 1]}`
			else "PLEASE WAIT"
		if separatedHud then
			local balanceText = (ticketBalance :: Frame):FindFirstChild("Fichas") :: TextLabel
			local milestoneText = (milestoneProgress :: Frame):FindFirstChild("NextReward") :: TextLabel
			balanceText.Text = hudBalance.Text
			milestoneText.Text = hudDaily.Text
			for dotIndex = 1, 7 do
				local dot = (milestoneProgress :: Frame):FindFirstChild(`DailyDot{dotIndex}`)
				if dot and dot:IsA("Frame") then
					dot.BackgroundColor3 = if ready and dotIndex <= reward.dailyIndex then Theme.Mark else Theme.Stage
				end
			end
		end
		balance.Text = if ready then `{fichas} TICKETS` else "—"
		if ready then
			local index = reward.dailyIndex + 1
			daily.Text = `Step {index}/7 · +{Catalog.DAILY_FICHAS[index]} Tickets`
			dailyNote.Text = if reward.dailyReady then "Finish a match today" else "Come back tomorrow to advance"
			for dotIndex, dot in dots do
				dot.BackgroundColor3 = if dotIndex <= reward.dailyIndex then Theme.Mark else (if studioV2 then Theme.Stage else Theme.Disabled)
			end
		else
			daily.Text = "Rewards unavailable"
			dailyNote.Text = "Please try again shortly"
		end
		demoNote.Text = if purchaseMode == "simulated"
			then (if lastSize.X < 760 then "NO SAVE IN STUDIO" else "STUDIO: PROGRESS IS NOT SAVED")
			else (if lastSize.X < 760 then "PROGRESS STAYS" else "Missing a day will not reset your track.")
		power.Text = if ready
			then `BRIBE ({reward.suborns}) · {if bingo then bingo.subornsUsed else 0}/2`
			else "BRIBE THE MC"
		power.Active = ready
			and reward.suborns > 0
			and bingo ~= nil
			and not bingo.hasUsedSuborn
			and bingo.subornsUsed < 2
		power.AutoButtonColor = power.Active
		local copies = {
			Fichas = { "TICKETS", "Earn them by playing or pick a pack." },
			Cartelas = { "CARDS", "Permanent themes for your Bingo card." },
			Poderes = { "POWER UPS", "A bonus call announced to everyone." },
			Convites = { "INVITES", "Bring a friend into the club." },
		}
		sectionTitle.Text = copies[selectedTab][1]
		sectionCopy.Text = copies[selectedTab][2]
		local unavailableOffer = false
		if selectedTab == "Fichas" then
			for _, pack in Catalog.FICHA_PACKS do
				if pack.productId <= 0 or prices[pack.productId] == nil then
					unavailableOffer = true
					break
				end
			end
		elseif selectedTab == "Cartelas" then
			for _, theme in Catalog.THEMES do
				if theme.id ~= "classic" and (theme.passId <= 0 or prices[theme.passId] == nil) then
					unavailableOffer = true
					break
				end
			end
		elseif selectedTab == "Poderes" then
			unavailableOffer = Catalog.SUBORN_PRODUCT_ID <= 0 or prices[Catalog.SUBORN_PRODUCT_ID] == nil
		end
		commerceNote.Text = if selectedTab == "Convites"
			then ""
			elseif purchaseMode == "simulated" and not unavailableOffer then (if selectedTab == "Cartelas"
					and not platform.HasSimulatedPass()
				then "Studio: use studio.project.json to simulate passes."
				elseif
					selectedTab == "Cartelas"
				then "Studio: simulated pass with a temporary profile; no Robux charged."
				elseif lastSize.X < 760 then "Studio: simulated purchase, no Robux."
				else "Studio: simulated purchase; no Robux charged. Progress is not saved.")
			elseif purchaseMode == "disabled" then "Test profile with DataStore: simulated purchases are disabled."
			elseif unavailableOffer then (if lastSize.X < 760
				then "*Estimated Robux price; sale inactive."
				else "*Estimated price; purchases unavailable until products are enabled on Roblox.")
			else (if lastSize.X < 760
				then "Robux price confirmed by Roblox."
				else "Robux price confirmed by Roblox. The platform verifies each purchase.")
		if studioV2 then
			commerceNote.Text = if selectedTab == "Convites" then ""
				elseif purchaseMode == "simulated" and not unavailableOffer then "Studio demo: no Robux charged; progress is not saved."
				elseif purchaseMode == "disabled" then "Purchases are unavailable in this test profile."
				elseif unavailableOffer then "*Estimated Robux price; sale unavailable."
				else "Robux price confirmed by Roblox."
		end
		for name, tab in tabs do
			local selected = name == selectedTab
			tab.BackgroundColor3 = if selected then Theme.Spotlight else Theme.Stage
			tab.TextColor3 = if selected then (if studioV2 then Theme.Midnight else Theme.Ink) else Theme.Paper
			if studioV2 then
				local stroke = tab:FindFirstChildOfClass("UIStroke")
				if stroke then stroke.Thickness = if selected then 3 else 1 end
			end
		end
		for _, row in entries do
			row.frame.Visible = row.tab == selectedTab
		end
		for _, pack in Catalog.FICHA_PACKS do
			local row = entries[pack.id]
			row.buy.Text =
				`{prices[pack.productId] or pack.targetRobux} ROBUX{if prices[pack.productId] then "" else "*"}`
			row.buy.Active = canPurchase and pack.productId > 0 and prices[pack.productId] ~= nil
			row.buy.AutoButtonColor = row.buy.Active
			row.buy.BackgroundColor3 = if row.buy.Active then (if studioV2 then Theme.Spotlight else Theme.Stage) else (if studioV2 then Theme.Stage else Theme.Disabled)
			row.buy.TextColor3 = if studioV2 then Theme.Midnight else (if row.buy.Active then Theme.White else Theme.Muted)
			purchaseStyle(row.buy, Theme.Spotlight, row.buy.Active)
		end
		for _, theme in Catalog.THEMES do
			local row = entries[theme.id]
			if not row then
				continue
			end
			local owned = ready and reward.ownedThemes[theme.id] == true
			row.fichas.Visible = theme.fichas >= 0 and not owned
			row.fichas.Text = `{theme.fichas} TICKETS`
			row.fichas.Active = ready and fichas >= theme.fichas
			row.fichas.BackgroundColor3 = if row.fichas.Active then Theme.Stage else (if studioV2 then Theme.Stage else Theme.Disabled)
			row.fichas.TextColor3 = if studioV2 then Theme.Paper else (if row.fichas.Active then Theme.White else Theme.Muted)
			purchaseStyle(row.fichas, Theme.Stage, row.fichas.Active)
			row.robux.Visible = not owned
			row.robux.Text =
				`{prices[theme.passId] or theme.targetRobux} ROBUX{if prices[theme.passId] then "" else "*"}`
			row.robux.Active = canPurchase
				and (purchaseMode ~= "simulated" or platform.HasSimulatedPass())
				and theme.passId > 0
				and prices[theme.passId] ~= nil
			row.robux.BackgroundColor3 = if row.robux.Active then (if studioV2 then Theme.Spotlight else Theme.Burgundy) else (if studioV2 then Theme.Stage else Theme.Disabled)
			row.robux.TextColor3 = if studioV2 then Theme.Midnight else (if row.robux.Active then Theme.White else Theme.Muted)
			purchaseStyle(row.robux, Theme.Spotlight, row.robux.Active)
			row.equip.Visible = owned
			row.equip.Text = if ready and reward.equippedTheme == theme.id then "EQUIPPED" else "EQUIP"
			row.equip.Active = owned and reward.equippedTheme ~= theme.id
			row.detail.Text = if owned
				then "In your collection"
				elseif theme.fichas < 0 then "Robux exclusive · permanent"
				else "Earn by playing or buy now"
			if studioV2 and not owned and theme.fichas >= 0 and ready and fichas < theme.fichas then
				row.detail.Text = `Need {theme.fichas - fichas} more Tickets`
			end
		end
		powerRow.stock.Text = `IN STOCK: {if ready then reward.suborns else 0}`
		powerRow.fichas.Active = ready and fichas >= Catalog.SUBORN_FICHAS
		powerRow.fichas.BackgroundColor3 = if powerRow.fichas.Active then Theme.Stage else (if studioV2 then Theme.Stage else Theme.Disabled)
		powerRow.fichas.TextColor3 = if studioV2 then Theme.Paper else (if powerRow.fichas.Active then Theme.White else Theme.Muted)
		purchaseStyle(powerRow.fichas, Theme.Stage, powerRow.fichas.Active)
		powerRow.robux.Text =
			`{prices[Catalog.SUBORN_PRODUCT_ID] or Catalog.SUBORN_TARGET_ROBUX} ROBUX{if prices[Catalog.SUBORN_PRODUCT_ID]
				then ""
				else "*"}`
		powerRow.robux.Active = canPurchase
			and Catalog.SUBORN_PRODUCT_ID > 0
			and prices[Catalog.SUBORN_PRODUCT_ID] ~= nil
		powerRow.robux.BackgroundColor3 = if powerRow.robux.Active then (if studioV2 then Theme.Spotlight else Theme.Burgundy) else (if studioV2 then Theme.Stage else Theme.Disabled)
		powerRow.robux.TextColor3 = if studioV2 then Theme.Midnight else (if powerRow.robux.Active then Theme.White else Theme.Muted)
		purchaseStyle(powerRow.robux, Theme.Spotlight, powerRow.robux.Active)
	end

	local menu = {}
	function menu.SetContext(snapshot: Types.Snapshot?): ()
		bingo = snapshot
		local size = root.AbsoluteSize
		if size ~= lastSize and size.X > 0 and size.Y > 0 then
			layout(size.X, size.Y)
		end
		if os.clock() - lastRequest >= (if reward and reward.ready then 30 else 2) then
			lastRequest = os.clock()
			platform.Discover()
			fire("Request")
		end
		render()
	end
	function menu.Destroy(): ()
		alive = false
		platform.Destroy()
		showcaseCard.Destroy()
		for _, connection in connections do
			connection:Disconnect()
		end
		for _, component in buttons do
			component.Destroy()
		end
		root:Destroy()
	end
	table.insert(
		connections,
		shade.Activated:Connect(function()
			menuOpen = false
			render()
		end)
	)
	platform.Start(previewArt)
	return menu
end

return Controller
