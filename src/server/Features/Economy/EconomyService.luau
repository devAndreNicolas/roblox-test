--!strict
local Service = {}
function Service.Credit(profile: any, amount: number): ()
	assert(amount >= 0 and amount % 1 == 0)
	profile.fichas += amount
end
function Service.TrySpend(profile: any, amount: number): boolean
	assert(amount >= 0 and amount % 1 == 0)
	if profile.fichas < amount then
		return false
	end
	profile.fichas -= amount
	return true
end
return Service
