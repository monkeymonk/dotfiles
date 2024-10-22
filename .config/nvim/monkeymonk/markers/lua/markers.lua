local config = {}

local M = {}

function M.setup(opts)
  if opts ~= nil then
    config = vim.tbl_extend("force", config, opts)
  end

  vim.api.nvim_create_user_command("ToggleMark", function()
    M.ToggleMark()
  end, {})

  vim.api.nvim_create_user_command("ClearAllMarks", function()
    M.ClearAllMarks()
  end, {})

  vim.api.nvim_set_keymap("n", "m", "<cmd> ToggleMark <cr>", { desc = "Toggle mark", noremap = true, silent = true })
  vim.api.nvim_set_keymap(
    "n",
    "<leader>mm",
    "<cmd> ToggleMark <cr>",
    { desc = "Toggle mark", noremap = true, silent = true }
  )
  vim.api.nvim_set_keymap(
    "n",
    "<leader>ml",
    "<cmd> Telescope marks <cr>",
    { desc = "List marks", noremap = true, silent = true }
  )
  vim.api.nvim_set_keymap(
    "n",
    "<leader>mx",
    "<cmd> ClearAllMarks <cr>",
    { desc = "Remove all marks", noremap = true, silent = true }
  )
end

function M.ToggleMark()
  -- Enter "waiting" state to capture the next key press for the mark identifier
  local key = vim.fn.getchar()
  local mark = vim.fn.nr2char(key)

  -- Check if the input is a valid mark character (you might want to expand this validation)
  if not string.match(mark, "%w") then
    print("Invalid mark: " .. mark)
    return
  end

  -- Proceed with the existing logic
  local current_line, current_col = unpack(vim.api.nvim_win_get_cursor(0))
  current_col = current_col + 1 -- Adjust column for Vim's 0-indexing in Lua API

  local mark_pos = vim.api.nvim_buf_get_mark(0, mark)
  local mark_line, mark_col = mark_pos[1], mark_pos[2]

  if mark_line ~= 0 or mark_col ~= 0 then
    if mark_line == current_line then
      vim.api.nvim_buf_set_mark(0, mark, 0, 0, {})
      vim.cmd("redraw")
      print("Mark '" .. mark .. "' removed.")
    else
      local buf_name = vim.api.nvim_buf_get_name(0)
      local confirm = vim.fn.input(
        "Mark '"
          .. mark
          .. "' exists in "
          .. buf_name
          .. " at line "
          .. mark_line
          .. ". Use `"
          .. mark
          .. " to go to that mark. Remove? (y/n): "
      )
      if confirm == "y" then
        vim.api.nvim_buf_set_mark(0, mark, 0, 0, {})
        vim.api.nvim_buf_set_mark(0, mark, current_line, current_col, {})
        vim.cmd("redraw")
        print("Mark '" .. mark .. "' replaced.")
      else
        print("Action cancelled.")
      end
    end
  else
    vim.api.nvim_buf_set_mark(0, mark, current_line, current_col, {})
    vim.cmd("redraw")
    print("Mark '" .. mark .. "' set.")
  end
end

function M.ClearAllMarks()
  -- Remove lowercase and uppercase letter marks
  for mark = 97, 122 do -- ASCII 'a' to 'z'
    vim.api.nvim_buf_del_mark(0, string.char(mark))
  end
  for mark = 65, 90 do -- ASCII 'A' to 'Z'
    vim.api.nvim_buf_del_mark(0, string.char(mark))
  end

  -- Remove numbered marks
  for mark = 48, 57 do -- ASCII '0' to '9'
    vim.api.nvim_buf_del_mark(0, string.char(mark))
  end

  vim.cmd("redraw")
  print("All letter and numbered marks removed.")
end

return M
