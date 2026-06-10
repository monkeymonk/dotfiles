return {
	name = "snacks",
	src = "https://github.com/folke/snacks.nvim",
	priority = 900,
	dependencies = {
		"https://github.com/echasnovski/mini.icons",
	},

	setup = function()
		local db = require("util.dashboard")

		require("mini.icons").setup()
		require("snacks").setup({
			bigfile = { enabled = true },
			dashboard = {
				sections = {
					function()
						return { header = table.concat(db.random_art(), "\n"), padding = 2 }
					end,
					{ section = "keys", gap = 1, padding = 1 },
					function()
						return { text = { " " .. db.random_tip(), hl = "Comment" }, padding = { 1, 0 } }
					end,
				},
			},
			explorer = { replace_netrw = true },
			indent = {},
			input = {},
			notifier = {},
			picker = {
				actions = {
					send_qf = function(picker)
						local sel = picker:selected()
						local items = #sel > 0 and sel or picker:items()
						picker:close()
						require("util.quicklist").set_qf_from_picker(items)
						require("util.quicklist").open_qf_later()
					end,
				},
				sources = {
					grep = {
						win = {
							input = {
								keys = {
									["<c-q>"] = { "send_qf", mode = { "i", "n" } },
								},
							},
							list = {
								keys = {
									["<c-q>"] = "send_qf",
								},
							},
						},
					},
					explorer = {
						hidden = true,
						ignored = true,
						actions = {
							explorer_del_visual = function(picker)
								local from = vim.fn.line("'<")
								local to = vim.fn.line("'>")
								for i = from, to do
									local item = picker.list:get(i)
									if item then
										picker.list:set_selected(i, true)
									end
								end
								vim.cmd("normal! " .. vim.api.nvim_replace_termcodes("<Esc>", true, false, true))
								picker:action("explorer_del")
							end,
							-- Opening a file prompts for a target split when more than one
							-- editor window is open (snacks' a/s/d/f letter overlay), so
							-- files from the sidebar can land in a specific split.
							explorer_confirm_pick = function(picker, item)
								if item and not item.dir and not picker.input.filter.meta.searching then
									local targets = vim.tbl_filter(function(win)
										local buf = vim.api.nvim_win_get_buf(win)
										return vim.api.nvim_win_get_config(win).relative == ""
											and not vim.bo[buf].filetype:find("^snacks")
									end, vim.api.nvim_tabpage_list_wins(0))
									if #targets > 1 then
										local win = require("snacks.picker.util").pick_win({ main = picker.main })
										if not win then
											return
										end
										picker.main = win
									end
								end
								return picker:action("confirm")
							end,
						},
						win = {
							list = {
								keys = {
									["d"] = { "explorer_del_visual", mode = { "x" } },
									["<CR>"] = "explorer_confirm_pick",
									["l"] = "explorer_confirm_pick",
								},
							},
						},
					},
				},
			},
			scope = {},
			scratch = {},
			words = { enabled = true },
		})

		vim.api.nvim_create_autocmd("BufDelete", {
			group = vim.api.nvim_create_augroup("user_dashboard_reopen", { clear = true }),
			callback = function()
				vim.schedule(function()
					for _, win in ipairs(vim.fn.getwininfo()) do
						if win.quickfix == 1 then
							return
						end
					end
					for _, buf in ipairs(vim.api.nvim_list_bufs()) do
						if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted then
							local name = vim.api.nvim_buf_get_name(buf)
							local ft = vim.bo[buf].filetype
							if name ~= "" and ft ~= "snacks_dashboard" then
								return
							end
						end
					end
					require("snacks").dashboard()
				end)
			end,
		})
	end,

	keys = function(map)
		local pickers = require("util.pickers")

		-- Find / search
		map.n("<leader>ff", pickers.files, "Find files")
		map.n("<leader>fo", pickers.recent, "Recent files")
		map.n("<leader>fb", pickers.buffers, "Buffers")
		map.n("<leader>sf", pickers.files, "Files")
		map.n("<leader>sg", pickers.grep, "Grep")
		map.n("<leader>sw", pickers.grep_word, "Word under cursor")
		map.n("<leader>sb", pickers.buffers, "Buffers")
		map.n("<leader>sh", pickers.help, "Help tags")
		map.n("<leader>so", pickers.recent, "Recent files")
		map.n("<leader>ss", pickers.lsp_symbols, "Document symbols")
		map.n("<leader>sd", pickers.diagnostics, "Diagnostics")
	end,
}
