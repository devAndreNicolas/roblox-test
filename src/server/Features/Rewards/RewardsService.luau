--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerData = require(script.Parent.Parent.PlayerData.PlayerDataService)
local Daily = require(script.Parent.DailyRewardsService)
local Referral = require(script.Parent.ReferralService)
local Shop = require(script.Parent.Parent.Shop.ShopService)
local Inventory = require(script.Parent.Parent.Inventory.InventoryService)
local Receipt = require(script.Parent.Parent.Monetization.ReceiptService)
local Service = {}
local started = false
local update: RemoteEvent
local action: RemoteEvent
local connections: {RBXScriptConnection} = {}
local activationHandler: ((Player) -> ())? = nil
local lastAction: {[Player]: number} = {}
local lastRequest: {[Player]: number} = {}

local function snapshot(player: Player, message: string?): {[string]: any}
	local profile = PlayerData.Get(player.UserId)
	if not profile then return {kind = "RewardsSnapshot", ready = false, message = message or "Carregando recompensas..."} end
	return {kind = "RewardsSnapshot", ready = true, demo = PlayerData.IsDemo(player.UserId),
		fichas = profile.fichas, dailyIndex = profile.dailyIndex, dailyCycles = profile.dailyCycles,
		dailyReady = profile.lastDailyDay < math.floor(os.time() / 86400),
		nextDailyAt = (profile.lastDailyDay + 1) * 86400,
		ownedThemes = table.clone(profile.ownedThemes), equippedTheme = profile.equippedTheme,
		suborns = profile.suborns, message = message}
end
function Service.Push(player: Player, message: string?): ()
	if started and player.Parent then update:FireClient(player, snapshot(player, message)) end
end
function Service.SetActivationHandler(handler: (Player) -> ()): () activationHandler = handler end
function Service.HasSuborn(player: Player): boolean
	local profile = PlayerData.Get(player.UserId)
	return profile ~= nil and profile.suborns > 0
end
function Service.CommitSuborn(userId: number, token: string): boolean
	local ok, message = PlayerData.MutateUserId(userId, function(profile: any): (boolean, string)
		if profile.powerOperations[token] == "pending" or profile.powerOperations[token] == "resolved" then
			return false, "Suborno reservado."
		end
		if profile.suborns <= 0 then return false, "Sem Suborno no estoque." end
		profile.suborns -= 1
		profile.powerOperations[token] = "pending"
		return true, "Suborno do MC usado!"
	end)
	local player = Players:GetPlayerByUserId(userId)
	if ok and player then Service.Push(player, message) end
	return ok and (message == "Suborno do MC usado!" or message == "Suborno reservado.")
end
function Service.ResolveSuborn(userId: number, token: string): ()
	PlayerData.MutateUserId(userId, function(profile: any): (boolean, string)
		if profile.powerOperations[token] ~= "pending" then return false, "Suborno já resolvido." end
		profile.powerOperations[token] = "resolved"
		return true, "Suborno resolvido."
	end)
end
function Service.RefundSuborn(userId: number, token: string): ()
	local ok, message = PlayerData.MutateUserId(userId, function(profile: any): (boolean, string)
		if profile.powerOperations[token] ~= "pending" then return false, "Sem reserva para devolver." end
		profile.powerOperations[token] = "refunded"
		profile.suborns += 1
		return true, "Suborno devolvido ao estoque."
	end)
	local player = Players:GetPlayerByUserId(userId)
	if ok and player and message == "Suborno devolvido ao estoque." then Service.Push(player, message) end
end
function Service.CompleteMatch(sessionId: string, matchId: number, participantIds: {number}, winnerId: number?): ()
	local matchKey = `{sessionId}:{matchId}`
	local utcDay = math.floor(os.time() / 86400)
	for _, userId in participantIds do
		task.spawn(function()
			local ok, message, profile = false, "", nil
			for attempt = 1, 4 do
				ok, message, profile = PlayerData.MutateUserId(userId, function(data: any): (boolean, string)
					local changed, summary, first = Daily.ApplyMatch(data, matchKey, winnerId == userId, utcDay)
					if changed and first then Referral.ApplyFirstMatch(data) end
					return changed, summary
				end)
				if ok then break end
				task.wait(attempt)
			end
			if not ok then warn("[Rewards] Match payout pending after retries", userId, matchKey); return end
			local player = Players:GetPlayerByUserId(userId)
			if player then Service.Push(player, message) end
			if profile and profile.referrerUserId and profile.referralPaid and not profile.referralInviterConfirmed then
				local paid = false
				for attempt = 1, 4 do
					paid = Referral.PayInviter(userId, profile.referrerUserId)
					if paid then break end
					task.wait(attempt)
				end
				if paid then
					local inviter = Players:GetPlayerByUserId(profile.referrerUserId)
					if inviter then Service.Push(inviter, "Selo do Clube por convite!") end
				end
			end
		end)
	end
end
function Service.Start(): ()
	if started then return end
	started = true
	local folder = ReplicatedStorage:FindFirstChild("Remotes")
	if not folder then folder = Instance.new("Folder"); folder.Name = "Remotes"; folder.Parent = ReplicatedStorage end
	assert(folder:IsA("Folder"))
	local foundUpdate = folder:FindFirstChild("RewardUpdate") or Instance.new("RemoteEvent")
	foundUpdate.Name = "RewardUpdate"; foundUpdate.Parent = folder
	local foundAction = folder:FindFirstChild("RewardAction") or Instance.new("RemoteEvent")
	foundAction.Name = "RewardAction"; foundAction.Parent = folder
	assert(foundUpdate:IsA("RemoteEvent") and foundAction:IsA("RemoteEvent"))
	update, action = foundUpdate, foundAction
	Receipt.Start(Service.Push)
	table.insert(connections, action.OnServerEvent:Connect(function(player: Player, verb: unknown, itemId: unknown)
		if typeof(verb) ~= "string" then return end
		local now = os.clock()
		if verb == "Request" then
			if lastRequest[player] and now - lastRequest[player] < 0.5 then return end
			lastRequest[player] = now
			task.spawn(function()
				PlayerData.RefreshUserId(player.UserId)
				Service.Push(player)
			end)
			return
		end
		if lastAction[player] and now - lastAction[player] < 0.35 then return end
		lastAction[player] = now
		if verb == "Activate" then
			if activationHandler then activationHandler(player) end
			return
		end
		if typeof(itemId) ~= "string" or #itemId > 40 then return end
		if verb == "BuyFichas" then
			local ok, message = PlayerData.MutateUserId(player.UserId, function(profile: any): (boolean, string)
				return Shop.Buy(profile, itemId)
			end)
			Service.Push(player, if ok then message else "Não foi possível salvar agora.")
		elseif verb == "Equip" then
			local ok, message = PlayerData.MutateUserId(player.UserId, function(profile: any): (boolean, string)
				return Inventory.Equip(profile, itemId)
			end)
			Service.Push(player, if ok then message else "Não foi possível salvar agora.")
		end
	end))
	local function added(player: Player): ()
		task.spawn(function()
			if not PlayerData.Load(player) then Service.Push(player, "Perfil indisponível."); return end
			Service.Push(player)
			local profile = PlayerData.Get(player.UserId)
			if profile then
				for token, state in profile.powerOperations do
					if state == "pending" then Service.RefundSuborn(player.UserId, token) end
				end
			end
			Referral.RecordJoin(player)
			task.delay(3, function()
				if player.Parent then Referral.RecordJoin(player) end
			end)
			Referral.RetryPending(player.UserId)
			Receipt.ReconcilePasses(player, Service.Push)
			Service.Push(player)
		end)
	end
	table.insert(connections, Players.PlayerAdded:Connect(added))
	table.insert(connections, Players.PlayerRemoving:Connect(function(player: Player)
		lastAction[player] = nil
		lastRequest[player] = nil
		PlayerData.Forget(player)
	end))
	for _, player in Players:GetPlayers() do added(player) end
end
return Service
