local function patch_deprecated_client_calls(client)
	local methods = getmetatable(client).__index

	client.request = function(first, ...)
		if first == client then
			return methods.request(client, ...)
		end
		return methods.request(client, first, ...)
	end

	client.request_sync = function(first, ...)
		if first == client then
			return methods.request_sync(client, ...)
		end
		return methods.request_sync(client, first, ...)
	end
end

return {
	name = "tailwind-tools",
	src = "https://github.com/luckasRanarison/tailwind-tools.nvim",
	lazy = false,

	config = function()
		vim.api.nvim_create_autocmd("LspAttach", {
			callback = function(args)
				local client = vim.lsp.get_client_by_id(args.data.client_id)
				if client and client.name == "tailwindcss" then
					patch_deprecated_client_calls(client)
					require("tailwind-tools").setup({
						conceal = {
							symbol = "…",
						},
					})
					return true
				end
			end,
		})
	end,
}
