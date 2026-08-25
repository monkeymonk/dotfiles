return {
	name = "markdown-plus",
	src = "https://github.com/yousefhadder/markdown-plus.nvim",
	ft = "markdown",

	config = function()
		require("markdown-plus").setup({})
	end,
}
