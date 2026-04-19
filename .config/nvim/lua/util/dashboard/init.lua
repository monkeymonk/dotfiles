local M = {}

function M.random_art()
	local library = require("util.dashboard.ascii")
	local names = {}
	for k, v in pairs(library) do
		if type(v) == "table" then
			names[#names + 1] = k
		end
	end
	if #names == 0 then
		return { "" }
	end
	return library[names[math.random(#names)]]
end

function M.random_tip()
	return require("util.dashboard.tips").random()
end

return M
