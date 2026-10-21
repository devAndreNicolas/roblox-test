--!strict
-- Server composition root for the Bingo MVP.

local RoundService = require(script:WaitForChild("Features"):WaitForChild("Bingo"):WaitForChild("BingoService"))
local RewardsService = require(script.Features.Rewards.RewardsService)

RewardsService.Start()
local settingsModule = script.Parent:FindFirstChild("RoundSettings")
local roundSettings = if settingsModule and settingsModule:IsA("ModuleScript") then require(settingsModule) else nil
RoundService.Start(RewardsService, roundSettings)
