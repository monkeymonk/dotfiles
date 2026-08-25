return {
	name = "yanky",
	src = "https://github.com/gbprod/yanky.nvim",
	dependencies = {
		"folke/snacks.nvim",
	},
	priority = 110,

	opts = {
		ring = {
			history_length = 100,
			storage = "shada",
			sync_with_numbered_registers = true,
			ignore_registers = { "_" },
		},
		system_clipboard = {
			sync_with_ring = true,
		},
		highlight = {
			on_put = true,
			on_yank = true,
			timer = 300,
		},
		preserve_cursor_position = {
			enabled = true,
		},
		textobj = {
			enabled = true,
		},
	},

	lazy = false,

	keys = {
		{ "y", "<Plug>(YankyYank)", desc = "Yank", mode = { "n", "x" } },
		{ "p", "<Plug>(YankyPutAfter)", desc = "Put after", mode = { "n", "x" } },
		{ "P", "<Plug>(YankyPutBefore)", desc = "Put before", mode = { "n", "x" } },
		{ "gp", "<Plug>(YankyGPutAfter)", desc = "Put after and leave cursor", mode = { "n", "x" } },
		{ "gP", "<Plug>(YankyGPutBefore)", desc = "Put before and leave cursor", mode = { "n", "x" } },
		{ "]p", "<Plug>(YankyPutIndentAfterLinewise)", desc = "Put linewise below" },
		{ "[p", "<Plug>(YankyPutIndentBeforeLinewise)", desc = "Put linewise above" },
		{ "]P", "<Plug>(YankyPutIndentAfterLinewise)", desc = "Put linewise below" },
		{ "[P", "<Plug>(YankyPutIndentBeforeLinewise)", desc = "Put linewise above" },
		{ ">p", "<Plug>(YankyPutIndentAfterShiftRight)", desc = "Put and indent right" },
		{ "<p", "<Plug>(YankyPutIndentAfterShiftLeft)", desc = "Put and indent left" },
		{ ">P", "<Plug>(YankyPutIndentBeforeShiftRight)", desc = "Put before and indent right" },
		{ "<P", "<Plug>(YankyPutIndentBeforeShiftLeft)", desc = "Put before and indent left" },
		{ "=p", "<Plug>(YankyPutAfterFilter)", desc = "Put after and filter" },
		{ "=P", "<Plug>(YankyPutBeforeFilter)", desc = "Put before and filter" },
		{
			"<leader>y",
			function()
				local ok, snacks = pcall(require, "snacks")
				if ok and snacks.picker and snacks.picker.yanky then
					snacks.picker.yanky()
				else
					vim.cmd("YankyRingHistory")
				end
			end,
			desc = "Yank history",
			mode = { "n", "x" },
		},
		{
			"iy",
			function()
				require("yanky.textobj").last_put()
			end,
			desc = "Last put text object",
			mode = { "o", "x" },
		},
	},
}
