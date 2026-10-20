--!strict
local Queue = {}
function Queue.new()
	local members: {[number]: boolean} = {}
	local queue = {}
	function queue.Join(id: number): () members[id] = true end
	function queue.Leave(id: number): () members[id] = nil end
	function queue.Contains(id: number): boolean return members[id] == true end
	function queue.Count(): number
		local count = 0
		for _ in members do count += 1 end
		return count
	end
	function queue.TakeEligible(): {number}
		local ids = {}
		for id in members do table.insert(ids, id) end
		table.sort(ids)
		table.clear(members)
		return ids
	end
	function queue.Clear(): () table.clear(members) end
	return queue
end
return Queue
