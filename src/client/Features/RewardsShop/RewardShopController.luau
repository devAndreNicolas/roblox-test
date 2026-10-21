--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Catalog = require(ReplicatedStorage.Shared.Features.RewardsShop.RewardCatalog)
local Types = require(ReplicatedStorage.Shared.Features.Bingo.BingoTypes)
local BingoCard = require(script.Parent.Parent.Bingo.Components.BingoCard)
local PlatformAdapter = require(script.Parent.RewardShopPlatformAdapter)
local UI = script.Parent.Parent.Parent.UI
local Surface = require(UI.Surface)
local Theme = require(UI.Theme)
local ActionButton = require(UI.ActionButton)

local Controller = {}
local SOFT_GOLD = Color3.fromRGB(255, 224, 150)
local DEEP_BLUE = Color3.fromRGB(27, 43, 78)
local PREVIEW_NUMBERS =
	{ 7, 18, 33, 47, 62, 11, 24, 38, 52, 67, 4, 27, 0, 49, 70, 13, 21, 42, 58, 73, 2, 29, 44, 55, 65 }

local function panel(parent: Instance, name: string, color: Color3, radius: number, z: number): Frame
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
	local object = Surface.Text(parent, name, size, color, font)
	object.Text = value
	object.ZIndex = z
	object.TextYAlignment = Enum.TextYAlignment.Center
	return object
end

local function outline(object: GuiObject, color: Color3, thickness: number): ()
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

	local hud = panel(root, "RewardsHud", DEEP_BLUE, 14, 31)
	outline(hud, Theme.Spotlight, 2)
	local hudBalance = label(hud, "Fichas", "0 FICHAS", 18, Theme.Paper, Theme.Display, 32)
	local hudDaily = label(hud, "NextReward", "PRÓXIMO MARCO", 11, SOFT_GOLD, Theme.Body, 32)
	local hudOpen = button(hud, "OpenShop", "ABRIR LOJA", function()
		menuOpen = true
		render()
	end, Theme.Spotlight, 32)

	local power = button(root, "UseSuborn", "SUBORNO DO MC", function()
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
	end, Theme.Burgundy, 32)

	local shade = Instance.new("TextButton")
	shade.Name = "ShopShade"
	shade.Text = ""
	shade.BackgroundColor3 = Theme.Midnight
	shade.BackgroundTransparency = 0.16
	shade.BorderSizePixel = 0
	shade.Size = UDim2.fromScale(1, 1)
	shade.ZIndex = 40
	shade.Visible = false
	shade.Parent = root

	local shop = panel(root, "ShopPanel", Theme.Midnight, 18, 41)
	outline(shop, Theme.Spotlight, 2)
	shop.ClipsDescendants = true
	shop.Visible = false
	local header = panel(shop, "Header", Theme.Stage, 0, 42)
	local accent = panel(header, "GoldRule", Theme.Spotlight, 0, 43)
	local masthead = label(header, "Masthead", "BINGO NOIR  /  LOJA", 14, SOFT_GOLD, Theme.Display, 44)
	local title = label(header, "Title", "LOJA DO PALCO", 29, Theme.Paper, Theme.Display, 44)
	local close = button(header, "CloseShop", "FECHAR  ×", function()
		menuOpen = false
		render()
	end, DEEP_BLUE, 44)

	local rail = panel(shop, "Rail", Theme.Paper, 12, 42)
	local balanceKicker = label(rail, "BalanceKicker", "SEU SALDO", 13, Theme.Burgundy, Theme.Bold, 43)
	local balance = label(rail, "Balance", "0", 44, Theme.Ink, Theme.Display, 43)
	local balanceUnit = label(rail, "BalanceUnit", "FICHAS", 16, Theme.Stage, Theme.Display, 43)
	local dailyKicker = label(rail, "DailyKicker", "PRÓXIMO MARCO", 13, Theme.Burgundy, Theme.Bold, 43)
	local daily = label(rail, "Daily", "Jogue uma partida hoje", 17, Theme.Ink, Theme.Bold, 43)
	local dailyNote = label(rail, "DailyNote", "7 marcos · sem perder progresso", 12, Theme.Muted, Theme.Body, 43)
	local dots: { Frame } = {}
	for index = 1, 7 do
		local dot = panel(rail, `DailyDot{index}`, Theme.Disabled, 4, 43)
		dots[index] = dot
	end
	local demoNote = label(rail, "DemoNote", "", 11, Theme.Muted, Theme.Body, 43)

	local scroll: ScrollingFrame
	local nav = Instance.new("Frame")
	nav.Name = "Categories"
	nav.BackgroundTransparency = 1
	nav.ZIndex = 43
	nav.Parent = shop
	local tabs: { [string]: TextButton } = {}
	for _, tab in { "Fichas", "Cartelas", "Poderes", "Convites" } do
		tabs[tab] = button(nav, tab, string.upper(tab), function()
			selectedTab = tab
			scroll.CanvasPosition = Vector2.zero
			render()
		end, Theme.Stage, 44)
	end

	local sectionTitle = label(shop, "SectionTitle", "FICHAS", 30, Theme.Paper, Theme.Display, 43)
	local sectionCopy = label(shop, "SectionCopy", "Ganhe jogando ou escolha um pacote.", 14, SOFT_GOLD, Theme.Body, 43)
	local commerceNote = label(
		shop,
		"CommerceNote",
		"Preços previstos; compras Robux ainda indisponíveis.",
		12,
		Theme.Paper,
		Theme.Body,
		43
	)
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
	local list = Instance.new("UIListLayout")
	list.Padding = UDim.new(0, 10)
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Parent = scroll
	local padding = Instance.new("UIPadding")
	padding.PaddingRight = UDim.new(0, 8)
	padding.PaddingBottom = UDim.new(0, 8)
	padding.Parent = scroll

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

	local entries: { [string]: any } = {}
	local previewArt: { ImageLabel } = {}
	local function entry(tab: string, id: string, order: number, height: number, fill: Color3): any
		local frame = panel(scroll, id, fill, 12, 44)
		frame.LayoutOrder = order
		frame.Size = UDim2.new(1, 0, 0, height)
		local result = { frame = frame, tab = tab, height = height }
		entries[id] = result
		return result
	end

	for index, pack in Catalog.FICHA_PACKS do
		local row = entry("Fichas", pack.id, index, 116, Theme.Paper)
		row.icon = Instance.new("ImageLabel")
		row.icon.Name = "OfferIcon"
		row.icon.Image = pack.icon
		row.icon.BackgroundTransparency = 1
		row.icon.ScaleType = Enum.ScaleType.Fit
		row.icon.ZIndex = 45
		row.icon.Parent = row.frame
		row.kicker = label(row.frame, "Kicker", string.upper(pack.name), 13, Theme.Burgundy, Theme.Bold, 45)
		row.amount = label(row.frame, "Amount", `+{pack.amount} FICHAS`, 29, Theme.Ink, Theme.Display, 45)
		row.detail =
			label(row.frame, "Detail", "Adicionadas ao seu saldo após a compra.", 12, Theme.Muted, Theme.Body, 45)
		row.buy = button(row.frame, "BuyRobux", "EM BREVE", function()
			promptProduct(pack.productId)
		end, Theme.Stage, 45)
		row.productId = pack.productId
	end
	local earn = entry("Fichas", "earn", 4, 112, DEEP_BLUE)
	earn.title = label(earn.frame, "Title", "GANHE NO PALCO", 24, Theme.Paper, Theme.Display, 45)
	earn.detail = label(
		earn.frame,
		"Detail",
		"+5 Fichas por partida · +2 ao vencer. O primeiro jogo do dia também avança sua trilha.",
		14,
		SOFT_GOLD,
		Theme.Body,
		45
	)

	-- The showcase uses the same card module as the match. A theme shown here
	-- therefore has the same frame, numbers and marked states in play.
	local showcase = entry("Cartelas", "theme_showcase", 0, 238, DEEP_BLUE)
	outline(showcase.frame, Theme.Spotlight, 2)
	local showcaseCard = BingoCard.new(showcase.frame, function(_index: number) end)
	local sampleCells: { Types.CardCell } = {}
	for index, number in PREVIEW_NUMBERS do
		sampleCells[index] = { number = number, isFree = number == 0, isMarked = index == 2 or index == 9 }
	end
	showcaseCard.Render(sampleCells, "preview", {})
	local showcaseEyebrow = label(showcase.frame, "Eyebrow", "PRÉVIA NA PARTIDA", 12, SOFT_GOLD, Theme.Bold, 45)
	local showcaseName = label(showcase.frame, "Name", "", 29, Theme.Paper, Theme.Display, 45)
	local showcaseCopy = label(showcase.frame, "Copy", "Moldura real da partida. Os números mudam a cada rodada.", 16, Theme.Paper, Theme.Body, 45)
	local showcaseStatus = label(showcase.frame, "Status", "", 13, SOFT_GOLD, Theme.Bold, 45)
	local showcaseAccent = panel(showcase.frame, "Accent", Theme.Spotlight, 0, 44)
	local selectedThemeId = "dossier_blue"
	local function showTheme(themeId: string): ()
		local theme = Catalog.FindTheme(themeId)
		if not theme then return end
		selectedThemeId = themeId
		showcaseCard.SetTheme(themeId)
		showcaseName.Text = theme.name
		showcaseAccent.BackgroundColor3 = theme.accent
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
	local showcaseEquip = button(showcase.frame, "Equip", "EQUIPAR", function()
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
		row.sample = Instance.new("Frame")
		row.sample.Name = "SampleNumbers"
		row.sample.BackgroundTransparency = 1
		row.sample.ZIndex = 47
		row.sample.Parent = row.swatchPaper
		local sampleLayout = Instance.new("UIGridLayout")
		sampleLayout.CellSize = UDim2.new(0.2, -1, 0.2, -1)
		sampleLayout.CellPadding = UDim2.fromOffset(1, 1)
		sampleLayout.FillDirectionMaxCells = 5
		sampleLayout.Parent = row.sample
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
		row.art = Instance.new("ImageLabel")
		row.art.Name = "ThemeArtwork"
		row.art.Image = theme.image
		row.art.BackgroundTransparency = 1
		row.art.ScaleType = Enum.ScaleType.Fit
		row.art.ZIndex = 48
		row.art.Parent = row.swatch
		table.insert(previewArt, row.art)
		row.name = label(row.frame, "Name", theme.name, 20, Theme.Ink, Theme.Bold, 45)
		row.detail = label(row.frame, "Detail", "Tema permanente da cartela", 12, Theme.Muted, Theme.Body, 45)
		row.inspect = button(row.frame, "Inspect", "VER NA PARTIDA  ›", function()
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
		row.equip = button(row.frame, "Equip", "EQUIPAR", function()
			showTheme(theme.id)
			fire("Equip", theme.id)
		end, Theme.Mark, 45)
	end

	local powerRow = entry("Poderes", "suborn", 1, 232, Theme.Paper)
	local powerMark = Instance.new("ImageLabel")
	powerMark.Name = "OfferIcon"
	powerMark.Image = Catalog.SUBORN_ICON
	powerMark.BackgroundTransparency = 1
	powerMark.ScaleType = Enum.ScaleType.Fit
	powerMark.ZIndex = 45
	powerMark.Parent = powerRow.frame
	powerRow.name = label(powerRow.frame, "Name", "SUBORNO DO MC", 26, Theme.Ink, Theme.Display, 45)
	powerRow.detail = label(
		powerRow.frame,
		"Detail",
		"O MC anuncia um número da sua cartela como próxima chamada para todos. Você ainda precisa marcá-lo.",
		14,
		Theme.Ink,
		Theme.Body,
		45
	)
	powerRow.limit =
		label(powerRow.frame, "Limit", "1 uso por jogador · 2 por partida", 13, Theme.Burgundy, Theme.Bold, 45)
	powerRow.stock = label(powerRow.frame, "Stock", "NO ESTOQUE: 0", 13, Theme.Stage, Theme.Bold, 45)
	powerRow.fichas = button(powerRow.frame, "BuyFichas", "650 FICHAS", function()
		fire("BuyFichas", "suborn")
	end, Theme.Stage, 45)
	powerRow.robux = button(powerRow.frame, "BuyRobux", "EM BREVE", function()
		promptProduct(Catalog.SUBORN_PRODUCT_ID)
	end, Theme.Burgundy, 45)

	local inviteRow = entry("Convites", "invite", 1, 232, Theme.Paper)
	inviteRow.kicker = label(inviteRow.frame, "Kicker", "UM CONVITE, DOIS PRÊMIOS", 14, Theme.Burgundy, Theme.Bold, 45)
	inviteRow.name = label(inviteRow.frame, "Name", "SELO DO CLUBE", 29, Theme.Ink, Theme.Display, 45)
	inviteRow.detail = label(
		inviteRow.frame,
		"Detail",
		"Convide alguém pelo Roblox. Quando essa pessoa concluir a primeira partida, vocês dois recebem o tema Selo do Clube. Se já tiverem o tema, recebem 50 Fichas.",
		14,
		Theme.Ink,
		Theme.Body,
		45
	)
	inviteRow.button = button(inviteRow.frame, "SendInvite", "CONVIDAR AMIGO", function()
		platform.Invite(message)
	end, Theme.Burgundy, 45)

	layout = function(width: number, height: number): ()
		lastSize = Vector2.new(width, height)
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
		balance.TextSize = if portrait then 29 else 35
		Surface.Rect(dailyKicker, half + 6, 7, half - 24, 18)
		Surface.Rect(daily, half + 6, 26, half - 24, 24)
		daily.TextSize = if portrait then 13 else 17
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
			tabs[name].TextSize = if portrait then 11 else 15
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
		hud.Visible = isLobby
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
		showcaseFichas.Text = if selectedTheme then `{selectedTheme.fichas} FICHAS` else ""
		showcaseFichas.Active = selectedTheme ~= nil and ready and fichas >= selectedTheme.fichas
		showcaseFichas.BackgroundColor3 = if showcaseFichas.Active then Theme.Spotlight else Theme.Disabled
		showcaseRobux.Visible = not showcaseOwned
		showcaseRobux.Text = if selectedTheme then `{prices[selectedTheme.passId] or selectedTheme.targetRobux} ROBUX{if prices[selectedTheme.passId] then "" else "*"}` else ""
		showcaseRobux.Active = selectedTheme ~= nil and canPurchase and selectedTheme.passId > 0
			and prices[selectedTheme.passId] ~= nil and (purchaseMode ~= "simulated" or platform.HasSimulatedPass())
		showcaseRobux.BackgroundColor3 = if showcaseRobux.Active then Theme.Burgundy else Theme.Disabled
		showcaseRobux.TextColor3 = if showcaseRobux.Active then Theme.White else Theme.Muted
		showcaseEquip.Visible = showcaseOwned
		showcaseEquip.Text = if ready and reward.equippedTheme == selectedThemeId then "EQUIPADA NA PARTIDA" else "EQUIPAR NA PARTIDA"
		showcaseEquip.Active = showcaseOwned and reward.equippedTheme ~= selectedThemeId
		showcaseStatus.Text = if ready and reward.equippedTheme == selectedThemeId
			then "EQUIPADA PARA A PRÓXIMA PARTIDA"
			elseif ready and reward.ownedThemes[selectedThemeId] then "NA SUA COLEÇÃO · TOQUE EM EQUIPAR"
			else "ESCOLHA ESTA CARTELA PARA LEVAR AO PALCO"
		hudBalance.Text = if ready then `{fichas} FICHAS` else "CARREGANDO"
		hudDaily.Text = if ready
			then `MARCO {reward.dailyIndex + 1}/7 · +{Catalog.DAILY_FICHAS[reward.dailyIndex + 1]}`
			else "AGUARDE"
		balance.Text = if ready then `{fichas} FICHAS` else "—"
		if ready then
			local index = reward.dailyIndex + 1
			daily.Text = `Etapa {index}/7 · +{Catalog.DAILY_FICHAS[index]} Fichas`
			dailyNote.Text = if reward.dailyReady then "Conclua uma partida hoje" else "Volte amanhã para avançar"
			for dotIndex, dot in dots do
				dot.BackgroundColor3 = if dotIndex <= reward.dailyIndex then Theme.Mark else Theme.Disabled
			end
		else
			daily.Text = "Recompensas indisponíveis"
			dailyNote.Text = "Tente novamente em instantes"
		end
		demoNote.Text = if purchaseMode == "simulated"
			then (if lastSize.X < 760 then "TESTE SEM SALVAR" else "STUDIO: SEM SALVAMENTO")
			else (if lastSize.X < 760 then "TRILHA SEM RESET" else "A trilha não zera se você faltar.")
		power.Text = if ready
			then `SUBORNO ({reward.suborns}) · {if bingo then bingo.subornsUsed else 0}/2`
			else "SUBORNO DO MC"
		power.Active = ready
			and reward.suborns > 0
			and bingo ~= nil
			and not bingo.hasUsedSuborn
			and bingo.subornsUsed < 2
		power.AutoButtonColor = power.Active
		local copies = {
			Fichas = { "FICHAS", "Ganhe jogando ou escolha um pacote." },
			Cartelas = { "CARTELAS", "Temas permanentes para levar ao palco." },
			Poderes = { "PODERES", "Uma jogada extra, anunciada para todos." },
			Convites = { "CONVITES", "Seu amigo entra no clube com você." },
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
				then "Studio: use studio.project.json para simular passes."
				elseif
					selectedTab == "Cartelas"
				then "Studio: passe simulado no perfil temporário; nenhum Robux cobrado."
				elseif lastSize.X < 760 then "Studio: compra simulada, sem Robux."
				else "Studio: compra simulada; nenhum Robux cobrado. Progresso não salva.")
			elseif purchaseMode == "disabled" then "Perfil de teste com DataStore: compras simuladas desativadas."
			elseif unavailableOffer then (if lastSize.X < 760
				then "*Robux previsto; venda não ativa."
				else "*Preço previsto; compras indisponíveis até ativar os produtos no Roblox.")
			else (if lastSize.X < 760
				then "Robux confirmado pelo Roblox."
				else "Preço Robux confirmado pelo Roblox. A plataforma confirma cada compra.")
		for name, tab in tabs do
			local selected = name == selectedTab
			tab.BackgroundColor3 = if selected then Theme.Spotlight else Theme.Stage
			tab.TextColor3 = if selected then Theme.Ink else Theme.Paper
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
			row.buy.BackgroundColor3 = if row.buy.Active then Theme.Stage else Theme.Disabled
			row.buy.TextColor3 = if row.buy.Active then Theme.White else Theme.Muted
		end
		for _, theme in Catalog.THEMES do
			local row = entries[theme.id]
			if not row then
				continue
			end
			local owned = ready and reward.ownedThemes[theme.id] == true
			row.fichas.Visible = theme.fichas >= 0 and not owned
			row.fichas.Text = `{theme.fichas} FICHAS`
			row.fichas.Active = ready and fichas >= theme.fichas
			row.fichas.BackgroundColor3 = if row.fichas.Active then Theme.Stage else Theme.Disabled
			row.fichas.TextColor3 = if row.fichas.Active then Theme.White else Theme.Muted
			row.robux.Visible = not owned
			row.robux.Text =
				`{prices[theme.passId] or theme.targetRobux} ROBUX{if prices[theme.passId] then "" else "*"}`
			row.robux.Active = canPurchase
				and (purchaseMode ~= "simulated" or platform.HasSimulatedPass())
				and theme.passId > 0
				and prices[theme.passId] ~= nil
			row.robux.BackgroundColor3 = if row.robux.Active then Theme.Burgundy else Theme.Disabled
			row.robux.TextColor3 = if row.robux.Active then Theme.White else Theme.Muted
			row.equip.Visible = owned
			row.equip.Text = if ready and reward.equippedTheme == theme.id then "EQUIPADO" else "EQUIPAR"
			row.equip.Active = owned and reward.equippedTheme ~= theme.id
			row.detail.Text = if owned
				then "Na sua coleção"
				elseif theme.fichas < 0 then "Exclusivo Robux · permanente"
				else "Jogue para ganhar ou compre"
		end
		powerRow.stock.Text = `NO ESTOQUE: {if ready then reward.suborns else 0}`
		powerRow.fichas.Active = ready and fichas >= Catalog.SUBORN_FICHAS
		powerRow.fichas.BackgroundColor3 = if powerRow.fichas.Active then Theme.Stage else Theme.Disabled
		powerRow.fichas.TextColor3 = if powerRow.fichas.Active then Theme.White else Theme.Muted
		powerRow.robux.Text =
			`{prices[Catalog.SUBORN_PRODUCT_ID] or Catalog.SUBORN_TARGET_ROBUX} ROBUX{if prices[Catalog.SUBORN_PRODUCT_ID]
				then ""
				else "*"}`
		powerRow.robux.Active = canPurchase
			and Catalog.SUBORN_PRODUCT_ID > 0
			and prices[Catalog.SUBORN_PRODUCT_ID] ~= nil
		powerRow.robux.BackgroundColor3 = if powerRow.robux.Active then Theme.Burgundy else Theme.Disabled
		powerRow.robux.TextColor3 = if powerRow.robux.Active then Theme.White else Theme.Muted
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
