local M = {}

local notify = require("util.notify")

local function argv()
	return vim.fn.argv()
end

function M.set_current_file_only()
	vim.cmd("args %")
end

function M.show()
	local args = argv()
	if #args == 0 then
		notify.info("Arglist", "No files in arglist")
		return
	end

	local items = {}
	for index, file in ipairs(args) do
		items[#items + 1] = {
			text = file,
			idx = index,
			file = file,
		}
	end

	require("snacks").picker({
		title = "Arglist",
		items = items,
		format = function(item)
			return { { item.text } }
		end,
		confirm = function(picker, item)
			picker:close()
			if item then
				vim.cmd("argument " .. item.idx)
			end
		end,
	})
end

function M.add_current_file()
	vim.cmd("argedit %")
end

function M.remove_file()
	local args = argv()
	if #args == 0 then
		notify.info("Arglist", "No files in arglist")
		return
	end

	vim.ui.select(args, { prompt = "Remove from arglist:" }, function(choice)
		if not choice then
			return
		end
		vim.cmd("argdelete " .. vim.fn.fnameescape(choice))
		notify.info("Arglist", "Removed " .. choice)
	end)
end

return M
