return {
	name = "snacks",
	src = "https://github.com/folke/snacks.nvim",
	dependencies = {
		"https://github.com/echasnovski/mini.icons",
	},

	setup = function()
		local db = require("util.dashboard")

		require("mini.icons").setup()
		require("snacks").setup({
			dashboard = {
				sections = {
					function()
						local lines = db.random_art()
						return { header = table.concat(lines, "\n"), padding = 2 }
					end,
					{ section = "keys", gap = 1, padding = 1 },
					function()
						return {
							text = { " " .. db.random_tip(), hl = "Comment" },
							padding = { 1, 0 },
						}
					end,
				},
			},
			explorer = {
				replace_netrw = true,
			},
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
								-- Select the visual range in the picker
								for i = from, to do
									local item = picker.list:get(i)
									if item then
										picker.list:set_selected(i, true)
									end
								end
								-- Escape visual mode then trigger the built-in delete
								vim.cmd("normal! " .. vim.api.nvim_replace_termcodes("<Esc>", true, false, true))
								picker:action("explorer_del")
							end,
						},
						win = {
							list = {
								keys = {
									["d"] = {
										"explorer_del_visual",
										mode = { "x" },
									},
								},
							},
						},
					},
				},
			},
			scope = {},
		})

		-- Show dashboard when all real buffers are closed
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
							-- Skip empty unnamed buffers and dashboard buffers
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

		-- File group (<leader>f)
		map.n("<leader>ff", pickers.files, "Find files")

		map.n("<leader>fo", pickers.recent, "Recent files")

		map.n("<leader>fb", pickers.buffers, "Buffers")

		-- Search group (<leader>s)
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
