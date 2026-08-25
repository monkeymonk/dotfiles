-- Explicit Emmet abbreviation expansion, emmet-vim style.
--
-- The completion menu already offers abbreviations (blink's `lsp` source talks
-- to emmet-language-server, so <CR> on the menu entry expands them). This adds
-- the keybind path: expand whatever abbreviation ends at the cursor without
-- opening the menu.
--
-- Both paths go through the same request, so the result is identical: the
-- server extracts the abbreviation, and its textEdit carries LSP snippet
-- tabstops which LuaSnip then drives with <Tab>/<S-Tab>.
local M = {}

local notify = require("util.notify")

local CLIENT = "emmet-language-server"

---@param bufnr integer
---@return vim.lsp.Client?
local function get_client(bufnr)
	return vim.lsp.get_clients({ bufnr = bufnr, name = CLIENT })[1]
end

---Byte offset one past the character the cursor sits on.
---@param line string
---@param col integer byte offset, 0-indexed
---@return integer
local function next_char(line, col)
	if col >= #line then
		return #line
	end
	return math.min(col + 1 + vim.str_utf_end(line, col + 1), #line)
end

---@param bufnr integer
---@param encoding string
---@return lsp.CompletionParams
local function completion_params(bufnr, encoding)
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local line = vim.api.nvim_buf_get_lines(bufnr, row - 1, row, false)[1] or ""

	-- Insert mode: the cursor is already past the abbreviation. Normal mode: it
	-- sits on the last character, which the server would otherwise cut off.
	if not vim.startswith(vim.api.nvim_get_mode().mode, "i") then
		col = next_char(line, col)
	end

	return {
		textDocument = vim.lsp.util.make_text_document_params(bufnr),
		position = { line = row - 1, character = vim.str_utfindex(line, encoding, col, false) },
	}
end

---@param bufnr integer
---@param range lsp.Range
---@param encoding string
---@return string
local function range_text(bufnr, range, encoding)
	local line = vim.api.nvim_buf_get_lines(bufnr, range.start.line, range.start.line + 1, false)[1] or ""
	local from = vim.str_byteindex(line, encoding, range.start.character, false)
	local to = vim.str_byteindex(line, encoding, range["end"].character, false)
	return line:sub(from + 1, to)
end

---Find the item that expands the whole abbreviation, not one of the extra
---snippet suggestions the server appends. Markup items label themselves with
---the abbreviation; stylesheet items label themselves with the expansion and
---put the abbreviation in filterText.
---@param items lsp.CompletionItem[]
---@param abbreviation string
---@return lsp.CompletionItem?
local function pick_item(items, abbreviation)
	for _, item in ipairs(items) do
		if item.textEdit and item.label == abbreviation then
			return item
		end
	end
	for _, item in ipairs(items) do
		if item.textEdit and item.filterText == abbreviation then
			return item
		end
	end
	return items[1]
end

---@param bufnr integer
---@param item lsp.CompletionItem
---@param encoding string
local function apply(bufnr, item, encoding)
	local range = item.textEdit.range
	vim.lsp.util.apply_text_edits({ { range = range, newText = "" } }, bufnr, encoding)

	local line = vim.api.nvim_buf_get_lines(bufnr, range.start.line, range.start.line + 1, false)[1] or ""
	vim.api.nvim_win_set_cursor(0, {
		range.start.line + 1,
		vim.str_byteindex(line, encoding, range.start.character, false),
	})

	if not vim.startswith(vim.api.nvim_get_mode().mode, "i") then
		vim.cmd.startinsert()
	end
	require("luasnip").lsp_expand(item.textEdit.newText)
end

---Expand the Emmet abbreviation ending at the cursor.
function M.expand()
	local bufnr = vim.api.nvim_get_current_buf()
	local client = get_client(bufnr)
	if not client then
		notify.warn("Emmet", "No emmet client attached to this buffer")
		return
	end

	local encoding = client.offset_encoding or "utf-16"
	client:request("textDocument/completion", completion_params(bufnr, encoding), function(err, result)
		if err or not result then
			notify.warn("Emmet", err and err.message or "No abbreviation at cursor")
			return
		end

		local items = result.items or result
		if vim.tbl_isempty(items) or not items[1].textEdit then
			notify.warn("Emmet", "No abbreviation at cursor")
			return
		end

		-- Every item replaces the same range: the abbreviation the server found.
		local abbreviation = range_text(bufnr, items[1].textEdit.range, encoding)
		apply(bufnr, pick_item(items, abbreviation), encoding)
	end, bufnr)
end

function M.setup()
	local map = require("util.map")

	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("user_emmet", { clear = true }),
		callback = function(args)
			local client = vim.lsp.get_client_by_id(args.data.client_id)
			if not client or client.name ~= CLIENT then
				return
			end

			-- Buffer-local, so this only shadows blink's insert-mode <C-y>
			-- (select_and_accept) in emmet buffers, where pressing bare <C-y>
			-- now waits one 'timeoutlen' (300ms) to see if a comma follows.
			map.map("i", "<C-y>,", M.expand, "Emmet expand", { buffer = args.buf })
			map.map("n", "<leader>ce", M.expand, "Emmet expand", { buffer = args.buf })
		end,
	})
end

return M
