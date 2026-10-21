--!strict
-- Server composition root for the Bingo MVP.

local RoundService = require(script:WaitForChild("Features"):WaitForChild("Bingo"):WaitForChild("BingoService"))
local RewardsService = require(script.Features.Rewards.RewardsService)

RewardsService.Start()
RoundService.Start(RewardsService)
