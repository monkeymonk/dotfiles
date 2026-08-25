return {
	name = "window-picker",
	src = "https://github.com/s1n7ax/nvim-window-picker",
	lazy = true,

	config = function()
		require("window-picker").setup({
			hint = "floating-big-letter",
			filter_rules = {
				autoselect_one = true,
				include_current_win = false,
				bo = {
					filetype = { "NvimTree", "neo-tree", "notify", "snacks_notif", "snacks_explorer" },
					buftype = { "terminal" },
				},
			},
		})
	end,

	keys = {
		{
			"<leader>wp",
			function()
				local id = require("window-picker").pick_window()
				if id then
					vim.api.nvim_set_current_win(id)
				end
			end,
			desc = "Pick window",
		},
	},
}
