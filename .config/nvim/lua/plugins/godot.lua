-- @TODO: dynamise Godot path/version

-- Function to detect if a project.godot file exists in the current directory
local function is_godot_project()
  local project_file = vim.fn.getcwd() .. "/project.godot"
  return vim.fn.filereadable(project_file) == 1
end

if not is_godot_project() then
  return {}
end

local GDPATH = os.getenv("HOME")
  .. "/GodotEngine/Godot_v4.3-stable_mono_linux_x86_64/Godot_v4.3-stable_mono_linux.x86_64"

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
    event = "VeryLazy",
    ft = { "gd", "gdscript" },
    init = function()
      vim.g.godot_executable = GDPATH
    end,
  },

  -- Run and debug your Godot game in neovim
  -- https://github.com/Lommix/godot.nvim
  -- nvim --listen ~/.cache/nvim/godot.pipe .
  {
    "lommix/godot.nvim",
    keys = {
      -- {
      --   "<leader>ogg",
      --   "<cmd>! ~/GodotEngine/Godot_v4.2.2-stable_linux.x86_64<CR>",
      --   desc = "Run Godot",
      --   mode = "n",
      -- },
      {
        "<leader>Ggc",
        "<cmd>lua require('godot').debugger.continue()<CR>",
        desc = "Godot: Continue Debugger",
        mode = "n",
      },
      {
        "<leader>Ggd",
        "<cmd>lua require('godot').debugger.debug()<CR>",
        desc = "Godot: Run Debugger",
        mode = "n",
      },
      {
        "<leader>GgD",
        "<cmd>lua require('godot').debugger.debug_at_cursor()<CR>",
        desc = "Godot: Run Debugger at Cursor",
        mode = "n",
      },
      {
        "<leader>Ggq",
        "<cmd>lua require('godot').debugger.quit()<CR>",
        desc = "Godot: Quit Debugger",
        mode = "n",
      },
      {
        "<leader>Ggn",
        "<cmd>lua require('godot').debugger.step()<CR>",
        desc = "Godot: Step Debugger",
        mode = "n",
      },
    },
    opts = {
      bin = GDPATH,
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
    ft = { "gd", "gdscript", "gdshader" },
    opts = {
      ensure_installed = {
        "gdscript",
        "godot_resource",
        "gdshader",
      },
      highlight = { enable = true },
      indent = { enable = false },
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
        -- debugServer = 6006,
        host = "127.0.0.1",
        port = 6006,
        type = "server",
      }

      dap.configurations.gdscript = {
        {
          launch_scene = true,
          name = "Launch scene",
          project = "${workspaceFolder}",
          request = "launch",
          type = "godot",
        },
      }
    end,
    keys = {
      {
        "<leader>Gds",
        "<cmd>lua require('dap').continue()<CR>",
        desc = "Debug: Start/Continue",
        mode = "n",
      },
      {
        "<leader>Gdq",
        "<cmd>lua require('dap').terminate(); require('dapui').close()<CR>",
        desc = "Debug: Quit",
        mode = "n",
      },
      {
        "<leader>Gdn",
        "<cmd>lua require('dap').step_into()<CR>",
        desc = "Debug: Step Into",
        mode = "n",
      },
      {
        "<leader>Gdp",
        "<cmd>lua require('dap').step_over()<CR>",
        desc = "Debug: Step Over",
        mode = "n",
      },
      {
        "<leader>Gdx",
        "<cmd>lua require('dap').step_out()<CR>",
        desc = "Debug: Step Out",
        mode = "n",
      },
      {
        "<leader>Gdb",
        "<cmd>lua require('dap').toggle_breakpoint()<CR>",
        desc = "Debug: Toggle Breakpoint",
        mode = "n",
      },
      -- Allow to create conditional breakpoints with given condition (ex. "my_variable = 42") let the prompt empty for no condition.
      {
        "<leader>GdB",
        "<cmd>lua require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>",
        desc = "Debug: Set Breakpoint",
        mode = "n",
      },
    },
  },
}
