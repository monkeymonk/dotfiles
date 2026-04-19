local servers = require("config.lsp.servers")

local capabilities = vim.lsp.protocol.make_client_capabilities()
pcall(function()
	capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)
end)

local function setup_gdscript()
	-- gdscript uses TCP to connect to the running Godot editor; Mason does not manage it.
	vim.lsp.config("gdscript", {
		cmd = vim.lsp.rpc.connect("127.0.0.1", tonumber(os.getenv("GDScript_Port")) or 6005),
		filetypes = { "gdscript" },
		root_markers = { "project.godot" },
		capabilities = capabilities,
		on_attach = function(client)
			-- Godot does not handle didClose well.
			local notify = client.notify
			client.notify = function(method, params)
				if method == "textDocument/didClose" then
					return
				end
				notify(method, params)
			end
		end,
	})
	vim.lsp.enable("gdscript")
end

local function setup_servers()
	for name, conf in pairs(servers) do
		conf.capabilities = capabilities
		vim.lsp.config(name, conf)
	end
end

local function sorted_server_names()
	local names = vim.tbl_keys(servers)
	table.sort(names)
	return names
end

local function setup_mason(server_names)
	local mason_ok, mason = pcall(require, "mason")
	local mason_lspconfig_ok, mason_lspconfig = pcall(require, "mason-lspconfig")

	if mason_ok then
		mason.setup({
			ui = {
				border = "rounded",
			},
		})
	end

	if mason_ok and mason_lspconfig_ok then
		mason_lspconfig.setup({
			automatic_enable = server_names,
		})
		return
	end

	for _, name in ipairs(server_names) do
		vim.lsp.enable(name)
	end
end

require("config.lsp.commands").setup()
setup_gdscript()
setup_servers()
setup_mason(sorted_server_names())
