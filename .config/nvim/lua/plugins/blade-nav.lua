return {
	name = "blade-nav",
	src = "https://github.com/ricardoramirezr/blade-nav.nvim",
	dependencies = {
		"https://github.com/saghen/blink.cmp",
	},
	ft = { "blade", "php" },

	setup = function()
		require("blade-nav").setup({})

		local group = vim.api.nvim_create_augroup("user_blade_nav_keys", { clear = true })
		vim.api.nvim_create_autocmd("FileType", {
			group = group,
			pattern = { "blade", "php" },
			callback = function(args)
				local function goto_target()
					require("util.blade_nav").goto_blade_target()
				end

				vim.keymap.set("n", "gV", goto_target, {
					buffer = args.buf,
					silent = true,
					desc = "Blade target under cursor",
				})

				vim.keymap.set("n", "<leader>cv", goto_target, {
					buffer = args.buf,
					silent = true,
					desc = "Blade target under cursor",
				})
			end,
		})

		vim.api.nvim_create_user_command("BladeGotoTarget", function()
			require("util.blade_nav").goto_blade_target()
		end, { desc = "Go to Blade view/component under cursor" })
	end,
}
