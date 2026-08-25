return {
	name = "track-action",
	src = "https://github.com/17xande/track-action.nvim",
	main = "track-action",
	lazy = false,

	cond = function()
		return vim.fn.has("nvim-0.13") == 1
	end,

	opts = {
		keybind = "<leader>ta",
	},

	install = {
		notes = {
			"Requires Neovim >= 0.13 for the CmdAtom event; current 0.12 builds skip loading it.",
		},
	},
}
