--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Features.Bingo.BingoTypes)
local Client = {}
function Client.new(callback: (Types.Snapshot) -> ())
	local connection: RBXScriptConnection? = nil
	local folder: Folder? = nil
	local function discover(): ()
		if connection then
			return
		end
		local found = ReplicatedStorage:FindFirstChild("Remotes")
		if not found or not found:IsA("Folder") then
			return
		end
		local update = found:FindFirstChild("RoundUpdate")
		if not update or not update:IsA("RemoteEvent") then
			return
		end
		folder = found
		connection = update.OnClientEvent:Connect(function(payload: unknown)
			if typeof(payload) ~= "table" then
				return
			end
			local data = payload :: any
			if
				data.kind ~= "Snapshot"
				or typeof(data.sessionId) ~= "string"
				or typeof(data.matchId) ~= "number"
				or typeof(data.phase) ~= "string"
				or typeof(data.calledNumbers) ~= "table"
				or typeof(data.timeRemaining) ~= "number"
				or typeof(data.callIntervalSeconds) ~= "number"
			then
				return
			end
			callback(data :: Types.Snapshot)
		end)
	end
	local function fire(name: string, ...: any): ()
		local remote = folder and folder:FindFirstChild(name)
		if remote and remote:IsA("RemoteEvent") then
			remote:FireServer(...)
		end
	end
	local client = {}
	function client.RequestSnapshot(): ()
		discover()
		fire("RequestSnapshot")
	end
	function client.MarkCell(matchId: number, index: number): ()
		fire("MarkCell", matchId, index)
	end
	function client.SkipIntro(matchId: number): ()
		fire("SkipScene", matchId)
	end
	function client.Destroy(): ()
		if connection then
			connection:Disconnect()
			connection = nil
		end
		folder = nil
	end
	return client
end
return Client
