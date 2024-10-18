-- @TODO: dynamise Godot path/version
return {
  -- Use vim and godot engine to make games
  -- https://github.com/habamax/vim-godot
  {
    "habamax/vim-godot",
    config = function()
      require("lspconfig").gdscript.setup({
        on_attach = function(client)
          local _notify = client.notify
          client.notify = function(method, params)
            if method == "textDocument/didClose" then
              return
            end
            _notify(method, params)
          end
        end,
      })
    end,
    ft = { "gd", "gdscript" },
    init = function()
      vim.g.godot_executable = os.getenv("HOME") .. "/GodotEngine/Godot_v4.3-stable_linux.x86_64"
    end,
  },

  -- Run and debug your Godot game in neovim
  -- https://github.com/Lommix/godot.nvim
  {
    "lommix/godot.nvim",
    ft = { "gd", "gdscript" },
    keys = {
      -- {
      --   "<leader>ogg",
      --   "<cmd>! ~/GodotEngine/Godot_v4.2.2-stable_linux.x86_64<CR>",
      --   desc = "Run Godot",
      --   mode = "n",
      -- },
      {
        "<leader>dGc",
        "<cmd>lua require('godot').debugger.continue()<CR>",
        desc = "Continue Godot Debugger",
        mode = "n",
      },
      {
        "<leader>dGd",
        "<cmd>lua require('godot').debugger.debug()<CR>",
        desc = "Run Godot Debugger",
        mode = "n",
      },
      {
        "<leader>dGD",
        "<cmd>lua require('godot').debugger.debug_at_cursor()<CR>",
        desc = "Run Godot Debugger at Cursor",
        mode = "n",
      },
      {
        "<leader>dGq",
        "<cmd>lua require('godot').debugger.quit()<CR>",
        desc = "Quit Godot Debugger",
        mode = "n",
      },
      {
        "<leader>dGs",
        "<cmd>lua require('godot').debugger.step()<CR>",
        desc = "Step Godot Debugger",
        mode = "n",
      },
    },
    opts = {
      bin = os.getenv("HOME") .. "/GodotEngine/Godot_v4.3-stable_linux.x86_64",
    },
  },

  -- Quickstart configs for Nvim LSP
  -- https://github.com/neovim/nvim-lspconfig
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gdscript = {
          cmd = { "ncat", "localhost", os.getenv("GDScript_Port") or "6005" },
        },
      },
    },
  },

  -- Nvim Treesitter configurations and abstraction layer
  -- https://github.com/nvim-treesitter/nvim-treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "gdscript",
        "godot_resource",
        "gdshader",
      },
    },
  },

  -- mason-nvim-dap bridges mason.nvim with the nvim-dap plugin - making it easier to use both plugins together.
  -- https://github.com/jay-babu/mason-nvim-dap.nvim
  {
    "jay-babu/mason-nvim-dap.nvim",
    config = function()
      local dap = require("dap")

      -- Godot stuff
      -- @see https://docs.godotengine.org/en/stable/tutorials/editor/external_editor.html#lsp-dap-support
      dap.adapters.godot = {
        debugServer = 6006,
        host = "127.0.0.1",
        port = 6007,
        type = "server",
      }

      dap.configurations.gdscript = {
        {
          launch_scene = true,
          name = "Launch scene",
          project = "${workspaceFolder}/src",
          request = "launch",
          type = "godot",
        },
      }
    end,
  },
}
