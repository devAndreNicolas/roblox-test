--!strict
local PlayerData = require(script.Parent.Parent.PlayerData.PlayerDataService)
local Inventory = require(script.Parent.Parent.Inventory.InventoryService)
local Service = {}

function Service.RecordJoin(player: Player): ()
	local ok, joinData = pcall(function()
		return player:GetJoinData()
	end)
	if not ok or typeof(joinData) ~= "table" then
		return
	end
	local referrer = joinData.ReferredByPlayerId
	if typeof(referrer) ~= "number" or referrer <= 0 or referrer == player.UserId or referrer % 1 ~= 0 then
		return
	end
	PlayerData.MutateUserId(player.UserId, function(profile: any): (boolean, string)
		if profile.completedMatches > 0 or profile.referrerUserId then
			return false, "Invite already registered or account already exists."
		end
		profile.referrerUserId = referrer
		return true, "Invite registered. Finish your first match."
	end)
end

function Service.ApplyFirstMatch(profile: any): ()
	if not profile.referrerUserId or profile.referralPaid then
		return
	end
	Inventory.GrantTheme(profile, "club_seal")
	profile.referralPaid = true
end

function Service.PayInviter(inviteeUserId: number, referrerUserId: number): boolean
	if inviteeUserId == referrerUserId then
		return false
	end
	local marker = tostring(inviteeUserId)
	local ok = PlayerData.MutateUserId(referrerUserId, function(profile: any): (boolean, string)
		if profile.referralRewards[marker] then
			return false, "Invite reward already granted."
		end
		profile.referralRewards[marker] = true
		Inventory.GrantTheme(profile, "club_seal")
		return true, "Club Seal received from an invite!"
	end)
	if not ok then
		return false
	end
	PlayerData.MutateUserId(inviteeUserId, function(profile: any): (boolean, string)
		if profile.referralInviterConfirmed then
			return false, "Invite already completed."
		end
		profile.referralInviterConfirmed = true
		return true, "Invite completed."
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
