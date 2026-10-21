--!strict
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Studio uses a separate namespace, so playtests never mutate published player profiles.
local store = DataStoreService:GetDataStore(if RunService:IsStudio() then "BingoNoirPlayer_Studio_v1" else "BingoNoirPlayer_v1")
local Service = {}
export type Profile = {
	schemaVersion: number, revision: number, fichas: number,
	dailyIndex: number, dailyCycles: number, lastDailyDay: number, completedMatches: number,
	ownedThemes: {[string]: boolean}, equippedTheme: string, suborns: number,
	processedMatches: {[string]: boolean}, processedPurchases: {[string]: boolean},
	powerOperations: {[string]: string},
	referrerUserId: number?, referralPaid: boolean, referralInviterConfirmed: boolean, referralRewards: {[string]: boolean},
}
type Mutation = (Profile) -> (boolean, string)
local cached: {[number]: Profile} = {}
local demo: {[number]: Profile} = {}
local demoUsers: {[number]: boolean} = {}
local unavailable: {[number]: boolean} = {}

local function default(): Profile
	return {schemaVersion = 1, revision = 0, fichas = 0, dailyIndex = 0, dailyCycles = 0,
		lastDailyDay = -1, completedMatches = 0, ownedThemes = {classic = true}, equippedTheme = "classic", suborns = 0,
		processedMatches = {}, processedPurchases = {}, powerOperations = {}, referrerUserId = nil,
		referralPaid = false, referralInviterConfirmed = false, referralRewards = {}}
end
local function normalize(raw: any): Profile
	if typeof(raw) ~= "table" then return default() end
	local data = raw :: any
	local fresh = default()
	for key, value in fresh do
		if data[key] == nil then data[key] = value end
	end
	if typeof(data.ownedThemes) ~= "table" then data.ownedThemes = {classic = true} end
	if typeof(data.processedMatches) ~= "table" then data.processedMatches = {} end
	if typeof(data.processedPurchases) ~= "table" then data.processedPurchases = {} end
	if typeof(data.powerOperations) ~= "table" then data.powerOperations = {} end
	if typeof(data.referralRewards) ~= "table" then data.referralRewards = {} end
	if typeof(data.fichas) ~= "number" or data.fichas < 0 then data.fichas = 0 end
	if typeof(data.suborns) ~= "number" or data.suborns < 0 then data.suborns = 0 end
	if typeof(data.revision) ~= "number" then data.revision = 0 end
	if typeof(data.dailyIndex) ~= "number" or data.dailyIndex < 0 or data.dailyIndex > 6 then data.dailyIndex = 0 end
	if typeof(data.dailyCycles) ~= "number" or data.dailyCycles < 0 then data.dailyCycles = 0 end
	if typeof(data.lastDailyDay) ~= "number" then data.lastDailyDay = -1 end
	if typeof(data.completedMatches) ~= "number" or data.completedMatches < 0 then data.completedMatches = 0 end
	data.schemaVersion = 1
	return data :: Profile
end
local function key(userId: number): string return `Player_{userId}` end
local function applyCache(userId: number, profile: Profile): ()
	local old = cached[userId]
	if not old or profile.revision >= old.revision then cached[userId] = profile end
end
function Service.Load(player: Player): boolean
	local userId = player.UserId
	local ok, raw = pcall(function() return store:GetAsync(key(userId)) end)
	if ok then
		unavailable[userId] = nil
		applyCache(userId, normalize(raw))
		return true
	end
	warn("[PlayerData] Load failed", userId, raw)
	if RunService:IsStudio() then
		demoUsers[userId] = true
		demo[userId] = demo[userId] or default()
		applyCache(userId, demo[userId])
		return true
	end
	unavailable[userId] = true
	return false
end
function Service.Get(userId: number): Profile?
	return cached[userId]
end
function Service.RefreshUserId(userId: number): boolean
	if demoUsers[userId] or demo[userId] then return true end
	local ok, raw = pcall(function() return store:GetAsync(key(userId)) end)
	if not ok then return false end
	unavailable[userId] = nil
	applyCache(userId, normalize(raw))
	return true
end
function Service.IsDemo(userId: number): boolean return demoUsers[userId] == true end
function Service.IsAvailable(userId: number): boolean return cached[userId] ~= nil and not unavailable[userId] end
function Service.MutateUserId(userId: number, mutation: Mutation): (boolean, string, Profile?)
	if unavailable[userId] then return false, "Perfil indisponível. Tente novamente.", nil end
	if demoUsers[userId] or demo[userId] then
		local profile = demo[userId] or default()
		local changed, message = mutation(profile)
		if changed then profile.revision += 1 end
		demo[userId] = profile
		applyCache(userId, profile)
		return true, message, profile
	end
	local message = "OK"
	local ok, result = pcall(function()
		return store:UpdateAsync(key(userId), function(raw: any)
			local profile = normalize(raw)
			local changed, nextMessage = mutation(profile)
			message = nextMessage
			if changed then profile.revision += 1 end
			return profile
		end)
	end)
	if not ok or typeof(result) ~= "table" then
		warn("[PlayerData] Mutation failed", userId, result)
		return false, "Não foi possível salvar agora. Tente novamente.", nil
	end
	local profile = normalize(result)
	applyCache(userId, profile)
	return true, message, profile
end
function Service.Forget(player: Player): ()
	cached[player.UserId] = nil
	unavailable[player.UserId] = nil
	demoUsers[player.UserId] = nil
end
return Service
