local map = require("util.map")

local diagnostics = require("config.actions.diagnostics")
local memory_sheet = require("util.memory_sheet")
local native_tools = require("util.native_tools")
local pickers = require("util.pickers")
local quicklist = require("util.quicklist")

memory_sheet.setup()

map.batch({
	{ "<leader>dd", diagnostics.toggle_buffer, desc = "Toggle diagnostics (buffer)" },
	{ "<leader>dq", diagnostics.to_qflist, desc = "Diagnostics to quickfix list" },
	{ "<leader>dl", diagnostics.to_loclist, desc = "Diagnostics to location list" },
	{
		"<leader>up",
		function()
			local rows = {}
			for _, p in ipairs(require("zpack.api").get_plugins()) do
				rows[#rows + 1] = ("%s  %s  [%s]"):format(
					p.status == "loaded" and "✓" or "·",
					p.name,
					p.lazy and "lazy" or "eager"
				)
			end
			vim.notify(table.concat(rows, "\n"), vim.log.levels.INFO)
		end,
		desc = "Plugins list",
	},
	{ "<leader>uP", "<cmd>Pack update<cr>", desc = "Plugins update" },
	{ "<leader>uu", native_tools.open_undotree, desc = "Undo tree" },
	{ "<leader>ur", "<cmd>restart<cr>", desc = "Restart Neovim" },
	{ "<leader>u?", memory_sheet.open, desc = "Memory sheet" },
	{ "<leader>e", pickers.explorer, desc = "File explorer" },
	{ "<leader><space>", pickers.files, desc = "Find files" },
	{ "<leader>/", pickers.grep, desc = "Grep" },
	{
		"<leader>sG",
		function()
			quicklist.grep_cwd()
		end,
		desc = "Grep in current file directory",
	},
}, { mode = "n" })
