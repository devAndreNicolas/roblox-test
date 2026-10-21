--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Override = {}

function Override.new(onChanged: () -> ())
	local function passRemote(): RemoteEvent?
		local folder = ReplicatedStorage:FindFirstChild("Remotes")
		local candidate = folder and folder:FindFirstChild("PassPurchaseAdapter")
		return if candidate and candidate:IsA("RemoteEvent") then candidate else nil
	end
	local connection = ReplicatedStorage.DescendantAdded:Connect(function(child: Instance)
		if child.Name == "PassPurchaseAdapter" and child:IsA("RemoteEvent") then onChanged() end
	end)
	local adapter = {}
	function adapter.HasPass(): boolean
		return passRemote() ~= nil
	end
	function adapter.PromptPass(themeId: string): boolean
		local remote = passRemote()
		if not remote then return false end
		remote:FireServer(themeId)
		return true
	end
	function adapter.Destroy(): ()
		connection:Disconnect()
	end
	return adapter
end

return Override
