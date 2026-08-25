return {
	name = "scissors",
	src = "https://github.com/chrisgrieser/nvim-scissors",
	dependencies = {
		"folke/snacks.nvim",
		"L3MON4D3/LuaSnip",
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

	keys = {
		{ "<leader>csa", "<cmd>ScissorsAddNewSnippet<cr>", desc = "Snippet add" },
		{ "<leader>cse", "<cmd>ScissorsEditSnippet<cr>", desc = "Snippet edit", mode = { "n", "x" } },
	},
}
