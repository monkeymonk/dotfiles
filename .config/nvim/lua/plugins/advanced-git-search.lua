return {
	name = "advanced-git-search",
	src = "https://github.com/aaronhallaert/advanced-git-search.nvim",
	dependencies = {
		"https://github.com/tpope/vim-fugitive",
		"https://github.com/sindrets/diffview.nvim",
	},
	lazy = true,

	setup = function()
		require("advanced_git_search.snacks").setup({})
	end,

	keys = function(map)
		map.n("<leader>gB", "<cmd>AdvancedGitSearch diff_branch_file<cr>", "Search branches")
		map.n("<leader>gD", "<cmd>AdvancedGitSearch diff_commit_file<cr>", "Search commits in file")
		map.n("<leader>gL", "<cmd>AdvancedGitSearch search_log_content<cr>", "Search log content")
	end,
}
