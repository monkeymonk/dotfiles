return {
	name = "neogit",
	src = "https://github.com/NeogitOrg/neogit",
	cmd = "Neogit",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},

	install = {
		binaries = { "git" },
		notes = {
			"Neogit uses inline diffs here; native DiffTool is exposed through your git keymaps.",
		},
	},

	config = function()
		require("neogit").setup({
			integrations = {
				diffview = false,
				codediff = false,
			},
			kind = "tab",
			commit_editor = {
				kind = "split",
				show_staged_diff = false,
			},
		})
	end,

	keys = {
		{ "<leader>gg", "<cmd>Neogit<cr>", desc = "Open Neogit" },
	},
}
