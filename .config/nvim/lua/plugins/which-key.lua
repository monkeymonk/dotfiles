return {
	name = "which-key",
	src = "https://github.com/folke/which-key.nvim",
	lazy = false,

	opts = {
		delay = 300,
		icons = { mappings = false },
		preset = "modern",
		-- Every multi-key prefix in the config needs a row here, or which-key
		-- renders it as a bare key. Two rules keep this list honest: a prefix is
		-- either a leaf or a group, never both (`<leader>cp` used to be both, and
		-- stalled on timeoutlen); and conditional groups share their feature's
		-- availability condition.
		spec = {
			{ "<leader>a", group = "ai", mode = { "n", "x" } },
			{ "<leader>b", group = "buffer" },
			{ "<leader>c", group = "code", mode = { "n", "x" } },
			{ "<leader>cc", group = "review", mode = { "n", "x" } },
			{ "<leader>cd", group = "dependencies" },
			{ "<leader>cs", group = "snippets", mode = { "n", "x" } },
			{ "<leader>d", group = "diagnostics" },
			{ "<leader>g", group = "git" },
			{ "<leader>ga", group = "atlas" },
			{ "<leader>j", group = "debug", mode = { "n", "x" } },
			{ "<leader>q", group = "quit/session" },
			{ "<leader>s", group = "search" },
			{
				"<leader>t",
				group = "tracking",
				cond = function()
					return vim.fn.has("nvim-0.13") == 1
				end,
			},
			{ "<leader>u", group = "ui" },
			{ "<leader>un", group = "notifications" },
			{ "<leader>w", group = "windows" },
			{ "<leader>x", group = "nav/list" },
			{ "<leader>xa", group = "arglist" },
			{ "<leader>xm", group = "markers" },
		},
	},
}
