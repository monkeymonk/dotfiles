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
        "bash",
        "cmake",
        "comment",
        "cpp",
        "css",
        "diff",
        -- "fish",
        "gitignore",
        "go",
        "graphql",
        "html",
        "http",
        "javascript",
        "jsdoc",
        "json",
        "lua",
        -- "markdown",
        -- "markdown_inline",
        "norg",
        "php",
        "python",
        "regex",
        "rust",
        "scss",
        "sql",
        "svelte",
        "tsx",
        "typescript",
        "vue",
        "yaml",
      },
    },
  },
}
