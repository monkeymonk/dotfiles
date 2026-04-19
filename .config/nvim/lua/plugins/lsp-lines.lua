return {
	name = "lsp-lines",
	src = "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
	event = "LspAttach",

	setup = function()
		require("lsp_lines").setup()
		-- Start disabled to avoid visual noise; toggle with <leader>ul
		require("lsp_lines").toggle()
	end,

	keys = function(map)
		map.n("<leader>ul", function()
			require("lsp_lines").toggle()
		end, "Toggle LSP lines")
	end,
}
