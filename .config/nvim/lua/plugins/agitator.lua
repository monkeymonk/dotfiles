return {
	name = "agitator",
	src = "https://github.com/emmanueltouzery/agitator.nvim",
	lazy = true,

	keys = function(map)
		map.n("<leader>gt", function()
			require("agitator").git_time_machine({ use_current_win = false })
		end, "Time machine")

		map.n("<leader>gl", function()
			require("agitator").git_blame_toggle()
		end, "Blame toggle")
	end,
}
