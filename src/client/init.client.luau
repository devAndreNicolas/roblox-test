--!strict
-- Client composition root for the Bingo MVP.

local BingoController = require(script:WaitForChild("Features"):WaitForChild("Bingo"):WaitForChild("BingoController"))

BingoController.Start()
