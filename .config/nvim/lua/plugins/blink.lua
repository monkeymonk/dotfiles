return {
	name = "blink",
	src = "https://github.com/saghen/blink.cmp",
	dependencies = {
		"https://github.com/saghen/blink.lib",
		"https://github.com/saghen/blink.compat",
	},

	setup = function()
		require("blink.compat").setup({})

		require("blink.cmp").setup({
			fuzzy = { implementation = "lua" },
			snippets = {
				preset = "luasnip",
			},
			keymap = {
				preset = "default",
				["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
				["<CR>"] = { "accept", "fallback" },
				["<Tab>"] = { "snippet_forward", "select_next", "fallback" },
				["<S-Tab>"] = { "snippet_backward", "select_prev", "fallback" },
			},
			completion = {
				documentation = {
					auto_show = true,
					auto_show_delay_ms = 200,
				},
				menu = {
					border = "rounded",
				},
			},
			signature = { enabled = true },
			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
			},
		})
	end,
}
