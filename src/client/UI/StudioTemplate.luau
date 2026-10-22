--!strict
-- Resolves and clones visual templates from the Studio-authored BingoGuiDesign.
-- Callers own their own fallback and bind game state after cloning.
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local StudioTemplate = {}

local function findDesignRoot(): Instance?
	local design = StarterGui:FindFirstChild("BingoGuiDesign")
	if design then
		return design
	end
	local player = Players.LocalPlayer
	local playerGui = player and player:FindFirstChildOfClass("PlayerGui")
	return playerGui and playerGui:FindFirstChild("BingoGuiDesign")
end

function StudioTemplate.Find(path: string): Instance?
	local current = findDesignRoot()
	if not current then
		return nil
	end
	if path == "" then
		return current
	end
	for name in string.gmatch(path, "[^%.]+") do
		local child = current:FindFirstChild(name)
		if not child then
			return nil
		end
		current = child
	end
	return current
end

function StudioTemplate.Clone(path: string, parent: Instance, expectedClass: string): Instance?
	local source = StudioTemplate.Find(path)
	if not source or not source:IsA(expectedClass) then
		return nil
	end
	local clone = source:Clone()
	clone.Parent = parent
	return clone
end

return table.freeze(StudioTemplate)
