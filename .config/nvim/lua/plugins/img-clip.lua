return {
	name = "img-clip",
	src = "https://github.com/HakonHarnes/img-clip.nvim",
	lazy = true,

	setup = function()
		require("img-clip").setup({
			default = {
				dir_path = "assets",
				extension = "png",
				prompt_for_file_name = true,
				insert_mode_after_paste = true,
			},
		})
	end,

	keys = function(map)
		map.n("<leader>cp", "<cmd>PasteImage<cr>", "Paste image from clipboard")
	end,

	install = {
		notes = {
			"Requires xclip or wl-clipboard on Linux.",
			"Run :checkhealth img-clip to verify dependencies.",
		},
	},
}
