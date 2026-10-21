--!strict
local Catalog = require(game:GetService("ReplicatedStorage").Shared.Features.RewardsShop.RewardCatalog)
local Economy = require(script.Parent.Parent.Economy.EconomyService)
local Service = {}
function Service.Buy(profile: any, itemId: string): (boolean, string)
	if itemId == "suborn" then
		if not Economy.TrySpend(profile, Catalog.SUBORN_FICHAS) then
			return false, "Not enough Tickets."
		end
		profile.suborns += 1
		return true, "MC Bribe added to your inventory."
	end
	local theme = Catalog.FindTheme(itemId)
	if not theme or theme.id == "classic" or theme.fichas < 0 then
		return false, "Item unavailable for Tickets."
	end
	if profile.ownedThemes[itemId] then
		return false, "You already own this theme."
	end
	if not Economy.TrySpend(profile, theme.fichas) then
		return false, "Not enough Tickets."
	end
	profile.ownedThemes[itemId] = true
	profile.equippedTheme = itemId
	return true, `Bought and equipped {theme.name}!`
end
return Service
