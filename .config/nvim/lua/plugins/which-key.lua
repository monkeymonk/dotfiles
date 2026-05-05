return {
	name = "which-key",
	src = "https://github.com/folke/which-key.nvim",
	lazy = true,

	opts = {
		delay = 300,
		icons = { mappings = false },
		preset = "modern",
		spec = {
			{ "<leader>a", group = "ai/claude" },
			{ "<leader>b", group = "buffer" },
			{ "<leader>c", group = "code" },
			{ "<leader>cs", group = "snippets" },
			{ "<leader>f", group = "file/find" },
			{ "<leader>g", group = "git" },
			{ "<leader>j", group = "debug" },
			{ "<leader>q", group = "quit/session" },
			{ "<leader>s", group = "search" },
			{ "<leader>u", group = "ui" },
			{ "<leader>ux", group = "diagnostics" },
			{ "<leader>w", group = "windows" },
			{ "<leader>x", group = "nav/list" },
			{ "<leader>xm", group = "markers" },
		},
	},
}
