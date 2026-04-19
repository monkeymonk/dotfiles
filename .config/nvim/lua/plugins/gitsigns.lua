return {
	name = "gitsigns",
	src = "https://github.com/lewis6991/gitsigns.nvim",
	event = "BufReadPost",

	setup = function()
		require("gitsigns").setup({
			signs = {
				add = { text = "▎" },
				change = { text = "▎" },
				delete = { text = "" },
				topdelete = { text = "" },
				changedelete = { text = "▎" },
				untracked = { text = "▎" },
			},
			current_line_blame = false,
		})
	end,

	keys = function(map)
		local native_tools = require("util.native_tools")

		map.n("]h", function()
			require("gitsigns").next_hunk()
		end, "Next git hunk")

		map.n("[h", function()
			require("gitsigns").prev_hunk()
		end, "Previous git hunk")

		map.n("<leader>gs", function()
			require("gitsigns").stage_hunk()
		end, "Stage hunk")

		map.n("<leader>gr", function()
			require("gitsigns").reset_hunk()
		end, "Reset hunk")

		map.n("<leader>gp", function()
			require("gitsigns").preview_hunk()
		end, "Preview hunk")

		map.n("<leader>gb", function()
			require("gitsigns").blame_line({ full = true })
		end, "Blame line")

		map.n("<leader>gi", function()
			require("gitsigns").toggle_current_line_blame()
		end, "Toggle line blame")

		map.n("<leader>gd", function()
			native_tools.diff_current_file("HEAD")
		end, "Diff current file against HEAD")
	end,
}
