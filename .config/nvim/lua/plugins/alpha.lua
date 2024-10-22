return {
  -- a lua powered greeter like vim-startify / dashboard-nvim
  -- https://github.com/goolord/alpha-nvim/
  {
    "goolord/alpha-nvim",
    keys = {
      { "r", "<cmd> ReloadDashboard <CR>" },
      { "q", "<cmd> qa <CR>" }, -- allow to quit from alpha screen
    },
    opts = function()
      local dashboard = require("alpha.themes.dashboard")

      dashboard.section.buttons.val = {}
      dashboard.opts.layout[1].val = 10

      local function ReloadDashboard()
        local ascii = require("monkeymonk.ascii.utils")
        local tips = require("monkeymonk.tips.lua.tips")

        dashboard.section.header.val = ascii.getRandomArt()

        vim.schedule(function()
          dashboard.section.footer.val = tips.FetchTip()
          require("alpha").redraw()
        end)
      end

      vim.api.nvim_create_user_command("ReloadDashboard", ReloadDashboard, { nargs = 0 })
      ReloadDashboard()

      return dashboard
    end,
  },
}
