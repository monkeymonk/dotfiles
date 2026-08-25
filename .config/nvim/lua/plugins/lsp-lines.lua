return {
	name = "lsp-lines",
	src = "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
	event = "LspAttach",

	config = function()
		require("lsp_lines").setup()
		-- Start disabled to avoid visual noise; toggle with <leader>ul
		require("lsp_lines").toggle()
	end,

	keys = {
		{
			"<leader>ul",
			function()
				require("lsp_lines").toggle()
			end,
			desc = "Toggle LSP lines",
		},
	},
}
