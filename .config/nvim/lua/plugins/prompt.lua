return {
	name = "prompt.nvim",
	src = "https://github.com/monkeymonk/prompt.nvim",

	opts = {},

	-- prompt.nvim ships a `prompt-nvim` launcher that terminal AI tools invoke as
	-- their $EDITOR. Copy it onto PATH whenever the plugin installs or updates so
	-- it stays in lockstep with the plugin version (~/.local/bin is on PATH here).
	build = function()
		local src = vim.api.nvim_get_runtime_file("bin/prompt-nvim", false)[1]
		if not src then
			return
		end
		local dst = vim.fn.expand("~/.local/bin/prompt-nvim")
		vim.fn.mkdir(vim.fn.fnamemodify(dst, ":h"), "p")
		pcall(os.remove, dst) -- replace an existing file/symlink instead of writing through it
		vim.uv.fs_copyfile(src, dst)
		vim.uv.fs_chmod(dst, 493) -- 0755
	end,

	install = {
		notes = {
			"Launcher `prompt-nvim` is copied to ~/.local/bin on install/update; keep that on PATH.",
			"Run :checkhealth prompt to verify launcher and connector versions.",
		},
	},
}
