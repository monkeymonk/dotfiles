local highlight = require("highlight")

local config = {
	highlight_group = "WarningMsg", -- Default highlight group
}

local M = {}

function M.setup(opts)
	if opts ~= nil then
		config = vim.tbl_extend("force", config, opts)
	end

	vim.api.nvim_create_user_command("DuplicatesHighlight", function()
		highlight.highlight_duplicates(config)
	end, {})

	vim.api.nvim_create_user_command("DuplicatesShowInQuickfix", function()
		highlight.show_duplicates_in_quickfix()
	end, {})

	vim.api.nvim_create_user_command("DuplicatesClearHighlights", function()
		highlight.clear_highlights()
	end, {})

	-- Clear highlights with ESC
	-- vim.api.nvim_set_keymap(
	--   "n",
	--   "<Esc>",
	--   ':lua require("monkeymonk.duplicate-lines.highlight").clear_highlights()<CR>',
	--   { desc = "Clear highlights", noremap = false, silent = true }
	-- )
end

return M
