local wezterm = require("wezterm")
local M = {}

--- Get a random entry from a table
-- @param tbl table: Table from which to get a random entry
-- @return any: Random entry from the table
M.get_random_entry = function(tbl)
	local keys = {}
	for key, _ in ipairs(tbl) do
		table.insert(keys, key)
	end
	local randomKey = keys[math.random(1, #keys)]
	return tbl[randomKey]
end

--- Checks if the current appearance is set to a dark theme
-- @return boolean: true if dark theme, false otherwise
M.is_dark = function()
	local appearance = wezterm.gui.get_appearance()
	return appearance:find("Dark")
end

return M
