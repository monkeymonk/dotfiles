return {
	name = "trouble",
	src = "https://github.com/folke/trouble.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	cmd = "Trouble",

	config = function()
		require("trouble").setup({
			focus = false,
			follow = true,
			auto_preview = true,
			win = {
				position = "bottom",
			},
			preview = {
				type = "main",
				scratch = true,
			},
		})
	end,

	keys = {
		{ "<leader>uxt", "<cmd>Trouble diagnostics toggle<cr>", desc = "Trouble diagnostics" },
		{ "<leader>uxT", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Trouble buffer diagnostics" },
		{ "<leader>uxQ", "<cmd>Trouble qflist toggle<cr>", desc = "Trouble quickfix" },
		{ "<leader>uxL", "<cmd>Trouble loclist toggle<cr>", desc = "Trouble location list" },
		{ "<leader>cT", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "Trouble LSP" },
	},
}
