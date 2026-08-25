return {
	name = "gitsigns",
	src = "https://github.com/lewis6991/gitsigns.nvim",
	event = "BufReadPost",

	opts = {
		signs = {
			add = { text = "▎" },
			change = { text = "▎" },
			delete = { text = "" },
			topdelete = { text = "" },
			changedelete = { text = "▎" },
			untracked = { text = "▎" },
		},
		current_line_blame = false,
	},

	keys = {
		{
			"]h",
			function()
				require("gitsigns").nav_hunk("next")
			end,
			desc = "Next git hunk",
		},
		{
			"[h",
			function()
				require("gitsigns").nav_hunk("prev")
			end,
			desc = "Previous git hunk",
		},
		{
			"<leader>gs",
			function()
				require("gitsigns").stage_hunk()
			end,
			desc = "Stage hunk",
		},
		{
			"<leader>gr",
			function()
				require("gitsigns").reset_hunk()
			end,
			desc = "Reset hunk",
		},
		{
			"<leader>gp",
			function()
				require("gitsigns").preview_hunk()
			end,
			desc = "Preview hunk",
		},
		{
			"<leader>gb",
			function()
				require("gitsigns").blame_line({ full = true })
			end,
			desc = "Blame line",
		},
		{
			"<leader>gi",
			function()
				require("gitsigns").toggle_current_line_blame()
			end,
			desc = "Toggle line blame",
		},
		{
			"<leader>gd",
			function()
				require("util.native_tools").diff_current_file("HEAD")
			end,
			desc = "Diff current file against HEAD",
		},
	},
}
