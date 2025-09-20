return {
  -- Nvim Treesitter configurations and abstraction layer
  -- https://github.com/nvim-treesitter/nvim-treesitter
  {
    "nvim-treesitter/nvim-treesitter",
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
        "json",
        "lua",
        "norg",
        "php",
        "phpdoc",
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
