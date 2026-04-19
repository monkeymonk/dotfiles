local M = {}

local notify = require("util.notify")
local uv = vim.uv

local function file_exists(path)
	local stat = uv.fs_stat(path)
	return stat and stat.type == "file"
end

local function is_dir(path)
	local stat = uv.fs_stat(path)
	return stat and stat.type == "directory"
end

local function find_views_root(start_file)
	local dir = vim.fn.fnamemodify(start_file, ":p:h")
	while dir and dir ~= "/" do
		local candidate = dir .. "/resources/views"
		if is_dir(candidate) then
			return candidate
		end
		dir = vim.fn.fnamemodify(dir, ":h")
	end
end

local function lsp_definition(bufnr)
	for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
		if client:supports_method("textDocument/definition") then
			local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
			local results = vim.lsp.buf_request_sync(bufnr, "textDocument/definition", params, 150)
			if results then
				for _, res in pairs(results) do
					local def = res.result
					if def then
						local loc = vim.islist(def) and def[1] or def
						vim.lsp.util.jump_to_location(loc, client.offset_encoding)
						return true
					end
				end
			end
		end
	end

	return false
end

local function quoted_view_token(line, col)
	local cursor = col + 1

	for _, quote in ipairs({ "'", '"' }) do
		local left
		local right

		for idx = cursor, 1, -1 do
			if line:sub(idx, idx) == quote and (idx == 1 or line:sub(idx - 1, idx - 1) ~= "\\") then
				left = idx
				break
			end
		end

		if left then
			for idx = cursor + 1, #line do
				if line:sub(idx, idx) == quote and line:sub(idx - 1, idx - 1) ~= "\\" then
					right = idx
					break
				end
			end
		end

		if left and right and left < cursor + 1 then
			local before = line:sub(1, left - 1)
			local inside = line:sub(left + 1, right - 1)

			if before:match("@include%w*%s*%($")
				or before:match("@extends%w*%s*%($")
				or before:match("@component%w*%s*%($")
				or before:match("@each%w*%s*%($")
				or before:match("@includeIf%w*%s*%($")
				or before:match("@includeWhen%w*%s*%($")
				or before:match("@includeFirst%w*%s*%($")
				or before:match("view%s*%($")
			then
				return inside, "view"
			end
		end
	end
end

local function component_token(line, col)
	local left = line:sub(1, col + 1)
	local start_idx = left:match(".*()<x[%w%-%._:]*")
	if not start_idx then
		return
	end

	local after = line:sub(start_idx + 1)
	local name = after:match("^<([xX][%w%-%._:]+)")
	if name then
		return name, "component"
	end
end

local function resolve_target(views_root, token, kind)
	if kind == "view" then
		local rel = token:gsub("%.", "/")
		local blade_file = ("%s/%s.blade.php"):format(views_root, rel)
		local php_file = ("%s/%s.php"):format(views_root, rel)

		if file_exists(blade_file) then
			return blade_file
		end
		if file_exists(php_file) then
			return php_file
		end

		local matches = vim.fn.glob(("%s/%s*.blade.php"):format(views_root, rel), false, true)
		return matches and matches[1] or nil
	end

	local name = token:gsub("^x[-:]", ""):gsub("^x", ""):gsub("::", "/"):gsub("%.", "/")
	local component_file = ("%s/components/%s.blade.php"):format(views_root, name)

	if file_exists(component_file) then
		return component_file
	end

	local matches = vim.fn.glob(("%s/components/%s*.blade.php"):format(views_root, name), false, true)
	return matches and matches[1] or nil
end

function M.goto_blade_target()
	local bufnr = vim.api.nvim_get_current_buf()
	local file = vim.api.nvim_buf_get_name(bufnr)
	if file == "" then
		notify.warn("Blade", "Current buffer has no file on disk")
		return
	end

	if lsp_definition(bufnr) then
		return
	end

	local views_root = find_views_root(file)
	if not views_root then
		notify.warn("Blade", "Couldn't locate resources/views")
		return
	end

	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local line = vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)[1] or ""

	local token, kind = quoted_view_token(line, col)
	if not token then
		token, kind = component_token(line, col)
	end

	if not token then
		notify.warn("Blade", "No view or component under cursor")
		return
	end

	local path = resolve_target(views_root, token, kind)
	if not path then
		notify.warn("Blade", ("View not found for '%s'"):format(token))
		return
	end

	vim.cmd("edit " .. vim.fn.fnameescape(path))
end

return M
