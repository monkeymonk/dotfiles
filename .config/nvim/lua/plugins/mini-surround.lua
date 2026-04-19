return {
	name = "mini-surround",
	src = "https://github.com/echasnovski/mini.surround",
	event = { "BufReadPost", "BufNewFile" },

	setup = function()
		require("mini.surround").setup()
	end,
}
