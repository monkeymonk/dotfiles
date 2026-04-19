local map = require("util.map")

map.batch({
	{ "<leader>ww", "<C-w>w", desc = "Other window" },
	{ "<leader>wd", "<C-w>c", desc = "Close window" },
	{ "<leader>ws", "<C-w>s", desc = "Split below" },
	{ "<leader>wv", "<C-w>v", desc = "Split right" },
}, { mode = "n" })
