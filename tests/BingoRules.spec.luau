--!strict
-- Run in Studio with the server feature folder; no mutable game state required.
return function(feature: Instance): number
	local Rules = require(feature:FindFirstChild("BingoRules") :: ModuleScript)
	local Queue = require(feature:FindFirstChild("BingoQueue") :: ModuleScript)
	local checks = 0
	for seed = 1, 100 do
		local card = Rules.GenerateCard(Random.new(seed))
		assert(#card == 25 and card[13].isFree and card[13].isMarked)
		local called: {[number]: boolean} = {}
		for column = 1, 5 do
			local used: {[number]: boolean} = {}
			for row = 1, 5 do
				local cell = card[(row - 1) * 5 + column]
				if not cell.isFree then
					assert(cell.number >= (column - 1) * 15 + 1 and cell.number <= column * 15)
					assert(not used[cell.number]); used[cell.number] = true
				end
			end
		end
		local deck = Rules.Shuffle(Random.new(seed), 1, 75)
		for _, number in deck do assert(not called[number]); called[number] = true end
		assert(#deck == 75)
		assert(Rules.ValidateMark(card, {}, 1) ~= nil)
		assert(Rules.ValidateMark(card, called, 1) == nil)
		assert(Rules.ValidateMark(card, called, 13) ~= nil)
		assert(not Rules.IsComplete(card))
		local copy = Rules.CopyCard(card)
		copy[1].isMarked = true
		assert(not card[1].isMarked)
		for _, cell in card do cell.isMarked = true end
		assert(Rules.IsComplete(card))
		checks += 1
	end
	local queue = Queue.new()
	queue.Join(20); queue.Join(10); queue.Join(10)
	assert(queue.Count() == 2 and queue.Contains(10))
	queue.Leave(20); assert(queue.Count() == 1)
	queue.Join(30)
	local locked = queue.TakeEligible()
	assert(#locked == 2 and locked[1] == 10 and locked[2] == 30 and queue.Count() == 0)
	queue.Join(40); queue.Clear(); assert(queue.Count() == 0)
	return checks + 1
end
