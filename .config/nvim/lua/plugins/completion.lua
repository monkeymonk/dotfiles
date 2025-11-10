return {
  -- Compatibility layer for using nvim-cmp sources on blink.cmp
  -- https://github.com/Saghen/blink.compat
  { "saghen/blink.compat", version = "2.*", lazy = true, opts = {} },

  -- Avante source for blink-cmp
  -- https://github.com/Kaiser-Yang/blink-cmp-avante
  { "Kaiser-Yang/blink-cmp-avante", lazy = true }, -- registers source = "avante"

  -- Performant, batteries-included completion plugin for Neovim
  -- https://github.com/saghen/blink.cmp
  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      opts.sources = vim.tbl_deep_extend("force", opts.sources or {}, {
        default = { "lsp", "avante", "path", "snippets", "buffer", "dadbod" },

        providers = {
          -- Avante: real Blink source (no compat layer needed)
          avante = {
            module = "blink-cmp-avante",
            name = "Avante",
            score_offset = 50, -- put it near the top
          },

          -- Dadbod: nvim-cmp source, so we wrap it with blink.compat
          dadbod = {
            filetypes = { "sql", "mysql", "plsql" },
            min_keyword_length = 2,
            module = "blink.compat.source",
            name = "vim-dadbod-completion", -- exact cmp source name
            score_offset = 30,
          },
        },
      })
    end,
  },
}
