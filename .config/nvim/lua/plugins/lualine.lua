return {
	name = "lualine",
	src = "https://github.com/nvim-lualine/lualine.nvim",
	dependencies = {
		"echasnovski/mini.icons",
	},

	config = function()
		require("lualine").setup({
			options = {
				theme = "auto",
				globalstatus = true,
				component_separators = { left = "", right = "" },
				section_separators = { left = "", right = "" },
			},
			sections = {
				lualine_a = {
					"mode",
					function()
						local recording = vim.fn.reg_recording()
						return recording ~= "" and ("REC @" .. recording) or ""
					end,
				},
				lualine_b = { "branch", "diff" },
				lualine_c = { { "filename", path = 1 } },
				lualine_x = {
					-- lualine loads independently of codecompanion, so require
					-- lazily and stay silent when nothing has set it up.
					function()
						local ok, ai_status = pcall(require, "util.ai_status")
						return ok and ai_status.lualine() or ""
					end,
					"diagnostics",
					"filetype",
				},
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},
		})
	end,
}
