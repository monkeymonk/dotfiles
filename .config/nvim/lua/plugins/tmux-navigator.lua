return {
	name = "tmux-navigator",
	src = "https://github.com/christoomey/vim-tmux-navigator",
	lazy = true,

	setup = function()
		vim.g.tmux_navigator_no_mappings = 1
	end,

	keys = function(map)
		map.n("<C-h>", "<cmd>TmuxNavigateLeft<cr>", "Navigate left")
		map.n("<C-j>", "<cmd>TmuxNavigateDown<cr>", "Navigate down")
		map.n("<C-k>", "<cmd>TmuxNavigateUp<cr>", "Navigate up")
		map.n("<C-l>", "<cmd>TmuxNavigateRight<cr>", "Navigate right")
	end,
}
