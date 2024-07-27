local M = {}

function M.desc(desc, opts)
  local options = {
    desc = desc,
    noremap = true,
    silent = true,
  }

  if opts then
    for key, value in pairs(opts) do
      options[key] = value
    end
  end

  return options
end

local function splitModes(modes)
  local modeList = {}
  for mode in modes:gmatch(".") do
    table.insert(modeList, mode)
  end
  return modeList
end

function M.bind(modes, keys, action, options)
  if type(modes) == "string" then
    modes = splitModes(modes)
  end

  options = options or {}

  for _, mode in ipairs(modes) do
    vim.api.nvim_set_keymap(mode, keys, action, options)
  end
end

function M.unbind(modes, keys)
  if type(modes) == "string" then
    modes = splitModes(modes)
  end

  for _, mode in ipairs(modes) do
    vim.api.nvim_del_keymap(mode, keys)
  end
end

function M.which_key(opts)
  require("which-key").add(opts)
end

return M
