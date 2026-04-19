return {
	name = "neogen",
	src = "https://github.com/danymat/neogen",
	lazy = true,

	setup = function()
		require("neogen").setup({
			languages = {
				php = { template = { annotation_convention = "phpdoc" } },
			},
			snippet_engine = "luasnip",
		})
	end,

	keys = function(map)
		map.n("<leader>cn", function()
			require("neogen").generate({})
		end, "Generate annotation")

		map.x("<leader>cn", function()
			require("neogen").generate({})
		end, "Generate annotation")
	end,
}
