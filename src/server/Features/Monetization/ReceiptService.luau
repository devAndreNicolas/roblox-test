--!strict
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Catalog = require(game:GetService("ReplicatedStorage").Shared.Features.RewardsShop.RewardCatalog)
local PlayerData = require(script.Parent.Parent.PlayerData.PlayerDataService)
local Economy = require(script.Parent.Parent.Economy.EconomyService)
local Service = {}
local started = false

function Service.Start(push: (Player, string?) -> ()): ()
	if started then return end
	started = true
	MarketplaceService.ProcessReceipt = function(receiptInfo: any): Enum.ProductPurchaseDecision
		if typeof(receiptInfo.PurchaseId) ~= "string" or typeof(receiptInfo.PlayerId) ~= "number"
			or typeof(receiptInfo.ProductId) ~= "number" then
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
		-- Studio simulates purchases. Keep those grants in memory so mock receipts
		-- never become durable ownership in the separate Studio DataStore.
		if RunService:IsStudio() and not PlayerData.IsDemo(receiptInfo.PlayerId) then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
		local ok, message = PlayerData.MutateUserId(receiptInfo.PlayerId, function(profile: any): (boolean, string)
			if profile.processedPurchases[receiptInfo.PurchaseId] then return false, "Compra já concedida." end
			profile.processedPurchases[receiptInfo.PurchaseId] = true
			if isSuborn then
				profile.suborns += 1
				return true, "Suborno do MC adicionado ao estoque."
			end
			Economy.Credit(profile, pack.amount)
			return true, `+{pack.amount} Fichas recebidas!`
		end)
		if not ok then return Enum.ProductPurchaseDecision.NotProcessedYet end
		local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
		if player then push(player, message) end
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player: Player, passId: number, wasPurchased: boolean)
		if not wasPurchased then return end
		for _, theme in Catalog.THEMES do
			if theme.passId > 0 and theme.passId == passId then
				local verified, owns = true, false
				if RunService:IsStudio() and PlayerData.IsDemo(player.UserId) then
					owns = true
				else
					verified, owns = pcall(function() return MarketplaceService:UserOwnsGamePassAsync(player.UserId, passId) end)
				end
				if verified and owns then
					local saved, message = PlayerData.MutateUserId(player.UserId, function(profile: any): (boolean, string)
						if profile.ownedThemes[theme.id] then return false, "Tema já recebido." end
						profile.ownedThemes[theme.id] = true
						return true, `Comprou {theme.name}!`
					end)
					if saved then push(player, message) end
				end
				break
			end
		end
	end)
end

function Service.ReconcilePasses(player: Player, push: (Player, string?) -> ()): ()
	-- Studio ownership checks can report the creator's passes as owned. Only a
	-- simulated purchase prompt should grant a pass during Studio playtests.
	if RunService:IsStudio() then return end
	for _, theme in Catalog.THEMES do
		if theme.passId <= 0 then continue end
		local ok, owns = pcall(function() return MarketplaceService:UserOwnsGamePassAsync(player.UserId, theme.passId) end)
		if ok and owns then
			local saved, message = PlayerData.MutateUserId(player.UserId, function(profile: any): (boolean, string)
				if profile.ownedThemes[theme.id] then return false, "Tema já recebido." end
				profile.ownedThemes[theme.id] = true
				return true, `Tema {theme.name} restaurado.`
			end)
			if saved and message ~= "Tema já recebido." then push(player, message) end
		end
	end
end
return Service
