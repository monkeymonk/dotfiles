-- Auto-install Mason packages declared by:
--   1. config/lsp/servers.lua  (LSP server names → mason package names)
--   2. each plugin spec's `install.binaries` (formatters, linters, DAP, etc.)
--
-- Runs once on startup; only installs packages Mason knows are missing.
-- Manual entry point: :MasonEnsure
local M = {}

local notify = require("util.notify")

-- LSP `vim.lsp.config()` name → mason package name.
-- This is the same mapping mason-lspconfig publishes upstream.
local LSP_TO_MASON = {
	bashls = "bash-language-server",
	cssls = "css-lsp",
	docker_compose_language_service = "docker-compose-language-service",
	dockerls = "dockerfile-language-server",
	emmet_ls = "emmet-ls",
	gopls = "gopls",
	html = "html-lsp",
	intelephense = "intelephense",
	jsonls = "json-lsp",
	lua_ls = "lua-language-server",
	pyright = "pyright",
	rust_analyzer = "rust-analyzer",
	tailwindcss = "tailwindcss-language-server",
	ts_ls = "typescript-language-server",
	yamlls = "yaml-language-server",
}

-- Bare binary names a plugin spec might declare (in `install.binaries`)
-- that don't match Mason's package id. Anything not listed here is passed
-- through verbatim and Mason will skip what it doesn't recognise.
local BIN_TO_MASON = {
	pint = nil, -- composer-installed, not in Mason
	rustfmt = nil, -- ships with rustup
	goimports = nil, -- go install
	php_cs_fixer = nil,
	["pint or php-cs-fixer"] = nil,
	["bash-language-server"] = "bash-language-server",
}

local function package_names()
	local pkgs, seen = {}, {}
	local function push(name)
		if not name or seen[name] then
			return
		end
		seen[name] = true
		pkgs[#pkgs + 1] = name
	end

	local ok, servers = pcall(require, "config.lsp.servers")
	if ok then
		for server_name in pairs(servers) do
			push(LSP_TO_MASON[server_name])
		end
	end

	local pack_ok, pack = pcall(require, "util.pack")
	if pack_ok then
		local specs = pack.specs()
		for _, spec in ipairs(specs) do
			if spec.install and spec.install.binaries then
				for _, bin in ipairs(spec.install.binaries) do
					local exe = bin:match("^[%w_-]+")
					if BIN_TO_MASON[exe] ~= nil then
						push(BIN_TO_MASON[exe])
					else
						push(exe)
					end
				end
			end
		end
	end

	return pkgs
end

local function install(packages, mode)
	local mr_ok, mr = pcall(require, "mason-registry")
	if not mr_ok then
		notify.warn("mason", "mason-registry not available")
		return
	end

	local function run()
		local installing = 0
		local installed = 0
		local skipped = 0
		local missing = 0

		for _, name in ipairs(packages) do
			local got, pkg = pcall(mr.get_package, name)
			if not got then
				missing = missing + 1
			elseif pkg:is_installed() then
				installed = installed + 1
			else
				if mode == "list" then
					skipped = skipped + 1
					notify.info("mason", "would install: " .. name)
				else
					installing = installing + 1
					pkg:install():on("closed", function()
						vim.schedule(function()
							notify.info("mason", "installed: " .. name)
						end)
					end)
				end
			end
		end

		if mode == "list" then
			notify.info(
				"mason",
				("%d installed, %d to install, %d unknown"):format(installed, skipped, missing)
			)
		elseif installing > 0 then
			notify.info("mason", ("queueing %d package(s); see :Mason for progress"):format(installing))
		end
	end

	if mr.refresh then
		mr.refresh(run)
	else
		run()
	end
end

function M.ensure()
	install(package_names(), "install")
end

function M.dry_run()
	install(package_names(), "list")
end

function M.setup()
	vim.api.nvim_create_user_command("MasonEnsure", M.ensure, {
		desc = "Install all Mason packages declared by LSP/plugin specs",
	})
	vim.api.nvim_create_user_command("MasonEnsureList", M.dry_run, {
		desc = "List Mason packages that would be installed",
	})
end

return M
