--!strict
local Catalog = require(game:GetService("ReplicatedStorage").Shared.Features.RewardsShop.RewardCatalog)
local Economy = require(script.Parent.Parent.Economy.EconomyService)
local Service = {}
function Service.GrantTheme(profile: any, themeId: string): boolean
	if profile.ownedThemes[themeId] then
		Economy.Credit(profile, Catalog.DUPLICATE_FICHAS)
		return false
	end
	profile.ownedThemes[themeId] = true
	return true
end
function Service.Equip(profile: any, themeId: string): (boolean, string)
	if not Catalog.FindTheme(themeId) or not profile.ownedThemes[themeId] then
		return false, "Tema não disponível na coleção."
	end
	profile.equippedTheme = themeId
	return true, "Tema equipado!"
end
return Service
