return {
	name = "lsp-lines",
	src = "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
	event = "LspAttach",

	config = function()
		require("lsp_lines").setup()
		-- Start disabled to avoid visual noise; toggle with <leader>dv
		require("lsp_lines").toggle()
	end,

	keys = {
		{
			"<leader>dv",
			function()
				require("lsp_lines").toggle()
			end,
			desc = "Toggle virtual lines",
		},
	},
}
