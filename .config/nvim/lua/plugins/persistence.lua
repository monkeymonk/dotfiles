return {
	name = "persistence",
	src = "https://github.com/folke/persistence.nvim",

	setup = function()
		local sessions = require("util.sessions")

		require("persistence").setup({
			dir = vim.fn.stdpath("state") .. "/sessions/",
		})

		-- Auto-restore prompt on startup (no file args, no +cmd / -c / -S, no stdin)
		local function launched_bare()
			if vim.fn.argc() ~= 0 then
				return false
			end
			for i = 2, #vim.v.argv do
				local a = vim.v.argv[i]
				if a == "-" or a:sub(1, 1) == "+" or a == "-c" or a == "--cmd" or a == "-S" then
					return false
				end
			end
			return true
		end

		if launched_bare() then
			vim.api.nvim_create_autocmd("UIEnter", {
				once = true,
				callback = function()
					vim.schedule(function()
						local named = sessions.list()
						local has_auto = vim.fn.filereadable(require("persistence").current()) == 1

						if #named == 0 and not has_auto then
							return
						end

						local choices = { "[fresh start]" }
						if has_auto then
							choices[#choices + 1] = "[last session]"
						end
						for _, name in ipairs(named) do
							choices[#choices + 1] = name
						end

						vim.ui.select(choices, {
							prompt = "Restore session?",
						}, function(choice)
							if not choice or choice == "[fresh start]" then
								return
							elseif choice == "[last session]" then
								require("persistence").load()
							else
								sessions.load(choice)
							end
						end)
					end)
				end,
			})
		end
	end,

	keys = function(map)
		map.n("<leader>qn", function()
			vim.ui.input({ prompt = "Session name: " }, function(name)
				if name and name ~= "" then
					require("util.sessions").save(name)
				end
			end)
		end, "Save named session")

		map.n("<leader>qs", function()
			local sessions = require("util.sessions")
			local names = sessions.list()
			if #names == 0 then
				vim.notify("No named sessions for this project", vim.log.levels.INFO)
				return
			end
			vim.ui.select(names, { prompt = "Load session:" }, function(choice)
				if choice then
					sessions.load(choice)
				end
			end)
		end, "Load named session")

		map.n("<leader>qx", function()
			local sessions = require("util.sessions")
			local names = sessions.list()
			if #names == 0 then
				vim.notify("No named sessions for this project", vim.log.levels.INFO)
				return
			end
			vim.ui.select(names, { prompt = "Delete session:" }, function(choice)
				if choice then
					sessions.delete(choice)
				end
			end)
		end, "Delete named session")

		map.n("<leader>qd", function()
			require("persistence").stop()
		end, "Stop session recording")
	end,
}
