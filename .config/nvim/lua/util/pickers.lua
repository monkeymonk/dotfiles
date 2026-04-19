local M = {}

local function snacks()
	return require("snacks")
end

local function as_list(value)
	if value == nil then
		return {}
	end
	return type(value) == "table" and vim.deepcopy(value) or { value }
end

local function parse_grep_query(input)
	if not input or input == "" then
		return {
			search = input or "",
			glob = {},
			exclude = {},
		}
	end

	local pattern, filters = input:match("^(.-)%s+%-%-%s+(.+)$")
	if not filters then
		return {
			search = input,
			glob = {},
			exclude = {},
		}
	end

	local parsed = {
		search = vim.trim(pattern),
		glob = {},
		exclude = {},
	}

	for token in filters:gmatch("%S+") do
		if token ~= "--" then
			if token:sub(1, 1) == "!" and #token > 1 then
				parsed.exclude[#parsed.exclude + 1] = token:sub(2)
			else
				parsed.glob[#parsed.glob + 1] = token
			end
		end
	end

	return parsed
end

local function grep_finder(opts, ctx)
	local parsed = parse_grep_query(ctx.filter.search)
	local grep = require("snacks.picker.source.grep").grep
	local merged = vim.tbl_deep_extend("force", {}, opts, {
		glob = vim.list_extend(as_list(opts.glob), parsed.glob),
		exclude = vim.list_extend(as_list(opts.exclude), parsed.exclude),
	})
	local filter = ctx.filter:clone()
	filter.search = parsed.search
	local grep_ctx = setmetatable({ filter = filter }, { __index = ctx })
	return grep(merged, grep_ctx)
end

function M.explorer()
	snacks().explorer()
end

function M.files()
	snacks().picker.files()
end

function M.recent()
	snacks().picker.recent()
end

function M.buffers()
	snacks().picker.buffers()
end

function M.grep(opts)
	opts = opts or {}
	snacks().picker.grep(vim.tbl_deep_extend("force", {
		finder = grep_finder,
	}, opts))
end

function M.grep_word()
	snacks().picker.grep_word()
end

function M.help()
	snacks().picker.help()
end

function M.lsp_symbols()
	snacks().picker.lsp_symbols()
end

function M.diagnostics()
	snacks().picker.diagnostics()
end

return M
