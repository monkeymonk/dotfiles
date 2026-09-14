return {
	name = "img-clip",
	src = "https://github.com/HakonHarnes/img-clip.nvim",
	cmd = { "PasteImage" },

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

	install = {
		notes = {
			"Requires xclip or wl-clipboard on Linux.",
			"Run :checkhealth img-clip to verify dependencies.",
		},
	},
}
