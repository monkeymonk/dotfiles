return {
	name = "luasnip",
	src = "https://github.com/L3MON4D3/LuaSnip",
	priority = 120,
	dependencies = {
		"https://github.com/rafamadriz/friendly-snippets",
	},

	install = {
		notes = {
			"User Lua snippets live in ~/.config/nvim/luasnippets/*.lua.",
			"Scissors snippets live in ~/.config/nvim/snippets/*.json.",
			"Project-local snippets can live in ./.luasnippets/*.lua.",
			"Use :SnippetHelp or <leader>csh for the workflow.",
		},
	},

	setup = function()
		require("util.snippets").setup()
	end,
}
