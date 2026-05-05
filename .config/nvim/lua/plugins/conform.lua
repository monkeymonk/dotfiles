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
}
