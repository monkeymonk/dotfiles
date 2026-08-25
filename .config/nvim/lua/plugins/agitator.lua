return {
	name = "agitator",
	src = "https://github.com/emmanueltouzery/agitator.nvim",
	lazy = true,

	keys = {
		{
			"<leader>gt",
			function()
				require("agitator").git_time_machine({ use_current_win = false })
			end,
			desc = "Time machine",
		},
		{
			"<leader>gl",
			function()
				require("agitator").git_blame_toggle()
			end,
			desc = "Blame toggle",
		},
	},
}
