return {
	name = "noice",
	src = "https://github.com/folke/noice.nvim",
	dependencies = {
		"MunifTanjim/nui.nvim",
	},

	lazy = false,

	config = function()
		require("noice").setup({
			lsp = {
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
				},
			},
			presets = {
				bottom_search = true,
				command_palette = true,
				long_message_to_split = true,
				lsp_doc_border = true,
			},
		})
	end,

	keys = {
		{ "<leader>ui", "<cmd>Noice pick<cr>", desc = "Notifications" },
		{ "<leader>uh", "<cmd>Noice history<cr>", desc = "Message history" },
		{ "<leader>ue", "<cmd>Noice errors<cr>", desc = "Message errors" },
		{ "<leader>uN", "<cmd>Noice last<cr>", desc = "Last message" },
		{ "<leader>un", "<cmd>Noice dismiss<cr>", desc = "Dismiss notifications" },
	},
}
