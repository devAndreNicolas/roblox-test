--!strict
local Types = require(game:GetService("ReplicatedStorage").Shared.Features.Bingo.BingoTypes)
type Card = {Types.CardCell}
local Rules = {}

function Rules.Shuffle(random: Random, minimum: number, maximum: number): {number}
	local values = {}
	for value = minimum, maximum do table.insert(values, value) end
	for index = #values, 2, -1 do
		local other = random:NextInteger(1, index)
		values[index], values[other] = values[other], values[index]
	end
	return values
end

function Rules.GenerateCard(random: Random): Card
	local card: Card = {}
	for column = 1, 5 do
		local pool = Rules.Shuffle(random, (column - 1) * 15 + 1, column * 15)
		local selected = {pool[1], pool[2], pool[3], pool[4], pool[5]}
		table.sort(selected)
		for row = 1, 5 do
			local index = (row - 1) * 5 + column
			card[index] = {number = if index == 13 then 0 else selected[row], isFree = index == 13, isMarked = index == 13}
		end
	end
	return card
end

function Rules.ValidateMark(card: Card, called: {[number]: boolean}, index: number): string?
	local cell = card[index]
	if not cell then return "That square is not valid." end
	if cell.isMarked then return "That square is already marked." end
	if not cell.isFree and not called[cell.number] then return "That number has not been called yet." end
	return nil
end

function Rules.IsComplete(card: Card): boolean
	for _, cell in card do if not cell.isMarked then return false end end
	return true
end

function Rules.CopyCard(card: Card): Card
	local copy: Card = {}
	for index, cell in card do copy[index] = table.clone(cell) end
	return copy
end
return Rules
