return {
	name = "blink",
	src = "https://github.com/saghen/blink.cmp",
	dependencies = {
		"saghen/blink.lib",
		"saghen/blink.compat",
	},

	config = function()
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
			cmdline = {
				-- blink defaults the cmdline menu to <Tab>-only; show it while typing.
				keymap = {
					-- <Tab>/<S-Tab> cycling comes from the cmdline preset. These add
					-- arrows on top; they fall back to command history when the menu
					-- is closed.
					["<Down>"] = { "select_next", "fallback" },
					["<Up>"] = { "select_prev", "fallback" },
				},
				completion = {
					menu = { auto_show = true },
				},
			},
			sources = {
				-- In attached prompt.nvim buffers, use only the prompt source (plus
				-- snippets/buffer) so blink's path/LSP sources don't add noise to
				-- @-file and /-command completion. Everywhere else, the normal set.
				default = function()
					if require("prompt.buffer").is_attached(0) then
						return { "prompt", "snippets", "buffer" }
					end
					return { "lsp", "path", "snippets", "buffer" }
				end,
				providers = {
					prompt = { name = "Prompt", module = "prompt.integrations.blink" },
				},
			},
		})
	end,
}
