return {
	name = "mini-pairs",
	src = "https://github.com/echasnovski/mini.pairs",
	event = "InsertEnter",

	config = function()
		require("mini.pairs").setup()
	end,
}
