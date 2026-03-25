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
        "php",
        "phpdoc",
        "rust",
        "scss",
        "sql",
        "svelte",
        "tsx",
        "typescript",
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
