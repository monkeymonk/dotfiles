return {
	name = "noice",
	src = "https://github.com/folke/noice.nvim",
	dependencies = {
		"https://github.com/MunifTanjim/nui.nvim",
	},

	setup = function()
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

	keys = function(map)
		map.n("<leader>ui", "<cmd>Noice pick<cr>", "Notifications")
		map.n("<leader>uh", "<cmd>Noice history<cr>", "Message history")
		map.n("<leader>ue", "<cmd>Noice errors<cr>", "Message errors")
		map.n("<leader>uN", "<cmd>Noice last<cr>", "Last message")
		map.n("<leader>un", "<cmd>Noice dismiss<cr>", "Dismiss notifications")
	end,
}
