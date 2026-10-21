--!strict
local Catalog = require(game:GetService("ReplicatedStorage").Shared.Features.RewardsShop.RewardCatalog)
local Economy = require(script.Parent.Parent.Economy.EconomyService)
local Service = {}
function Service.Buy(profile: any, itemId: string): (boolean, string)
	if itemId == "suborn" then
		if not Economy.TrySpend(profile, Catalog.SUBORN_FICHAS) then return false, "Fichas insuficientes." end
		profile.suborns += 1
		return true, "Suborno do MC adicionado ao estoque."
	end
	local theme = Catalog.FindTheme(itemId)
	if not theme or theme.id == "classic" or theme.fichas < 0 then return false, "Item indisponível por Fichas." end
	if profile.ownedThemes[itemId] then return false, "Você já possui esse tema." end
	if not Economy.TrySpend(profile, theme.fichas) then return false, "Fichas insuficientes." end
	profile.ownedThemes[itemId] = true
	return true, `Comprou {theme.name}!`
end
return Service
