local map = require("util.map")
local pickers = require("util.pickers")

map.batch({
	{ "<leader>bb", pickers.buffers, desc = "List buffers" },
	{
		"<leader>bd",
		function()
			require("snacks").bufdelete()
		end,
		desc = "Delete buffer",
	},
	{
		"<leader>bD",
		function()
			require("snacks").bufdelete.other()
		end,
		desc = "Delete other buffers",
	},
	{ "<leader>be", "<cmd>enew<cr>", desc = "New empty buffer" },
	{ "<leader>bn", "<cmd>bnext<cr>", desc = "Next buffer" },
	{ "<leader>bp", "<cmd>bprevious<cr>", desc = "Previous buffer" },
}, { mode = "n" })
