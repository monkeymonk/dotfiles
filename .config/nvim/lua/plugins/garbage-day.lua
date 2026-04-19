return {
	name = "garbage-day",
	src = "https://github.com/zeioth/garbage-day.nvim",
	event = "LspAttach",

	setup = function()
		require("garbage-day").setup({
			excluded_lsp_clients = {},
			notifications = true,
		})
	end,
}
