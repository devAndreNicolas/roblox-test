--!strict
-- Server composition root for the Bingo MVP.

local RoundService = require(script:WaitForChild("Services"):WaitForChild("RoundService"))

RoundService.Start()
