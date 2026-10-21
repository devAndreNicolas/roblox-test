--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local SocialService = game:GetService("SocialService")
local ContentProvider = game:GetService("ContentProvider")
local Catalog = require(ReplicatedStorage.Shared.Features.RewardsShop.RewardCatalog)

local Adapter = {}

function Adapter.new(onSnapshot: (any) -> (), onChanged: () -> ())
	local player = Players.LocalPlayer
	local prices: {[number]: number} = {}
	local remote: RemoteEvent? = nil
	local rewardConnection: RBXScriptConnection? = nil
	local alive = true
	local overrideModule = script.Parent.Parent.Parent.Parent:FindFirstChild("ShopPurchaseOverride")
	local purchaseOverride = if overrideModule and overrideModule:IsA("ModuleScript")
		then require(overrideModule).new(onChanged) else nil

	local function fetchPrice(productId: number, kind: Enum.InfoType): ()
		if productId <= 0 then return end
		task.spawn(function()
			local ok, info = pcall(function() return MarketplaceService:GetProductInfoAsync(productId, kind) end)
			if ok and info and typeof(info.PriceInRobux) == "number" and alive then
				prices[productId] = info.PriceInRobux
				onChanged()
			end
		end)
	end

	local result = {Prices = prices}

	function result.Discover(): ()
		if remote then return end
		local folder = ReplicatedStorage:FindFirstChild("Remotes")
		local action = folder and folder:FindFirstChild("RewardAction")
		local update = folder and folder:FindFirstChild("RewardUpdate")
		if not action or not action:IsA("RemoteEvent") or not update or not update:IsA("RemoteEvent") then return end
		remote = action
		rewardConnection = update.OnClientEvent:Connect(function(payload: any)
			if alive and typeof(payload) == "table" and payload.kind == "RewardsSnapshot" then onSnapshot(payload) end
		end)
	end

	function result.Fire(verb: string, itemId: string?): ()
		if remote then remote:FireServer(verb, itemId) end
	end

	function result.HasSimulatedPass(): boolean
		return purchaseOverride ~= nil and purchaseOverride.HasPass()
	end

	function result.PromptProduct(productId: number, reward: any): string?
		if not reward or not reward.ready then return "Please wait for your profile to load." end
		if reward.purchaseMode ~= "real" and reward.purchaseMode ~= "simulated" then return "Purchases are disabled for this profile." end
		if productId <= 0 then return "Robux purchase is being prepared." end
		if not prices[productId] then return "Price unavailable. Please try again later." end
		local ok = pcall(function() MarketplaceService:PromptProductPurchase(player, productId) end)
		return if ok then nil else "Could not open the purchase right now."
	end

	function result.PromptPass(theme: any, reward: any): string?
		if not reward or not reward.ready then return "Please wait for your profile to load." end
		if reward.purchaseMode ~= "real" and reward.purchaseMode ~= "simulated" then return "Purchases are disabled for this profile." end
		if theme.passId <= 0 then return "Robux purchase is being prepared." end
		if reward.ownedThemes[theme.id] then return "You already own this theme." end
		if not prices[theme.passId] then return "Price unavailable. Please try again later." end
		if reward.purchaseMode == "simulated" then
			if purchaseOverride and purchaseOverride.PromptPass(theme.id) then return nil end
			return "Use studio.project.json para simular passes."
		end
		local ok = pcall(function() MarketplaceService:PromptGamePassPurchase(player, theme.passId) end)
		return if ok then nil else "Could not open the purchase right now."
	end

	function result.Invite(onError: (string) -> ()): ()
		task.spawn(function()
			local ok, canInvite = pcall(function() return SocialService:CanSendGameInviteAsync(player) end)
			if not alive then return end
			if not ok or not canInvite then onError("Invites are unavailable on this device."); return end
			local prompted = pcall(function() SocialService:PromptGameInvite(player) end)
			if not prompted and alive then onError("Could not open the invite right now.") end
		end)
	end

	function result.Start(art: {ImageLabel}): ()
		for _, pack in Catalog.FICHA_PACKS do fetchPrice(pack.productId, Enum.InfoType.Product) end
		for _, theme in Catalog.THEMES do fetchPrice(theme.passId, Enum.InfoType.GamePass) end
		fetchPrice(Catalog.SUBORN_PRODUCT_ID, Enum.InfoType.Product)
		task.spawn(function()
			pcall(function() ContentProvider:PreloadAsync(art) end)
			if alive then onChanged() end
		end)
	end

	function result.Destroy(): ()
		alive = false
		if rewardConnection then rewardConnection:Disconnect() end
		if purchaseOverride then purchaseOverride.Destroy() end
	end

	return result
end

return Adapter
