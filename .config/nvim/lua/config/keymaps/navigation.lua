local map = require("util.map")

local arglist = require("config.actions.arglist")
local markers = require("util.markers")
local quicklist = require("util.quicklist")

map.batch({
	{ "<leader>xq", quicklist.toggle_qf, desc = "Quickfix toggle" },
	{ "<leader>xl", quicklist.toggle_ll, desc = "Location list toggle" },
	{ "<leader>xr", quicklist.replace_in_qf_files, desc = "Quickfix replace in files" },
	{ "<leader>xaa", arglist.set_current_file_only, desc = "Arglist current file only" },
	{ "<leader>xas", arglist.show, desc = "Arglist show" },
	{ "<leader>xan", "<cmd>next<cr>", desc = "Arglist next" },
	{ "<leader>xap", "<cmd>previous<cr>", desc = "Arglist previous" },
	{ "<leader>xaf", "<cmd>first<cr>", desc = "Arglist first" },
	{ "<leader>xal", "<cmd>last<cr>", desc = "Arglist last" },
	{ "<leader>xae", arglist.add_current_file, desc = "Arglist add current file" },
	{ "<leader>xad", arglist.remove_file, desc = "Arglist remove file" },
	{ "<leader>xma", markers.add_current, desc = "Marker add" },
	{ "<leader>xml", markers.pick, desc = "Markers list" },
	{ "<leader>xmd", markers.remove, desc = "Marker remove" },
	{ "<leader>xmn", markers.next, desc = "Next marker" },
	{ "<leader>xmp", markers.prev, desc = "Previous marker" },
	{
		"]q",
		function()
			quicklist.jump("quickfix", "next")
		end,
		desc = "Next quickfix item",
	},
	{
		"[q",
		function()
			quicklist.jump("quickfix", "prev")
		end,
		desc = "Previous quickfix item",
	},
	{
		"]l",
		function()
			quicklist.jump("loclist", "next")
		end,
		desc = "Next location list item",
	},
	{
		"[l",
		function()
			quicklist.jump("loclist", "prev")
		end,
		desc = "Previous location list item",
	},
}, { mode = "n" })
