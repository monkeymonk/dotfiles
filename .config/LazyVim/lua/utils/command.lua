local M = {}

-- Create an alias for a command
-- @param alias The new command name
-- @param cmd The original command it represents
function M.alias(alias, cmd)
  vim.cmd(string.format("command! %s %s", alias, cmd))
end

-- Function to create a single autocmd.
-- @param event The event for which the autocmd should be created
-- @param callback The callback for the given event
-- @param opts The options table for the autocmd, see `:h nvim_create_autocmd`
function M.autocmd(event, callback, opts)
  opts = opts or {}

  if type(opts.group) == "string" then
    local exists, _ = pcall(vim.api.nvim_get_autocmds, { group = opts.group })
    if not exists then
      vim.api.nvim_create_augroup(opts.group, {})
    end
  end

  local options = vim.tbl_extend("force", { callback = callback }, opts or {})
  vim.api.nvim_create_autocmd(event, options)
end

-- Function to create a user command
-- @param name
-- @param callback
-- @param opts
function M.cmd(name, callback, opts)
  local options = vim.tbl_extend("force", {}, opts or {})
  vim.api.nvim_create_user_command(name, function()
    pcall(callback)
  end, options)
end

return M
