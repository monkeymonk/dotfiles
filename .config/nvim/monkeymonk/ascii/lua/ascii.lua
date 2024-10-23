local config = {
  library = require("library"),
}
local M = {}
local ascii = require("utils")

function M.setup(opts)
  if opts ~= nil then
    config = vim.tbl_extend("force", config, opts)
  end

  M.registerCommands()
end

-- Expose the commands directly
function M.getRandomArt()
  return ascii.getRandomArt(config.library)
end

function M.getArtByName(name)
  return ascii.getArtByName(name, config.library)
end

-- Register commands
function M.registerCommands()
  vim.api.nvim_create_user_command("RandomArt", function()
    print(M.getRandomArt())
  end, {})

  vim.api.nvim_create_user_command("ArtByName", function(params)
    print(M.getArtByName(params.args))
  end, {
    nargs = 1,
  })
end

return M
