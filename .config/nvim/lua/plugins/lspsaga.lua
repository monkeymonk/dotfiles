return {
	name = "lspsaga",
	src = "https://github.com/nvimdev/lspsaga.nvim",
	event = "LspAttach",

	config = function()
		require("lspsaga").setup({
			ui = {
				border = "rounded",
				code_action = "💡",
			},
			lightbulb = {
				enable = true,
				sign = false,
				virtual_text = true,
			},
			symbol_in_winbar = {
				enable = true,
			},
			rename = {
				in_select = false,
				auto_save = true,
			},
			finder = {
				keys = {
					toggle_or_open = "<CR>",
					quit = "q",
				},
			},
			definition = {
				keys = {
					edit = "<CR>",
					vsplit = "v",
					split = "s",
					quit = "q",
				},
			},
			outline = {
				layout = "float",
			},
		})
	end,

	keys = {
		-- Navigation
		{ "gd", "<cmd>Lspsaga goto_definition<cr>", desc = "Goto definition" },
		{ "gD", "<cmd>Lspsaga peek_definition<cr>", desc = "Peek definition" },
		{ "gr", "<cmd>Lspsaga finder ref<cr>", desc = "References" },
		{ "gi", "<cmd>Lspsaga finder imp<cr>", desc = "Goto implementation" },
		{ "gy", "<cmd>Lspsaga goto_type_definition<cr>", desc = "Goto type definition" },
		{ "gY", "<cmd>Lspsaga peek_type_definition<cr>", desc = "Peek type definition" },

		-- Info
		{ "K", "<cmd>Lspsaga hover_doc<cr>", desc = "Hover" },
		{
			"gK",
			function()
				vim.lsp.buf.signature_help({ border = "rounded" })
			end,
			desc = "Signature help",
		},
		{
			"<C-k>",
			function()
				vim.lsp.buf.signature_help({ border = "rounded" })
			end,
			desc = "Signature help",
			mode = "i",
		},

		-- Code actions
		{ "<leader>cr", "<cmd>Lspsaga rename<cr>", desc = "Rename" },
		{ "<leader>ca", "<cmd>Lspsaga code_action<cr>", desc = "Code action", mode = { "n", "v" } },
		{ "<leader>co", "<cmd>Lspsaga outline<cr>", desc = "Outline" },
		{ "<leader>ci", "<cmd>Lspsaga incoming_calls<cr>", desc = "Incoming calls" },
		{ "<leader>cO", "<cmd>Lspsaga outgoing_calls<cr>", desc = "Outgoing calls" },
		{ "<leader>cl", "<cmd>lsp status<cr>", desc = "LSP info" },
		{ "<leader>cR", "<cmd>lsp restart<cr>", desc = "LSP restart" },
		{ "<leader>cL", "<cmd>lsp log<cr>", desc = "LSP log" },
		{
			"<leader>ch",
			function()
				local bufnr = vim.api.nvim_get_current_buf()
				vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
			end,
			desc = "Toggle inlay hints",
		},

		-- Diagnostics
		{ "<leader>df", "<cmd>Lspsaga show_line_diagnostics<cr>", desc = "Line diagnostics" },
		{ "<leader>db", "<cmd>Lspsaga show_buf_diagnostics<cr>", desc = "Buffer diagnostics" },
		{ "<leader>dw", "<cmd>Lspsaga show_workspace_diagnostics<cr>", desc = "Workspace diagnostics" },
		{ "[d", "<cmd>Lspsaga diagnostic_jump_prev<cr>", desc = "Previous diagnostic" },
		{ "]d", "<cmd>Lspsaga diagnostic_jump_next<cr>", desc = "Next diagnostic" },
		{
			"[e",
			function()
				require("lspsaga.diagnostic"):goto_prev({ severity = vim.diagnostic.severity.ERROR })
			end,
			desc = "Previous error",
		},
		{
			"]e",
			function()
				require("lspsaga.diagnostic"):goto_next({ severity = vim.diagnostic.severity.ERROR })
			end,
			desc = "Next error",
		},
		{
			"[w",
			function()
				require("lspsaga.diagnostic"):goto_prev({ severity = vim.diagnostic.severity.WARN })
			end,
			desc = "Previous warning",
		},
		{
			"]w",
			function()
				require("lspsaga.diagnostic"):goto_next({ severity = vim.diagnostic.severity.WARN })
			end,
			desc = "Next warning",
		},
	},
}
