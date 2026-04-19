return {
	name = "comment",
	src = "https://github.com/numToStr/Comment.nvim",
	dependencies = {
		"https://github.com/JoosepAlviste/nvim-ts-context-commentstring",
	},
	event = { "BufReadPost", "BufNewFile" },

	setup = function()
		require("ts_context_commentstring").setup({
			enable_autocmd = false,
		})

		require("Comment").setup({
			pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
		})
	end,
}
