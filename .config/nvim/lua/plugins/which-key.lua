return {
  -- Create key bindings that stick. WhichKey is a lua plugin for Neovim 0.5 that displays a popup with possible keybindings of the command you started typing.
  -- https://github.com/folke/which-key.nvim
  -- https://www.nerdfonts.com/cheat-sheet
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      spec = {
        -- hidden
        { "<leader>-", hidden = true },
        { "<leader>|", hidden = true },
        { "<leader>l", hidden = true },
        { "<leader>L", hidden = true },
        -- groups
        { "<leader>m", group = "markers" },
        { "<leader>n", group = "notes" },
        { "<leader> ", group = "godot" },
        -- bindings
        {
          "<leader>qL",
          "<cmd> Lazy <CR>",
          desc = "Lazy",
        },
        {
          "<leader>qV",
          function()
            LazyVim.news.changelog()
          end,
          desc = "LazyVim Changelog",
        },
        {
          "<leader>rn",
          "<cmd> lua vim.lsp.buf.rename() <CR>",
          desc = "Smart rename",
        },
      },
    },
  },
}
