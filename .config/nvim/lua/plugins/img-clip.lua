return {
	name = "img-clip",
	src = "https://github.com/HakonHarnes/img-clip.nvim",
	lazy = true,

	config = function()
		require("img-clip").setup({
			default = {
				dir_path = "assets",
				extension = "png",
				prompt_for_file_name = true,
				insert_mode_after_paste = true,
			},
		})
	end,

	keys = {
		{ "<leader>cp", "<cmd>PasteImage<cr>", desc = "Paste image from clipboard" },
	},

	install = {
		notes = {
			"Requires xclip or wl-clipboard on Linux.",
			"Run :checkhealth img-clip to verify dependencies.",
		},
	},
}
