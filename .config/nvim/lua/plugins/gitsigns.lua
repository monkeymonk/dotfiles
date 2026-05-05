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

	keys = function(map)
		local gs = function()
			return require("gitsigns")
		end

		map.n("]h", function()
			gs().nav_hunk("next")
		end, "Next git hunk")
		map.n("[h", function()
			gs().nav_hunk("prev")
		end, "Previous git hunk")
		map.n("<leader>gs", function()
			gs().stage_hunk()
		end, "Stage hunk")
		map.n("<leader>gr", function()
			gs().reset_hunk()
		end, "Reset hunk")
		map.n("<leader>gp", function()
			gs().preview_hunk()
		end, "Preview hunk")
		map.n("<leader>gb", function()
			gs().blame_line({ full = true })
		end, "Blame line")
		map.n("<leader>gi", function()
			gs().toggle_current_line_blame()
		end, "Toggle line blame")
		map.n("<leader>gd", function()
			require("util.native_tools").diff_current_file("HEAD")
		end, "Diff current file against HEAD")
	end,
}
