return {
	name = "mcphub",
	src = "https://github.com/ravitemer/mcphub.nvim",
	dependencies = {
		"https://github.com/nvim-lua/plenary.nvim",
	},
	lazy = true,

	install = {
		notes = {
			"Run: npm install -g mcp-hub@latest",
			"Requires Node.js to be installed.",
		},
	},

	setup = function()
		local node = vim.fn.exepath("node")
		local mcp_hub = vim.fn.exepath("mcp-hub")

		if node == "" or mcp_hub == "" then
			vim.notify("mcphub: node or mcp-hub not found on PATH", vim.log.levels.WARN)
			return
		end

		require("mcphub").setup({
			cmd = node,
			cmdArgs = { mcp_hub },
		})
	end,

	keys = function(map)
		map.n("<leader>um", "<cmd>MCPHub<cr>", "MCP Hub")
	end,
}
