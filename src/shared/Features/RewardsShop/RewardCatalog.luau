--!strict
local Catalog = {}

Catalog.DAILY_FICHAS = table.freeze({ 10, 15, 20, 25, 30, 35, 40 })
Catalog.DAILY_THEMES = table.freeze({ "stage_star", "club_seal", "dossier_blue" })
Catalog.MATCH_FICHAS = 5
Catalog.WIN_FICHAS = 2
Catalog.DUPLICATE_FICHAS = 50
Catalog.SUBORN_FICHAS = 650
Catalog.SUBORN_TARGET_ROBUX = 149
Catalog.FICHA_PACKS = table.freeze({
	{
		id = "fichas_120",
		name = "Punhado",
		amount = 120,
		productId = 3720520619,
		targetRobux = 29,
		icon = "rbxassetid://106680168020796",
	},
	{
		id = "fichas_350",
		name = "Pacote",
		amount = 350,
		productId = 3720520624,
		targetRobux = 79,
		icon = "rbxassetid://106755788346393",
	},
	{
		id = "fichas_800",
		name = "Maleta",
		amount = 800,
		productId = 3720520631,
		targetRobux = 169,
		icon = "rbxassetid://88431256137058",
	},
})

-- IDs belong to universe 10772003576 (BINGO Experimental). Keep a separate
-- catalog or replace these IDs when publishing to another universe.
Catalog.SUBORN_PRODUCT_ID = 3720520635
Catalog.SUBORN_ICON = "rbxassetid://105872504074659"
Catalog.THEMES = table.freeze({
	{
		id = "classic",
		name = "Clássico",
		fichas = 0,
		passId = 0,
		targetRobux = 0,
		image = "",
		accent = Color3.fromRGB(35, 59, 104),
		paper = Color3.fromRGB(255, 244, 216),
	},
	{
		id = "dossier_blue",
		name = "Dossiê Azul",
		fichas = 300,
		passId = 2044514400,
		targetRobux = 49,
		image = "rbxassetid://122159259437743",
		accent = Color3.fromRGB(26, 64, 114),
		paper = Color3.fromRGB(247, 239, 217),
	},
	{
		id = "stage_star",
		name = "Estrela de Palco",
		fichas = 700,
		passId = 2045168372,
		targetRobux = 99,
		image = "rbxassetid://122015776508513",
		accent = Color3.fromRGB(125, 48, 72),
		paper = Color3.fromRGB(255, 242, 212),
	},
	{
		id = "club_seal",
		name = "Selo do Clube",
		fichas = 700,
		passId = 2045120362,
		targetRobux = 99,
		image = "rbxassetid://93200620468622",
		accent = Color3.fromRGB(25, 52, 96),
		paper = Color3.fromRGB(255, 249, 231),
	},
	{
		id = "on_air",
		name = "No Ar",
		fichas = -1,
		passId = 2045108372,
		targetRobux = 99,
		image = "rbxassetid://129262034393957",
		accent = Color3.fromRGB(0, 177, 211),
		paper = Color3.fromRGB(234, 248, 250),
	},
	{
		id = "velvet_gala",
		name = "Veludo de Gala",
		fichas = -1,
		passId = 2045330347,
		targetRobux = 149,
		image = "rbxassetid://112707626474228",
		accent = Color3.fromRGB(139, 48, 77),
		paper = Color3.fromRGB(255, 244, 222),
	},
})

function Catalog.FindTheme(id: string): any?
	for _, theme in Catalog.THEMES do
		if theme.id == id then
			return theme
		end
	end
	return nil
end

return table.freeze(Catalog)
