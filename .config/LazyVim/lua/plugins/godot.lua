-- @TODO: dynamise Godot path/version
return {
  -- Use vim and godot engine to make games
  -- https://github.com/habamax/vim-godot
  {
    "habamax/vim-godot",
    init = function()
      vim.g.godot_executable = os.getenv("HOME") .. "/GodotEngine/Godot_v4.3-stable_linux.x86_64"

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
  },

  -- Run and debug your Godot game in neovim
  -- https://github.com/Lommix/godot.nvim
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
}
