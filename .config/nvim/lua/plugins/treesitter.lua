return {
	name = "treesitter",
	src = "https://github.com/nvim-treesitter/nvim-treesitter",
	build = "TSUpdate",
	dependencies = {
		"https://github.com/EmranMR/tree-sitter-blade",
	},

	install = {
		notes = {
			"Parsers install automatically when you open a supported filetype.",
			"Run :TSUpdate after plugin updates if parser queries drift.",
		},
	},

	setup = function()
		local ts = require("nvim-treesitter")
		local installing = {}
		local starter_parsers = {
			"bash",
			"blade",
			"css",
			"dockerfile",
			"gdscript",
			"gdshader",
			"go",
			"gomod",
			"gosum",
			"gowork",
			"html",
			"javascript",
			"json",
			"lua",
			"markdown",
			"markdown_inline",
			"php",
			"python",
			"query",
			"rust",
			"tsx",
			"typescript",
			"vim",
			"vimdoc",
			"yaml",
		}

		ts.setup({})

		-- Blade uses its own filetype but the parser is named the same.
		pcall(vim.treesitter.language.register, "blade", "blade")
		ts.install(starter_parsers)

		local function ensure_parser(bufnr)
			local ft = vim.bo[bufnr].filetype
			if ft == "" then
				return
			end

			local lang = vim.treesitter.language.get_lang(ft) or ft
			if not lang or lang == "" then
				return
			end

			if vim.list_contains(ts.get_installed(), lang) then
				pcall(vim.treesitter.start, bufnr, lang)
				return
			end

			if installing[lang] or not vim.list_contains(ts.get_available(), lang) then
				return
			end

			installing[lang] = true
			ts.install(lang)

			local retries = 0
			local timer = vim.uv.new_timer()
			if not timer then
				installing[lang] = nil
				return
			end

			timer:start(750, 750, vim.schedule_wrap(function()
				retries = retries + 1

				if vim.list_contains(ts.get_installed(), lang) then
					installing[lang] = nil
					timer:stop()
					timer:close()
					if vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].filetype == ft then
						pcall(vim.treesitter.start, bufnr, lang)
					end
					return
				end

				if retries >= 40 then
					installing[lang] = nil
					timer:stop()
					timer:close()
				end
			end))
		end

		vim.api.nvim_create_autocmd("FileType", {
			group = vim.api.nvim_create_augroup("user_treesitter", { clear = true }),
			callback = function(args)
				ensure_parser(args.buf)
			end,
		})
	end,
}
