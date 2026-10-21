--!strict
local Catalog = require(game:GetService("ReplicatedStorage").Shared.Features.RewardsShop.RewardCatalog)
local Economy = require(script.Parent.Parent.Economy.EconomyService)
local Inventory = require(script.Parent.Parent.Inventory.InventoryService)
local Service = {}
function Service.ApplyMatch(profile: any, matchKey: string, won: boolean, utcDay: number): (boolean, string, boolean)
	if profile.processedMatches[matchKey] then
		return false, "Recompensa já recebida.", false
	end
	profile.processedMatches[matchKey] = true
	profile.completedMatches += 1
	local base = Catalog.MATCH_FICHAS + (if won then Catalog.WIN_FICHAS else 0)
	Economy.Credit(profile, base)
	local summary = `+{base} Fichas pela partida`
	if profile.lastDailyDay >= utcDay then
		return true, summary, profile.completedMatches == 1
	end
	profile.lastDailyDay = utcDay
	local index = profile.dailyIndex + 1
	Economy.Credit(profile, Catalog.DAILY_FICHAS[index])
	profile.dailyIndex = index % #Catalog.DAILY_FICHAS
	summary = `+{base + Catalog.DAILY_FICHAS[index]} Fichas (partida e marco diário {index})`
	if index == #Catalog.DAILY_FICHAS then
		local themeId = Catalog.DAILY_THEMES[(profile.dailyCycles % #Catalog.DAILY_THEMES) + 1]
		profile.dailyCycles += 1
		local granted = Inventory.GrantTheme(profile, themeId)
		local theme = Catalog.FindTheme(themeId)
		summary ..= if granted then ` + {theme.name}` else ` + {Catalog.DUPLICATE_FICHAS} Fichas por tema repetido`
	end
	return true, summary, profile.completedMatches == 1
end
return Service
