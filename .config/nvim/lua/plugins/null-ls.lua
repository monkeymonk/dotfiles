return {
  {
    "nvimtools/none-ls.nvim",
    opts = function()
      local nls = require("null-ls")
      local util = require("null-ls.utils")

      local root = util.get_root()
      local current_file = vim.api.nvim_buf_get_name(0)

      local root_autoload = root .. "/vendor/autoload.php"
      local theme_autoload = nil

      -- Look for a theme autoload file
      local theme_dir = root .. "/web/app/themes/"
      local handle = vim.loop.fs_scandir(theme_dir)
      if handle then
        while true do
          local name, type = vim.loop.fs_scandir_next(handle)
          if not name then
            break
          end
          if type == "directory" then
            local candidate = theme_dir .. name .. "/vendor/autoload.php"
            if vim.fn.filereadable(candidate) == 1 then
              if current_file:match("/themes/" .. name .. "/") then
                theme_autoload = candidate
                break
              end
            end
          end
        end
      end

      local autoload_file = theme_autoload or (vim.fn.filereadable(root_autoload) == 1 and root_autoload or nil)

      local extra_args = { "--memory-limit=2G" }
      if autoload_file then
        table.insert(extra_args, "--autoload-file=" .. autoload_file)
      end

      return {
        sources = {
          nls.builtins.diagnostics.phpstan.with({
            extra_args = extra_args,
          }),
        },
      }
    end,
  },
}
