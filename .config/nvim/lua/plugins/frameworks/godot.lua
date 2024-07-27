return {
  -- Use vim and godot engine to make games
  -- @see https://github.com/habamax/vim-godot
  {
    "habamax/vim-godot",
    init = function()
      vim.g.godot_executable = "/home/monkeymonk/GodotEngine/Godot_v4.2.2-stable_linux.x86_64"
    end,
  },
  -- Run and debug your Godot game in neovim
  -- @see https://github.com/Lommix/godot.nvim
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
        "<leader>ogc",
        "<cmd>lua require('godot').debugger.continue()<CR>",
        desc = "Continue Godot Debugger",
        mode = "n",
      },
      {
        "<leader>ogd",
        "<cmd>lua require('godot').debugger.debug()<CR>",
        desc = "Run Godot Debugger",
        mode = "n",
      },
      {
        "<leader>ogD",
        "<cmd>lua require('godot').debugger.debug_at_cursor()<CR>",
        desc = "Run Godot Debugger at Cursor",
        mode = "n",
      },
      {
        "<leader>ogq",
        "<cmd>lua require('godot').debugger.quit()<CR>",
        desc = "Quit Godot Debugger",
        mode = "n",
      },
      {
        "<leader>ogs",
        "<cmd>lua require('godot').debugger.step()<CR>",
        desc = "Step Godot Debugger",
        mode = "n",
      },
    },
    opts = {
      bin = os.getenv("HOME") .. "/GodotEngine/Godot_v4.2.2-stable_linux.x86_64",
    },
  },
}
