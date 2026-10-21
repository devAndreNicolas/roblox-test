--!strict
local PlayerData = require(script.Parent.Parent.PlayerData.PlayerDataService)
local Inventory = require(script.Parent.Parent.Inventory.InventoryService)
local Service = {}

function Service.RecordJoin(player: Player): ()
	local ok, joinData = pcall(function() return player:GetJoinData() end)
	if not ok or typeof(joinData) ~= "table" then return end
	local referrer = joinData.ReferredByPlayerId
	if typeof(referrer) ~= "number" or referrer <= 0 or referrer == player.UserId or referrer % 1 ~= 0 then return end
	PlayerData.MutateUserId(player.UserId, function(profile: any): (boolean, string)
		if profile.completedMatches > 0 or profile.referrerUserId then return false, "Convite já registrado ou conta existente." end
		profile.referrerUserId = referrer
		return true, "Convite registrado. Conclua sua primeira partida."
	end)
end

function Service.ApplyFirstMatch(profile: any): ()
	if not profile.referrerUserId or profile.referralPaid then return end
	Inventory.GrantTheme(profile, "club_seal")
	profile.referralPaid = true
end

function Service.PayInviter(inviteeUserId: number, referrerUserId: number): boolean
	if inviteeUserId == referrerUserId then return false end
	local marker = tostring(inviteeUserId)
	local ok = PlayerData.MutateUserId(referrerUserId, function(profile: any): (boolean, string)
		if profile.referralRewards[marker] then return false, "Convite já recompensado." end
		profile.referralRewards[marker] = true
		Inventory.GrantTheme(profile, "club_seal")
		return true, "Selo do Clube recebido por convite!"
	end)
	if not ok then return false end
	PlayerData.MutateUserId(inviteeUserId, function(profile: any): (boolean, string)
		if profile.referralInviterConfirmed then return false, "Convite já concluído." end
		profile.referralInviterConfirmed = true
		return true, "Convite concluído."
	end)
	return true
end

function Service.RetryPending(userId: number): ()
	local profile = PlayerData.Get(userId)
	if profile and profile.referrerUserId and profile.referralPaid and not profile.referralInviterConfirmed then
		Service.PayInviter(userId, profile.referrerUserId)
	end
end
return Service
