--!strict
-- Only loaded in Studio. Simulates pass acquisition for the temporary profile
-- because the creator account already owns its passes on the platform.
local RunService = game:GetService("RunService")
local Catalog = require(game:GetService("ReplicatedStorage").Shared.Features.RewardsShop.RewardCatalog)
local PlayerData = require(script.Parent.Parent.PlayerData.PlayerDataService)

local Simulator = {}

function Simulator.PurchasePass(player: Player, themeId: string): (boolean, string)
	if not RunService:IsStudio() or not PlayerData.IsDemo(player.UserId) then
		return false, "Simulação indisponível."
	end
	local theme = Catalog.FindTheme(themeId)
	if not theme or theme.passId <= 0 then
		return false, "Passe indisponível."
	end
	local ok, message = PlayerData.MutateUserId(player.UserId, function(profile: any): (boolean, string)
		if profile.ownedThemes[themeId] then return false, "Você já possui esse tema." end
		profile.ownedThemes[themeId] = true
		return true, `Compra simulada: {theme.name}!`
	end)
	return ok, message
end

return Simulator
