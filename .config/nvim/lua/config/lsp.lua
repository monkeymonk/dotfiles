local servers = require("config.lsp.servers")

local capabilities = vim.lsp.protocol.make_client_capabilities()
pcall(function()
	capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)
end)

-- gdscript: TCP-only, Mason cannot manage it.
vim.lsp.config("gdscript", {
	cmd = vim.lsp.rpc.connect("127.0.0.1", tonumber(os.getenv("GDScript_Port")) or 6005),
	filetypes = { "gdscript" },
	root_markers = { "project.godot" },
	capabilities = capabilities,
	on_attach = function(client)
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

local names = {}
for name, conf in pairs(servers) do
	conf.capabilities = capabilities
	vim.lsp.config(name, conf)
	names[#names + 1] = name
end
table.sort(names)
vim.lsp.enable(names)
-- mason-lspconfig.setup({ automatic_enable = ... }) runs from lua/plugins/mason.lua
-- after mason.setup(), and re-enables the same servers idempotently.

require("config.lsp.commands").setup()
