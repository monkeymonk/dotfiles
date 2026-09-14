local function format_buffer_or_range()
	local opts = { async = true, lsp_format = "fallback", timeout_ms = 3000 }
	local mode = vim.api.nvim_get_mode().mode

	if mode == "v" or mode == "V" or mode == string.char(22) then
		local visual_pos = vim.fn.getpos("v")
		local cursor_pos = vim.fn.getpos(".")
		local start_row, start_col = visual_pos[2], visual_pos[3]
		local end_row, end_col = cursor_pos[2], cursor_pos[3]

		if start_row > end_row or (start_row == end_row and start_col > end_col) then
			start_row, end_row = end_row, start_row
			start_col, end_col = end_col, start_col
		end

		-- Avoid Conform's implicit conversion: Vim's endpoint is inclusive, but the formatter's is exclusive.
		if mode == "v" then
			opts.range = {
				start = { start_row, start_col - 1 },
				["end"] = { end_row, end_col },
			}
		else
			local end_line = vim.api.nvim_buf_get_lines(0, end_row - 1, end_row, true)[1]
			opts.range = {
				start = { start_row, 0 },
				["end"] = { end_row, #end_line },
			}
		end
	end

	require("conform").format(opts)
end

return {
	name = "conform",
	src = "https://github.com/stevearc/conform.nvim",
	event = { "BufReadPost", "BufNewFile" },

	install = {
		binaries = {
			"prettier",
			"blade-formatter",
			"stylua",
			"pint",
			"goimports",
			"rustfmt",
			"shfmt",
		},
		packages = {
			npm = { "prettier", "@shufo/blade-formatter" },
			composer = { "laravel/pint", "friendsofphp/php-cs-fixer" },
			go = { "golang.org/x/tools/cmd/goimports@latest" },
		},
		notes = {
			"rustfmt ships with rustup. shfmt: go install mvdan.cc/sh/v3/cmd/shfmt@latest",
		},
	},

	opts = {
		notify_on_error = true,
		formatters_by_ft = {
			lua = { "stylua" },
			javascript = { "prettier" },
			javascriptreact = { "prettier" },
			typescript = { "prettier" },
			typescriptreact = { "prettier" },
			vue = { "prettier" },
			json = { "prettier" },
			jsonc = { "prettier" },
			css = { "prettier" },
			scss = { "prettier" },
			html = { "prettier" },
			yaml = { "prettier" },
			markdown = { "prettier" },
			blade = { "blade-formatter" },
			php = { "pint", "php_cs_fixer", stop_after_first = true },
			go = { "goimports", "gofmt" },
			rust = { "rustfmt" },
			sh = { "shfmt" },
			bash = { "shfmt" },
			zsh = { "shfmt" },
		},
		format_on_save = function(bufnr)
			local ft = vim.bo[bufnr].filetype
			if ft == "markdown" or ft == "gitcommit" then
				return
			end
			return { timeout_ms = 1500, lsp_format = "fallback" }
		end,
	},

	keys = {
		{
			"<leader>cf",
			format_buffer_or_range,
			mode = { "n", "x" },
			desc = "Format buffer or range",
		},
	},
}
