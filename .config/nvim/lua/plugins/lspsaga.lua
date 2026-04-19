return {
	name = "lspsaga",
	src = "https://github.com/nvimdev/lspsaga.nvim",
	event = "LspAttach",

	setup = function()
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

	keys = function(map)
		-- Navigation
		map.n("gd", "<cmd>Lspsaga goto_definition<cr>", "Goto definition")
		map.n("gD", "<cmd>Lspsaga peek_definition<cr>", "Peek definition")
		map.n("gr", "<cmd>Lspsaga finder ref<cr>", "References")
		map.n("gi", "<cmd>Lspsaga finder imp<cr>", "Goto implementation")
		map.n("gy", "<cmd>Lspsaga goto_type_definition<cr>", "Goto type definition")
		map.n("gY", "<cmd>Lspsaga peek_type_definition<cr>", "Peek type definition")

		-- Info
		map.n("K", "<cmd>Lspsaga hover_doc<cr>", "Hover")
		map.n("gK", function()
			vim.lsp.buf.signature_help({ border = "rounded" })
		end, "Signature help")
		map.i("<C-k>", function()
			vim.lsp.buf.signature_help({ border = "rounded" })
		end, "Signature help")

		-- Code actions
		map.n("<leader>cr", "<cmd>Lspsaga rename<cr>", "Rename")
		map.map({ "n", "v" }, "<leader>ca", "<cmd>Lspsaga code_action<cr>", "Code action")
		map.n("<leader>co", "<cmd>Lspsaga outline<cr>", "Outline")
		map.n("<leader>ci", "<cmd>Lspsaga incoming_calls<cr>", "Incoming calls")
		map.n("<leader>cO", "<cmd>Lspsaga outgoing_calls<cr>", "Outgoing calls")
		map.n("<leader>cl", "<cmd>lsp status<cr>", "LSP info")
		map.n("<leader>cR", "<cmd>lsp restart<cr>", "LSP restart")
		map.n("<leader>cL", "<cmd>lsp log<cr>", "LSP log")
		map.n("<leader>ch", function()
			local bufnr = vim.api.nvim_get_current_buf()
			vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
		end, "Toggle inlay hints")

		-- Diagnostics
		map.n("<leader>uxo", "<cmd>Lspsaga show_line_diagnostics<cr>", "Line diagnostics")
		map.n("<leader>uxb", "<cmd>Lspsaga show_buf_diagnostics<cr>", "Buffer diagnostics")
		map.n("<leader>uxw", "<cmd>Lspsaga show_workspace_diagnostics<cr>", "Workspace diagnostics")
		map.n("[d", "<cmd>Lspsaga diagnostic_jump_prev<cr>", "Previous diagnostic")
		map.n("]d", "<cmd>Lspsaga diagnostic_jump_next<cr>", "Next diagnostic")
		map.n("[e", function()
			require("lspsaga.diagnostic"):goto_prev({ severity = vim.diagnostic.severity.ERROR })
		end, "Previous error")
		map.n("]e", function()
			require("lspsaga.diagnostic"):goto_next({ severity = vim.diagnostic.severity.ERROR })
		end, "Next error")
		map.n("[w", function()
			require("lspsaga.diagnostic"):goto_prev({ severity = vim.diagnostic.severity.WARN })
		end, "Previous warning")
		map.n("]w", function()
			require("lspsaga.diagnostic"):goto_next({ severity = vim.diagnostic.severity.WARN })
		end, "Next warning")
	end,
}
