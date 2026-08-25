local stubs = require("config.php_stubs")

local function mise_node_bin()
	local config = vim.fn.expand("~/.config/mise/config.toml")
	local ok, lines = pcall(vim.fn.readfile, config)
	if ok then
		for _, line in ipairs(lines) do
			local version = line:match('^%s*node%s*=%s*"([^"]+)"')
			if version then
				local node = vim.fn.expand("~/.local/share/mise/installs/node/" .. version .. "/bin/node")
				if vim.fn.executable(node) == 1 then
					return node
				end
			end
		end
	end
end

local function node_bin()
	local node = mise_node_bin()
	if node then
		return node
	end

	node = vim.fn.exepath("node")
	return node ~= "" and node or "node"
end

local function mason_package(path)
	return vim.fn.stdpath("data") .. "/mason/packages/" .. path
end

local function node_cmd(package_path, ...)
	local cmd = { node_bin(), mason_package(package_path) }
	for i = 1, select("#", ...) do
		cmd[#cmd + 1] = select(i, ...)
	end
	return cmd
end

local function buffer_dir(bufnr)
	local name = vim.api.nvim_buf_get_name(bufnr)
	return name ~= "" and vim.fs.dirname(name) or vim.uv.cwd()
end

local function has_file(dir, path)
	return vim.uv.fs_stat(dir .. "/" .. path) ~= nil
end

local function node_module_root(start, module_path)
	local dir = start
	while dir do
		if has_file(dir, "node_modules/" .. module_path) then
			return dir
		end

		local parent = vim.fs.dirname(dir)
		if parent == dir then
			return nil
		end
		dir = parent
	end
end

local tailwind_config_files = {
	"tailwind.config.js",
	"tailwind.config.cjs",
	"tailwind.config.mjs",
	"tailwind.config.ts",
	"tailwind.config.cts",
	"tailwind.config.mts",
}

local function tailwind_root_dir(bufnr, on_dir)
	local start = buffer_dir(bufnr)
	local dependency_root = node_module_root(start, "tailwindcss/package.json")
	if not dependency_root then
		return
	end

	on_dir(vim.fs.root(start, tailwind_config_files) or dependency_root)
end

local function vue_tsserver_handler(client)
	local retries = 0

	return function(_, result, context)
		local ts_client = vim.lsp.get_clients({ bufnr = context.bufnr, name = "ts_ls" })[1]
		if not ts_client then
			if retries <= 10 then
				retries = retries + 1
				vim.defer_fn(function()
					client.handlers["tsserver/request"](_, result, context)
				end, 100)
			else
				vim.notify("vue_ls requires ts_ls for TypeScript support in .vue files.", vim.log.levels.ERROR)
			end
			return
		end

		local param = unpack(result)
		local id, command, payload = unpack(param)
		ts_client:exec_cmd({
			title = "vue_request_forward",
			command = "typescript.tsserverRequest",
			arguments = { command, payload },
		}, { bufnr = context.bufnr }, function(_, response)
			client:notify("tsserver/response", { { id, response and response.body } })
		end)
	end
end

return {
	lua_ls = {
		cmd = { "lua-language-server" },
		filetypes = { "lua" },
		root_markers = { ".luarc.json", ".luarc.jsonc", "stylua.toml", ".stylua.toml", ".git" },
		settings = {
			Lua = {
				completion = {
					callSnippet = "Replace",
				},
				diagnostics = {
					globals = { "vim" },
				},
				workspace = {
					checkThirdParty = false,
				},
			},
		},
	},

	intelephense = {
		cmd = {
			node_bin(),
			mason_package("intelephense/node_modules/intelephense/lib/intelephense.js"),
			"--stdio",
		},
		filetypes = { "php", "blade" },
		get_language_id = function()
			return "php"
		end,
		root_markers = { "composer.json", "artisan", "wp-config.php", ".git" },
		-- Re-resolve stub paths per client. The value below is captured when this
		-- module is first required, so a :PhpStubsInstall run later in the session
		-- would otherwise never reach a newly started server. Mutated in place:
		-- client.settings aliases config.settings, so reassigning it has no effect.
		before_init = function(_, config)
			config.settings.intelephense.environment.includePaths = stubs.get_stub_paths()
		end,
		settings = {
			intelephense = {
				environment = {
					includePaths = stubs.get_stub_paths(),
				},
				files = {
					associations = { "*.php", "*.blade.php" },
					-- wordpress-stubs.php is one ~5.8MB file and grows every release.
					-- Anything under its size makes intelephense skip it silently,
					-- which reads as "WordPress functions are all undefined".
					maxSize = 20000000,
				},
			},
		},
	},

	ts_ls = {
		cmd = node_cmd("typescript-language-server/node_modules/typescript-language-server/lib/cli.mjs", "--stdio"),
		filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "vue" },
		root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
		init_options = {
			plugins = {
				{
					name = "@vue/typescript-plugin",
					location = mason_package("vue-language-server/node_modules/@vue/language-server"),
					languages = { "vue" },
				},
			},
		},
	},

	vue_ls = {
		cmd = node_cmd("vue-language-server/node_modules/@vue/language-server/bin/vue-language-server.js", "--stdio"),
		filetypes = { "vue" },
		root_markers = { "package.json" },
		on_init = function(client)
			client.handlers["tsserver/request"] = vue_tsserver_handler(client)
		end,
	},

	tailwindcss = {
		cmd = node_cmd(
			"tailwindcss-language-server/node_modules/@tailwindcss/language-server/bin/tailwindcss-language-server",
			"--stdio"
		),
		filetypes = {
			"html",
			"css",
			"scss",
			"javascript",
			"javascriptreact",
			"typescript",
			"typescriptreact",
			"vue",
			"svelte",
			"php",
			"blade",
		},
		root_dir = tailwind_root_dir,
	},

	gopls = {
		cmd = { "gopls" },
		filetypes = { "go", "gomod", "gowork", "gotmpl" },
		root_markers = { "go.mod", "go.work", ".git" },
	},

	rust_analyzer = {
		cmd = { "rust-analyzer" },
		filetypes = { "rust" },
		root_markers = { "Cargo.toml", "rust-project.json", ".git" },
		settings = {
			["rust-analyzer"] = {
				check = {
					command = "clippy",
				},
			},
		},
	},

	bashls = {
		cmd = { "bash-language-server", "start" },
		filetypes = { "sh", "bash", "zsh" },
		root_markers = { ".git" },
	},

	-- Key must stay hyphenated: blink.cmp gates its emmet ranking fix on
	-- `client.name == "emmet-language-server"` (sources/lsp/completion.lua).
	-- With the lspconfig-style underscore name the fix never runs and emmet
	-- items outrank real LSP completions.
	["emmet-language-server"] = {
		cmd = node_cmd("emmet-language-server/node_modules/@olrtg/emmet-language-server/dist/index.js", "--stdio"),
		filetypes = {
			"astro",
			"blade",
			"css",
			"eruby",
			"html",
			"htmldjango",
			"javascriptreact",
			"less",
			"pug",
			"sass",
			"scss",
			"svelte",
			"typescriptreact",
			"vue",
		},
		root_markers = { "package.json", "composer.json", ".git" },
		-- Read once at initialize; the server has no didChangeConfiguration
		-- handler, so changing these needs an LSP restart.
		init_options = {
			showExpandedAbbreviation = "always",
			-- Server-side default is false (the `true` default comes from
			-- nvim-lspconfig, which we don't use). Without it the menu only
			-- offers the expansion, not `a:link`-style abbreviation suggestions.
			showAbbreviationSuggestions = true,
			-- Items carry no CompletionItemKind otherwise.
			showSuggestionsAsSnippets = true,
			-- Deliberately empty: an entry here overrides the server's
			-- <style>-tag detection for that filetype, which kills CSS
			-- abbreviations inside <style> blocks. Unknown filetypes
			-- (blade, astro, svelte, eruby, htmldjango) already fall back to
			-- html on their own.
			includeLanguages = {},
		},
	},

	pyright = {
		cmd = { "pyright-langserver", "--stdio" },
		filetypes = { "python" },
		root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "pyrightconfig.json", ".git" },
		settings = {
			python = {
				analysis = {
					autoSearchPaths = true,
					useLibraryCodeForTypes = true,
				},
			},
		},
	},

	cssls = {
		cmd = { "vscode-css-language-server", "--stdio" },
		filetypes = { "css", "scss", "less" },
		root_markers = { "package.json", ".git" },
		settings = {
			css = { lint = { unknownAtRules = "ignore" } },
			scss = { lint = { unknownAtRules = "ignore" } },
		},
	},

	html = {
		cmd = { "vscode-html-language-server", "--stdio" },
		filetypes = { "html" },
		root_markers = { "package.json", ".git" },
	},

	jsonls = {
		cmd = { "vscode-json-language-server", "--stdio" },
		filetypes = { "json", "jsonc" },
		root_markers = { ".git" },
	},

	yamlls = {
		cmd = { "yaml-language-server", "--stdio" },
		filetypes = { "yaml", "yaml.docker-compose" },
		root_markers = { ".git" },
	},

	dockerls = {
		cmd = { "docker-langserver", "--stdio" },
		filetypes = { "dockerfile" },
		root_markers = { "Dockerfile", ".git" },
	},

	docker_compose_language_service = {
		cmd = { "docker-compose-langserver", "--stdio" },
		filetypes = { "yaml.docker-compose" },
		root_markers = { "docker-compose.yml", "docker-compose.yaml", "compose.yml", "compose.yaml", ".git" },
	},
}
