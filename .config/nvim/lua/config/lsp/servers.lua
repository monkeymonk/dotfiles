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
		settings = {
			intelephense = {
				environment = {
					includePaths = stubs.get_stub_paths(),
				},
				files = {
					associations = { "*.php", "*.blade.php" },
					maxSize = 5000000,
				},
			},
		},
	},

	ts_ls = {
		cmd = { "typescript-language-server", "--stdio" },
		filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
		root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
	},

	tailwindcss = {
		cmd = { "tailwindcss-language-server", "--stdio" },
		filetypes = { "html", "css", "scss", "javascript", "javascriptreact", "typescript", "typescriptreact", "vue", "svelte", "php", "blade" },
		root_markers = { "tailwind.config.js", "tailwind.config.ts", "postcss.config.js", "package.json", ".git" },
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

	emmet_ls = {
		cmd = { "emmet-ls", "--stdio" },
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
		root_markers = { "package.json", ".git" },
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
