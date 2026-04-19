local M = {}

local tip_dir = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h") .. "/"

local tip_files = {
	tip_dir .. "neotips.txt",
	tip_dir .. "vtips.txt",
}

function M.random()
	local lines = {}
	for _, path in ipairs(tip_files) do
		local f = io.open(path, "r")
		if f then
			for line in f:lines() do
				if line ~= "" then
					lines[#lines + 1] = line
				end
			end
			f:close()
		end
	end
	if #lines == 0 then
		return "No tips found."
	end
	return lines[math.random(#lines)]
end

return M
