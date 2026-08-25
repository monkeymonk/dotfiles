return {
	name = "mini-surround",
	src = "https://github.com/echasnovski/mini.surround",
	event = { "BufReadPost", "BufNewFile" },

	config = function()
		require("mini.surround").setup()
	end,
}
