--!strict
local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
local store = if RunService:IsStudio() then nil else DataStoreService:GetDataStore("BingoNoirPlayer_v1")
local Adapter = {}

function Adapter.Read(userId: number): (boolean, any)
	if not store then
		return false, "Use studio.project.json para testar no Studio."
	end
	return pcall(function()
		return store:GetAsync(`Player_{userId}`)
	end)
end

function Adapter.Update(userId: number, transform: (any) -> any): (boolean, any)
	if not store then
		return false, "Use studio.project.json para testar no Studio."
	end
	return pcall(function()
		return store:UpdateAsync(`Player_{userId}`, transform)
	end)
end

function Adapter.IsTemporary(_userId: number): boolean
	return false
end
function Adapter.PurchaseMode(_userId: number): string
	return "real"
end
function Adapter.CanGrantReceipt(_userId: number): boolean
	return true
end
function Adapter.ShouldReconcilePasses(): boolean
	return true
end
function Adapter.Forget(_userId: number): () end

return Adapter
