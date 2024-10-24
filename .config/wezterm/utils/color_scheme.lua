local h = require("utils/helpers")
local M = {}

--- Get the color scheme based on the current appearance (dark/light)
-- If the appearance is dark, it returns "Catppuccin Mocha", otherwise "Catppuccin Latte"
-- @return string: The color scheme name based on the appearance
M.get_color_scheme = function()
	-- return "Catppuccin Mocha"
	return h.is_dark() and "Catppuccin Mocha" or "Catppuccin Latte"
end

return M
