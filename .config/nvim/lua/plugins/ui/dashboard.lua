local keymap = require("utils.keymap")
local which_key = keymap.which_key
local bind = keymap.bind
local desc = keymap.desc
local cmd = vim.api.nvim_create_user_command

return {
  -- Alpha plugin configuration
  -- https://github.com/goolord/alpha-nvim
  {
    "goolord/alpha-nvim",
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      -- Localize frequently used modules and settings for performance
      local button = dashboard.button
      dashboard.section.buttons.val = {
        { type = "padding", val = 1 },
        button("n", " > New File", "<cmd> ene <CR>"),
        button("SPC ff", "󰱼 > Find File", "<cmd> Telescope find_files <CR>"),
        button("SPC fr", " > Find Recent Files", "<cmd> Telescope oldfiles <CR>"),
        -- button("SPC fs", "󰊄 > Find File that contain Text", "<cmd> Telescope live_grep <CR>"),
        -- button("SPC pf", " > Find Project", "<cmd> Telescope project <CR>"),
        button("SPC qL", "󰁯 > Load Last Session", "<cmd> lua require('persistence').load({ last = true }) <CR>"),
        -- button("SPC fe", " > Toggle File Explorer", "<cmd> Neotree focus <CR>"),
        button(
          "c",
          " > Configuration",
          "<cmd> lua require('telescope.builtin').find_files({ search_dirs = { vim.fn.stdpath('config') } }) <CR>"
        ),
        button("l", "󰒲 > Lazy", ":Lazy<CR>"),
        -- button("x", "󰒲 > Lazy Extras", ":LazyExtras<CR>"),
        button("q", " > Quit", "<cmd> qa <CR>"),
        { type = "padding", val = 2 },
      }

      local tips = require("tips")

      -- Show a Vim tip
      local function vTipNotify()
        require("notify")(tips.FetchTip(), "info", {
          timeout = 3000,
          title = "Get better with Vim one tip at a time",
        })
      end

      cmd("VTipNotify", vTipNotify, { nargs = 0 })

      -- Function to update the header and footer
      local function reloadDashboard()
        local ascii = require("utils.ascii.utils")
        dashboard.section.header.val = ascii.get_any_random()
        -- dashboard.section.header.val = ascii.get("pig")

        vim.schedule(function()
          dashboard.section.footer.val = tips.FetchTip()
          alpha.redraw()
        end)
      end

      cmd("ReloadDashboard", reloadDashboard, { nargs = 0 })

      local function reloadDashboardPeriodically()
        reloadDashboard() -- Reload the dashboard initially
        local timer = vim.loop.new_timer()
        timer:start(
          0,
          15000,
          vim.schedule_wrap(function()
            reloadDashboard()
          end)
        )
      end

      reloadDashboardPeriodically()

      -- Load the dashboard with the appropriate configurations
      alpha.setup(dashboard.opts)

      -- Disable folding on the alpha buffer
      vim.cmd([[autocmd FileType alpha setlocal nofoldenable]])

      which_key({ "<leader>;", "<cmd> Alpha <CR>", desc = "Dashboard", icon = "", mode = { "n", "v" } })
      -- bind("nv", "<leader>;", "<cmd> Alpha <CR>", desc("Dashboard"))
      bind("nv", "<leader>qd", "<cmd> Alpha <CR>", desc("Dashboard"))
      bind("nv", "<leader>ht", "<cmd> VTipNotify <CR>", desc("Show a Vim/Neovim tip"))
      bind("nv", "<leader>q;", "<cmd> ReloadDashboard <CR>", desc("Reload dashboard"))
    end,
    event = "VimEnter",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      { "MaximilianLloyd/ascii.nvim", dependencies = "MunifTanjim/nui.nvim" },
      { dir = "~/.config/nvim/monkeymonk/tips" },
    },
  },
}
