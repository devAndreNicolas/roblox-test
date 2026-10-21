--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Features.Bingo.BingoConfig)
local Types = require(ReplicatedStorage.Shared.Features.Bingo.BingoTypes)
type Handlers = {
	mark: (Player, number, number) -> (),
	skip: (Player, number) -> (),
	snapshot: (Player) -> (),
}
local Transport = {}
export type Connection = {
	Send: (Player, Types.Snapshot) -> (),
	RemovePlayer: (Player) -> (),
	Destroy: () -> (),
}
local function finiteInteger(value: unknown): boolean
	return typeof(value) == "number" and value == value and math.abs(value) < math.huge and value % 1 == 0
end
function Transport.new(handlers: Handlers): Connection
	local folder = ReplicatedStorage:FindFirstChild("Remotes")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "Remotes"
		folder.Parent = ReplicatedStorage
	end
	assert(folder:IsA("Folder"), "Remotes must be a Folder")
	local remotes: { [string]: RemoteEvent } = {}
	for _, name in { "RoundUpdate", "MarkCell", "RequestSnapshot", "SkipScene" } do
		local remote = folder:FindFirstChild(name)
		if not remote then
			remote = Instance.new("RemoteEvent")
			remote.Name = name
			remote.Parent = folder
		end
		assert(remote:IsA("RemoteEvent"), name .. " must be a RemoteEvent")
		remotes[name] = remote
	end
	local limits: { [Player]: { [string]: number } } = {}
	local connections: { RBXScriptConnection } = {}
	local alive = true
	local function allow(player: Player, action: string, interval: number): boolean
		local times = limits[player] or {}
		limits[player] = times
		local now = os.clock()
		if times[action] and now - times[action] < interval then
			return false
		end
		times[action] = now
		return alive
	end
	table.insert(
		connections,
		remotes.MarkCell.OnServerEvent:Connect(function(player, matchId, cell)
			if not allow(player, "mark", Config.MARK_REQUEST_INTERVAL_SECONDS) then
				return
			end
			if not finiteInteger(matchId) or not finiteInteger(cell) then
				return
			end
			if cell < 1 or cell > 25 then
				return
			end
			handlers.mark(player, matchId, cell)
		end)
	)
	table.insert(
		connections,
		remotes.SkipScene.OnServerEvent:Connect(function(player, matchId)
			if allow(player, "skip", 0.2) and finiteInteger(matchId) then
				handlers.skip(player, matchId)
			end
		end)
	)
	table.insert(
		connections,
		remotes.RequestSnapshot.OnServerEvent:Connect(function(player)
			if allow(player, "snapshot", 0.5) then
				handlers.snapshot(player)
			end
		end)
	)
	local transport = {}
	function transport.Send(player: Player, snapshot: Types.Snapshot): ()
		if alive and player.Parent then
			remotes.RoundUpdate:FireClient(player, snapshot)
		end
	end
	function transport.RemovePlayer(player: Player): ()
		limits[player] = nil
	end
	function transport.Destroy(): ()
		alive = false
		for _, connection in connections do
			connection:Disconnect()
		end
		table.clear(connections)
		table.clear(limits)
	end
	return transport
end
return Transport
