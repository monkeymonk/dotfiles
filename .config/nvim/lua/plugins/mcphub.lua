return {
	name = "mcphub",
	src = "https://github.com/ravitemer/mcphub.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	lazy = true,

	install = {
		notes = {
			"Run: npm install -g mcp-hub@latest",
			"Requires Node.js to be installed.",
		},
	},

	config = function()
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

	keys = {
		{ "<leader>um", "<cmd>MCPHub<cr>", desc = "MCP Hub" },
	},
}
