return {
	name = "advanced-git-search",
	src = "https://github.com/aaronhallaert/advanced-git-search.nvim",
	dependencies = {
		"tpope/vim-fugitive",
		"sindrets/diffview.nvim",
	},
	lazy = true,

	config = function()
		require("advanced_git_search.snacks").setup({})
	end,

	keys = {
		{ "<leader>gB", "<cmd>AdvancedGitSearch diff_branch_file<cr>", desc = "Search branches" },
		{ "<leader>gD", "<cmd>AdvancedGitSearch diff_commit_file<cr>", desc = "Search commits in file" },
		{ "<leader>gL", "<cmd>AdvancedGitSearch search_log_content<cr>", desc = "Search log content" },
	},
}
