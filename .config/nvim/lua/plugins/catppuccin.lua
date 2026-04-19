return {
	name = "catppuccin",
	src = "https://github.com/catppuccin/nvim",
	priority = 1000,

	setup = function()
		require("catppuccin").setup({
			flavour = "mocha",
			integrations = {
				blink_cmp = true,
				gitsigns = true,
				neogit = true,
				render_markdown = true,
				snacks = true,
				treesitter = true,
				lualine = true,
			which_key = true,
				mini = {
					enabled = true,
				},
			},
		})

		vim.cmd.colorscheme("catppuccin")
	end,
}
