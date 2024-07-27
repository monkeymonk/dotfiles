local M = {}

local ns_id = vim.api.nvim_create_namespace("duplicate-lines")

function M.clear_highlights()
  vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
end

function M.highlight_duplicates(cfg)
  M.clear_highlights()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local duplicates = {}
  local line_count = {}

  for i, line in ipairs(lines) do
    if line_count[line] then
      table.insert(line_count[line], i)
      duplicates[line] = true
    else
      line_count[line] = { i }
    end
  end

  local duplicate_count = 0
  for line, _ in pairs(duplicates) do
    duplicate_count = duplicate_count + 1
    for _, index in ipairs(line_count[line]) do
      vim.api.nvim_buf_add_highlight(0, ns_id, cfg.highlight_group, index - 1, 0, -1)
    end
  end

  vim.notify(duplicate_count .. " duplicate lines found", vim.log.levels.INFO)
end

function M.show_duplicates_in_quickfix()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local line_count = {}
  local qf = {}

  for i, line in ipairs(lines) do
    if line_count[line] then
      table.insert(line_count[line], i)
    else
      line_count[line] = { i }
    end
  end

  for line, indexes in pairs(line_count) do
    if #indexes > 1 then
      for _, index in ipairs(indexes) do
        table.insert(qf, {
          bufnr = vim.api.nvim_get_current_buf(),
          lnum = index,
          text = line,
        })
      end
    end
  end

  vim.fn.setqflist(qf)
  vim.cmd("copen")
end

return M
