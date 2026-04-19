return {
	name = "trouble",
	src = "https://github.com/folke/trouble.nvim",
	dependencies = {
		"https://github.com/nvim-tree/nvim-web-devicons",
	},
	cmd = "Trouble",

	setup = function()
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

	keys = function(map)
		map.n("<leader>uxt", "<cmd>Trouble diagnostics toggle<cr>", "Trouble diagnostics")
		map.n("<leader>uxT", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", "Trouble buffer diagnostics")
		map.n("<leader>uxQ", "<cmd>Trouble qflist toggle<cr>", "Trouble quickfix")
		map.n("<leader>uxL", "<cmd>Trouble loclist toggle<cr>", "Trouble location list")
		map.n("<leader>cT", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", "Trouble LSP")
	end,
}
