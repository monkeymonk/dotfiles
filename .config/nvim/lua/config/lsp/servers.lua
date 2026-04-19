local stubs = require("config.php_stubs")

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
		cmd = { "intelephense", "--stdio" },
		filetypes = { "php", "blade" },
		root_markers = { "composer.json", ".git" },
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
