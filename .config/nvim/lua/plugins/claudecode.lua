return {
	name = "claudecode",
	src = "https://github.com/coder/claudecode.nvim",
	lazy = true,

	setup = function()
		require("claudecode").setup({})
	end,

	keys = function(map)
		map.n("<leader>ac", "<cmd>ClaudeCode<cr>", "Toggle Claude")
		map.n("<leader>af", "<cmd>ClaudeCodeFocus<cr>", "Focus Claude")
		map.n("<leader>ar", "<cmd>ClaudeCode --resume<cr>", "Resume Claude")
		map.n("<leader>aC", "<cmd>ClaudeCode --continue<cr>", "Continue Claude")
		map.n("<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", "Select Claude model")
		map.n("<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", "Add current buffer")
		map.x("<leader>as", "<cmd>ClaudeCodeSend<cr>", "Send to Claude")
		map.n("<leader>aD", "<cmd>ClaudeCodeDiffAccept<cr>", "Accept diff")
		map.n("<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", "Deny diff")
	end,
}
