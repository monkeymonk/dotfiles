return {
	name = "log-highlight",
	src = "https://github.com/fei6409/log-highlight.nvim",
	ft = "log",

	setup = function()
		require("log-highlight").setup({})

		-- Large file optimizations for log files
		local large_file_threshold = 1024 * 1024 -- 1 MB

		vim.api.nvim_create_autocmd("BufReadPre", {
			group = vim.api.nvim_create_augroup("user_log_largefile", { clear = true }),
			pattern = { "*.log", "*.log.*" },
			callback = function(args)
				local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(args.buf))
				if not ok or not stats then
					return
				end
				if stats.size > large_file_threshold then
					vim.b[args.buf].large_log = true
					vim.opt_local.swapfile = false
					vim.opt_local.undolevels = -1
					vim.opt_local.undoreload = 0
					vim.opt_local.list = false
					vim.opt_local.foldmethod = "manual"
					vim.opt_local.number = false
					vim.opt_local.relativenumber = false
					vim.opt_local.signcolumn = "no"
					vim.opt_local.statuscolumn = ""
					vim.opt_local.cursorline = false
				end
			end,
		})

		vim.api.nvim_create_autocmd("BufReadPost", {
			group = vim.api.nvim_create_augroup("user_log_largefile_post", { clear = true }),
			pattern = { "*.log", "*.log.*" },
			callback = function(args)
				if vim.b[args.buf].large_log then
					vim.treesitter.stop(args.buf)
					vim.bo[args.buf].syntax = ""
				end
			end,
		})
	end,
}
