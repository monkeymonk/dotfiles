return {
  -- Create key bindings that stick. WhichKey is a lua plugin for Neovim 0.5 that displays a popup with possible keybindings of the command you started typing.
  -- https://github.com/folke/which-key.nvim
  -- https://www.nerdfonts.com/cheat-sheet
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 100
    end,
    opts = {
      loop = true,
      preset = "modern",
      spec = {
        { "<leader> ", ":", desc = "Enter command mode" },
        { "<leader>:", ":", desc = "Enter command mode", hidden = true },
        { "<leader>+", "<C-x>", desc = "Increment number", hidden = true },
        { "<leader>-", "<C-a>", desc = "Decrement number", hidden = true },
        { "<leader><Tab>", group = "tabs" },
        { "<leader>a", group = "ai" },
        { "<leader>b", group = "buffer" },
        {
          "<leader>c",
          group = "code",
          {
            "<leader>cs",
            "<cmd> lua vim.lsp.buf.signature_help() <CR>",
            desc = "Show signature help",
            mode = { "n", "v" },
          },
          { "<leader>cc", group = "comments" },
        },
        {
          "<leader>f",
          group = "file",
          mode = { "n", "v" },
          { "<leader>ft", hidden = true },
          { "<leader>fT", hidden = true },
          {
            "<leader>fs",
            "<cmd> w <CR>",
            desc = "Save file",
          },
          {
            "<leader>fS",
            "<cmd> SaveAs <CR>",
            desc = "Save file as...",
          },
        },
        { "<leader>g", group = "git" },
        {
          "<leader>h",
          group = "help",
          mode = { "n", "v" },
          {
            "<leader>hl",
            "<cmd> Lazy <CR>",
            desc = "Lazy",
          },
        },
        { "<leader>i", hidden = true },
        { "<leader>l", hidden = true },
        { "<leader>lp", hidden = true },
        { "<leader>m", group = "markers" },
        { "<leader>n", group = "notes" },
        { "<leader>o", group = "open" },
        { "<leader>og", group = "godot" },
        { "<leader>p", group = "project", hidden = true },
        {
          "<leader>q",
          group = "session",
          mode = { "n", "v" },
          {
            "<leader>qq",
            "<cmd> confirm qa <CR>",
            desc = "Force Quit",
          },
        },
        {
          "<leader>r",
          group = "refactor",
          mode = { "n", "v" },
          { "<leader>rn", hidden = true },
          {
            "<leader>rn",
            "<cmd> lua vim.lsp.buf.rename() <CR>",
            desc = "Smart rename",
          },
        },
        { "<leader>s", group = "search" },
        { "<leader>t", group = "toggle" },
        {
          "<leader>u",
          group = "ui",
          mode = { "n", "v" },
          {
            "<leader>tc",
            "<cmd> nohl <CR>",
            desc = "Clear search highlight",
          },
          {
            "<leader>tn",
            "<cmd> set nu! <CR>",
            desc = "Toggle line number",
          },
          {
            "<leader>tr",
            "<cmd> set rnu! <CR>",
            desc = "Toggle relative number",
          },
        },
        {
          "<leader>w",
          group = "window",
          mode = { "n", "v" },
          {
            "<leader>wd",
            "<cmd> q <CR>",
            desc = "Delete Window",
          },
          {
            "<leader>wv",
            "<cmd> vsp <CR>",
            desc = "Split vertically",
          },
          {
            "<leader>ws",
            "<cmd> sp <CR>",
            desc = "Split horizontally",
          },
        },
        { "<leader>x", group = "diagnostics/quickfix" },
        { "<leader>`", hidden = true },
        { "<leader>|", hidden = true },
        { "<leader>L", hidden = true },
        { "<leader>K", hidden = true },
      },
    },
  },
}
