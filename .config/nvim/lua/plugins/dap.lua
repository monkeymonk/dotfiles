return {
  -- mason-nvim-dap bridges mason.nvim with the nvim-dap plugin - making it easier to use both plugins together.
  -- https://github.com/jay-babu/mason-nvim-dap.nvim
  {
    "jay-babu/mason-nvim-dap.nvim",
    cmd = { "DapInstall", "DapUninstall" },
    dependencies = "mason.nvim",
    opts = {
      -- Makes a best effort to setup the various debuggers with
      -- reasonable debug configurations
      automatic_setup = true,
      -- You can provide additional configuration to the handlers,
      -- see mason-nvim-dap README for more information
      handlers = {
        function(config)
          -- all sources with no handler get passed here

          -- Keep original functionality
          require("mason-nvim-dap").default_setup(config)
        end,
        php = function(config)
          config.configurations = {
            {
              type = "php",
              request = "launch",
              name = "Listen for Xdebug",
              port = 9003,
              pathMappings = {
                -- For some reason xdebug sometimes fails for me, depending on me
                -- using herd or docker. To get it to work, change the order of the mappings.
                -- The first mapping should be the one that you are actively using.
                -- This only started recently, so I don't know what changed.
                ["${workspaceFolder}"] = "${workspaceFolder}",
                ["/var/www/html"] = "${workspaceFolder}",
              },
            },
          }
          require("mason-nvim-dap").default_setup(config) -- don't forget this!
        end,
      },
      -- You'll need to check that you have the required things installed
      -- online, please don't ask me how to install them :)
      ensure_installed = {
        -- Update this to ensure that you have the debuggers for the langs you want
        "php",
        "bash",
        "python",
      },
    },
  },

  -- 🦆 A NeoVim plugin for managing several debuggers for Nvim-dap
  -- https://github.com/ravenxrz/DAPInstall.nvim
  {
    "Pocco81/DAPInstall.nvim",
    cmd = { "DIInstall", "DIUninstall", "DIList" },
  },

  -- This plugin adds virtual text support to nvim-dap. nvim-treesitter is used to find variable definitions.
  -- https://github.com/theHamsta/nvim-dap-virtual-text
  {
    "theHamsta/nvim-dap-virtual-text",
    dependencies = "mfussenegger/nvim-dap",
    config = function(_, opts)
      require("nvim-dap-virtual-text").setup(opts)
    end,
    lazy = true, -- Loads when nvim-dap loads
  },

  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "mason-org/mason.nvim",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      dapui.setup()
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
  },
}
