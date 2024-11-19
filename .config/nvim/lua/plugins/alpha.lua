return {
  -- a lua powered greeter like vim-startify / dashboard-nvim
  -- https://github.com/goolord/alpha-nvim/
  {
    "goolord/alpha-nvim",
    opts = function()
      local dashboard = require("alpha.themes.dashboard")

      dashboard.section.buttons.val = {}
      dashboard.opts.layout[1].val = 10

      local function ReloadDashboard()
        dashboard.section.header.val = require("ascii").getRandomArt()

        vim.schedule(function()
          dashboard.section.footer.val = require("tips").FetchTip()
          require("alpha").redraw()
        end)
      end

      vim.api.nvim_create_user_command("ReloadDashboard", ReloadDashboard, { nargs = 0 })
      -- vim.defer_fn(ReloadDashboard, 3000)

      local timer = vim.loop.new_timer()

      -- Set key mappings only when in alpha buffer
      vim.api.nvim_create_augroup("AlphaMappings", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          -- Start the timer to call ReloadDashboard every x seconds
          vim.defer_fn(function()
            timer:start(0, 7000, function()
              ReloadDashboard()
            end)
          end, 4000)

          -- Set key mappings in the alpha buffer
          vim.api.nvim_buf_set_keymap(0, "n", "l", "<cmd>Lazy<CR>", { noremap = true, silent = true })
          vim.api.nvim_buf_set_keymap(0, "n", "r", "<cmd>ReloadDashboard<CR>", { noremap = true, silent = true })
          vim.api.nvim_buf_set_keymap(0, "n", "q", "<cmd>qa<CR>", { noremap = true, silent = true })
        end,
        group = "AlphaMappings",
        pattern = "alpha",
      })

      -- Remove key mappings when leaving the Alpha screen (optional)
      vim.api.nvim_create_autocmd("BufLeave", {
        callback = function()
          -- Stop the timer when leaving the alpha buffer
          if timer then
            timer:stop()
            timer:close()
            timer = nil
          end

          vim.api.nvim_buf_del_keymap(0, "n", "l")
          vim.api.nvim_buf_del_keymap(0, "n", "r")
          vim.api.nvim_buf_del_keymap(0, "n", "q")
        end,
        group = "AlphaMappings",
        pattern = "alpha",
      })

      return dashboard
    end,
  },
}
