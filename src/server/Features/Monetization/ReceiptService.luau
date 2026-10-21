--!strict
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local Catalog = require(game:GetService("ReplicatedStorage").Shared.Features.RewardsShop.RewardCatalog)
local PlayerData = require(script.Parent.Parent.PlayerData.PlayerDataService)
local Economy = require(script.Parent.Parent.Economy.EconomyService)
local Service = {}
local started = false

function Service.Start(push: (Player, string?) -> ()): ()
	if started then
		return
	end
	started = true
	MarketplaceService.ProcessReceipt = function(receiptInfo: any): Enum.ProductPurchaseDecision
		if
			typeof(receiptInfo.PurchaseId) ~= "string"
			or typeof(receiptInfo.PlayerId) ~= "number"
			or typeof(receiptInfo.ProductId) ~= "number"
		then
			warn("[Receipt] Unknown product", receiptInfo.ProductId)
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
		local isSuborn = Catalog.SUBORN_PRODUCT_ID > 0 and receiptInfo.ProductId == Catalog.SUBORN_PRODUCT_ID
		local pack: any = nil
		for _, offer in Catalog.FICHA_PACKS do
			if offer.productId > 0 and offer.productId == receiptInfo.ProductId then
				if pack or isSuborn then
					warn("[Receipt] Duplicate product configuration", receiptInfo.ProductId)
					return Enum.ProductPurchaseDecision.NotProcessedYet
				end
				pack = offer
			end
		end
		if not isSuborn and not pack then
			warn("[Receipt] Unknown product", receiptInfo.ProductId)
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
		if not PlayerData.CanGrantReceipt(receiptInfo.PlayerId) then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
		local ok, message = PlayerData.MutateUserId(receiptInfo.PlayerId, function(profile: any): (boolean, string)
			if profile.processedPurchases[receiptInfo.PurchaseId] then
				return false, "Purchase already granted."
			end
			profile.processedPurchases[receiptInfo.PurchaseId] = true
			if isSuborn then
				profile.suborns += 1
				return true, "MC Bribe added to your inventory."
			end
			Economy.Credit(profile, pack.amount)
			return true, `+{pack.amount} Tickets received!`
		end)
		if not ok then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
		local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
		if player then
			push(player, message)
		end
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(
		function(player: Player, passId: number, wasPurchased: boolean)
			if not wasPurchased then
				return
			end
			for _, theme in Catalog.THEMES do
				if theme.passId > 0 and theme.passId == passId then
					local verified, owns = pcall(function()
						return MarketplaceService:UserOwnsGamePassAsync(player.UserId, passId)
					end)
					if verified and owns then
						local saved, message = PlayerData.MutateUserId(
							player.UserId,
							function(profile: any): (boolean, string)
								if profile.ownedThemes[theme.id] then
									return false, "Theme already received."
								end
								profile.ownedThemes[theme.id] = true
								profile.equippedTheme = theme.id
								return true, `Bought and equipped {theme.name}!`
							end
						)
						if saved then
							push(player, message)
						end
					end
					break
				end
			end
		end
	)
end

function Service.ReconcilePasses(player: Player, push: (Player, string?) -> ()): ()
	if not PlayerData.ShouldReconcilePasses() then
		return
	end
	for _, theme in Catalog.THEMES do
		if theme.passId <= 0 then
			continue
		end
		local ok, owns = pcall(function()
			return MarketplaceService:UserOwnsGamePassAsync(player.UserId, theme.passId)
		end)
		if ok and owns then
			local saved, message = PlayerData.MutateUserId(player.UserId, function(profile: any): (boolean, string)
				if profile.ownedThemes[theme.id] then
					return false, "Theme already received."
				end
				profile.ownedThemes[theme.id] = true
				return true, `Theme {theme.name} restored.`
			end)
			if saved and message ~= "Theme already received." then
				push(player, message)
			end
		end
	end
end
return Service
