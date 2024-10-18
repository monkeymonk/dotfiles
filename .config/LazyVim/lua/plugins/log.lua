return {
  -- Generic log syntax highlighting and filetype management for Neovim
  -- https://github.com/fei6409/log-highlight.nvim
  {
    "fei6409/log-highlight.nvim",
    config = function(_, opts)
      require("log-highlight").setup(opts)
    end,
  },
}
