--!strict
-- Mounted only by studio.project.json; absent from the production project.
local RunService = game:GetService("RunService")
assert(RunService:IsStudio(), "StudioPassPurchase must never run outside Studio")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Catalog = require(ReplicatedStorage.Shared.Features.RewardsShop.RewardCatalog)
local Server = ServerScriptService:WaitForChild("Server")
local PlayerData = require(Server.Features.PlayerData.PlayerDataService)
local Rewards = require(Server.Features.Rewards.RewardsService)

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local remote = Instance.new("RemoteEvent")
remote.Name = "PassPurchaseAdapter"
remote.Parent = remotes

remote.OnServerEvent:Connect(function(player: Player, themeId: unknown)
	if not PlayerData.IsTemporary(player.UserId) or typeof(themeId) ~= "string" then
		return
	end
	local theme = Catalog.FindTheme(themeId)
	if not theme or theme.passId <= 0 then
		return
	end
	local ok, message = PlayerData.MutateUserId(player.UserId, function(profile: any): (boolean, string)
		if profile.ownedThemes[themeId] then
			return false, "Você já possui esse tema."
		end
		profile.ownedThemes[themeId] = true
		profile.equippedTheme = themeId
		return true, `Compra simulada: {theme.name} equipado!`
	end)
	if ok then
		Rewards.Push(player, message)
	end
end)
