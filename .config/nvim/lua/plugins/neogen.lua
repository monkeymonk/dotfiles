return {
	name = "neogen",
	src = "https://github.com/danymat/neogen",
	lazy = true,

	config = function()
		require("neogen").setup({
			languages = {
				php = { template = { annotation_convention = "phpdoc" } },
			},
			snippet_engine = "luasnip",
		})
	end,

	keys = {
		{
			"<leader>cn",
			function()
				require("neogen").generate({})
			end,
			desc = "Generate annotation",
		},
		{
			"<leader>cn",
			function()
				require("neogen").generate({})
			end,
			desc = "Generate annotation",
			mode = "x",
		},
	},
}
