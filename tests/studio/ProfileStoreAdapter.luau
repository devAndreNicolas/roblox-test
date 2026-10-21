--!strict
-- Mounted by studio.project.json only. Keeps mock purchases out of saved data.
local RunService = game:GetService("RunService")
assert(RunService:IsStudio(), "ProfileStoreAdapter must never run outside Studio")
local DataStoreService = game:GetService("DataStoreService")
local store = DataStoreService:GetDataStore("BingoNoirPlayer_Studio_v1")
local Adapter = {}
local temporary: { [number]: boolean } = {}
local memory: { [number]: any } = {}

function Adapter.Read(userId: number): (boolean, any)
	if temporary[userId] then
		return true, memory[userId]
	end
	local ok, raw = pcall(function()
		return store:GetAsync(`Player_{userId}`)
	end)
	if ok then
		return true, raw
	end
	temporary[userId] = true
	memory[userId] = memory[userId] or {}
	return true, memory[userId]
end

function Adapter.Update(userId: number, transform: (any) -> any): (boolean, any)
	if temporary[userId] then
		return pcall(function()
			local nextProfile = transform(memory[userId])
			memory[userId] = nextProfile
			return nextProfile
		end)
	end
	return pcall(function()
		return store:UpdateAsync(`Player_{userId}`, transform)
	end)
end

function Adapter.IsTemporary(userId: number): boolean
	return temporary[userId] == true
end
function Adapter.PurchaseMode(userId: number): string
	return if temporary[userId] then "simulated" else "disabled"
end
function Adapter.CanGrantReceipt(userId: number): boolean
	return temporary[userId] == true
end
function Adapter.ShouldReconcilePasses(): boolean
	return false
end
function Adapter.Forget(_userId: number): () end

return Adapter
