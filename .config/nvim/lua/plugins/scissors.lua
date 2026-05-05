return {
	name = "scissors",
	src = "https://github.com/chrisgrieser/nvim-scissors",
	dependencies = {
		"https://github.com/folke/snacks.nvim",
		"https://github.com/L3MON4D3/LuaSnip",
	},
	cmd = {
		"ScissorsAddNewSnippet",
		"ScissorsEditSnippet",
	},

	install = {
		notes = {
			"Scissors manages VS Code style snippets in ~/.config/nvim/snippets/.",
			"Lua snippets still live in ~/.config/nvim/luasnippets/ for advanced cases.",
		},
	},

	opts = function()
		return {
			snippetDir = vim.fs.joinpath(vim.fn.stdpath("config"), "snippets"),
		}
	end,

	keys = function(map)
		map.n("<leader>csa", "<cmd>ScissorsAddNewSnippet<cr>", "Snippet add")
		map.map({ "n", "x" }, "<leader>cse", "<cmd>ScissorsEditSnippet<cr>", "Snippet edit")
	end,
}
