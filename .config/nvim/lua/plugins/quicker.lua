return {
	name = "quicker",
	src = "https://github.com/stevearc/quicker.nvim",

	setup = function()
		require("quicker").setup({
			edit = {
				enabled = true,
				autosave = "unmodified",
			},
			on_qf = function(bufnr)
				local quicklist = require("util.quicklist")

				vim.keymap.set("n", "dd", function()
					quicklist.remove_qf_item()
				end, { buffer = bufnr, silent = true, desc = "Remove quickfix item" })

				vim.keymap.set("n", "x", function()
					quicklist.remove_qf_item()
				end, { buffer = bufnr, silent = true, desc = "Remove quickfix item" })

				vim.keymap.set("n", ">", function()
					require("quicker").expand()
				end, { buffer = bufnr, silent = true, desc = "Expand quickfix context" })

				vim.keymap.set("n", "<", function()
					require("quicker").collapse()
				end, { buffer = bufnr, silent = true, desc = "Collapse quickfix context" })
			end,
		})
	end,
}
