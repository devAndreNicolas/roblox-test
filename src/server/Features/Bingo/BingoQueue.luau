--!strict
local Queue = {}
function Queue.new()
	local members: {[number]: boolean} = {}
	local order: {number} = {}
	local queue = {}
	function queue.Join(id: number): ()
		if members[id] then return end
		members[id] = true
		table.insert(order, id)
	end
	function queue.Leave(id: number): ()
		if not members[id] then return end
		members[id] = nil
		local position = table.find(order, id)
		if position then table.remove(order, position) end
	end
	function queue.Contains(id: number): boolean return members[id] == true end
	function queue.IsInFirst(id: number, limit: number): boolean
		local position = table.find(order, id)
		return position ~= nil and position <= limit
	end
	function queue.Count(): number
		return #order
	end
	function queue.TakeEligible(limit: number): {number}
		local ids = {}
		local takeCount = math.min(#order, limit)
		for _ = 1, takeCount do
			local id = table.remove(order, 1)
			if id then
				members[id] = nil
				table.insert(ids, id)
			end
		end
		return ids
	end
	function queue.Clear(): ()
		table.clear(members)
		table.clear(order)
	end
	return queue
end
return Queue
