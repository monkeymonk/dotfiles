return {
	name = "tailwind-tools",
	src = "https://github.com/luckasRanarison/tailwind-tools.nvim",
	lazy = true,

	setup = function()
		vim.api.nvim_create_autocmd("LspAttach", {
			callback = function(args)
				local client = vim.lsp.get_client_by_id(args.data.client_id)
				if client and client.name == "tailwindcss" then
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
