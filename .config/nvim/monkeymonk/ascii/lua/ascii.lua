local M = {}
local config = {}
local ascii = nil
local library = nil

function M.setup(opts)
  -- Load dependencies when setup is called (after rtp is configured)
  if not library then
    library = require("library")
    config.library = library
  end
  if not ascii then
    ascii = require("utils")
  end
  if opts ~= nil then
    config = vim.tbl_extend("force", config, opts)
  end

  M.registerCommands()
end

-- Expose the commands directly
function M.getRandomArt()
  -- Ensure dependencies are loaded
  if not ascii or not config.library then
    M.setup()
  end
  return ascii.getRandomArt(config.library)
end

function M.getArtByName(name)
  -- Ensure dependencies are loaded
  if not ascii or not config.library then
    M.setup()
  end
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
