return {
	name = "triforce",
	src = "https://github.com/gisketch/triforce.nvim",
	dependencies = {
		"nvzone/volt",
	},
	lazy = false,

	opts = {},

	keys = {
		{ "<leader>ut", "<cmd>Triforce profile<cr>", desc = "Triforce profile" },
	},
}
