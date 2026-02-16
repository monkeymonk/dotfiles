return {
  -- VimTeX: A modern Vim and neovim filetype plugin for LaTeX files.
  -- https://github.com/lervag/vimtex
  {
    "lervag/vimtex",
    config = function()
      vim.g.vimtex_mappings_disable = { ["n"] = { "K" } } -- disable `K` as it conflicts with LSP hover
      vim.g.vimtex_quickfix_method = vim.fn.executable("pplatex") == 1 and "pplatex" or "latexlog"
    end,
    ft = { "tex" },
  },

  -- A Vim Plugin for Lively Previewing LaTeX PDF Output
  -- https://github.com/xuhdev/vim-latex-live-preview
  {
    "xuhdev/vim-latex-live-preview",
    ft = { "tex" },
    keys = {
      { "<leader>np", "<cmd> LLPStartPreview <CR>", desc = "Start Preview", mode = { "n", "v" } },
    },
  },
}
