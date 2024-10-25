return {
  -- Nvim Treesitter configurations and abstraction layer
  -- https://github.com/nvim-treesitter/nvim-treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
    opts = {
      ensure_installed = {
        "astro",
        "cmake",
        "comment",
        "cpp",
        "css",
        "gitignore",
        "go",
        "graphql",
        "http",
        "norg",
        "php",
        "rust",
        "scss",
        "sql",
        "svelte",
        "vue",
      },
      highlight = {
        additional_vim_regex_highlighting = {
          "markdown",
        },
      },
    },
  },
}
