return {
  {
    "williamboman/mason.nvim",
    dependencies = "williamboman/mason-lspconfig.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "blade-formatter",
        "css-lsp",
        "efm",
        "intelephense",
        "ltex-ls",
        "luacheck",
        "php-debug-adapter",
        "selene",
        "shellcheck",
        "shfmt",
        "stylua",
        "tailwindcss-language-server",
        "typescript-language-server",
        "vue-language-server",
      })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = true },
      ---@type lspconfig.options
      servers = {
        -- ["blade-formatter"] = {
        --   filetypes = { "blade" },
        --   root_dir = function(fname)
        --     return require("lspconfig.util").find_git_ancestor(fname)
        --   end,
        --   settings = {},
        -- },
        bashls = {},
        cssls = {},
        efm = {
          init_options = { documentFormatting = true },
          settings = {
            rootMarkers = { ".git" },
            -- languages = {},
          },
        },
        emmet_ls = {
          filetypes = {
            "blade",
            "css",
            "html",
            "javascript",
            "javascriptreact",
            "less",
            "markdown",
            "sass",
            "scss",
            "typescript",
            "typescriptreact",
            "vue",
          },
          init_options = {
            html = {
              options = {
                -- For possible options, see: https://github.com/emmetio/emmet/blob/master/src/config.ts#L79-L26
                ["bem.enabled"] = true,
              },
            },
          },
        },
        html = {},
        intelephense = {
          settings = {
            intelephense = {
              format = {
                brackets = "k&r",
              },
              stubs = { "psr-4" },
            },
          },
        },
        ltex = {},
        lua_ls = {
          -- enabled = false,
          single_file_support = true,
          settings = {
            Lua = {
              workspace = {
                checkThirdParty = false,
              },
              completion = {
                workspaceWord = true,
                callSnippet = "Both",
              },
              misc = {
                parameters = {
                  -- "--log-level=trace",
                },
              },
              hint = {
                enable = true,
                setType = false,
                paramType = true,
                paramName = "Disable",
                semicolon = "Disable",
                arrayIndex = "Disable",
              },
              doc = {
                privateName = { "^_" },
              },
              type = {
                castNumberToInteger = true,
              },
              diagnostics = {
                disable = { "incomplete-signature-doc", "trailing-space" },
                -- enable = false,
                groupSeverity = {
                  strong = "Warning",
                  strict = "Warning",
                },
                groupFileStatus = {
                  ["ambiguity"] = "Opened",
                  ["await"] = "Opened",
                  ["codestyle"] = "None",
                  ["duplicate"] = "Opened",
                  ["global"] = "Opened",
                  ["luadoc"] = "Opened",
                  ["redefined"] = "Opened",
                  ["strict"] = "Opened",
                  ["strong"] = "Opened",
                  ["type-check"] = "Opened",
                  ["unbalanced"] = "Opened",
                  ["unused"] = "Opened",
                },
                unusedLocalExclude = { "_*" },
              },
              format = {
                enable = false,
                defaultConfig = {
                  indent_style = "space",
                  indent_size = "2",
                  continuation_indent_size = "2",
                },
              },
            },
          },
        },
        phpactor = {
          filetypes = { "blade", "php" },
          settings = {
            phpactor = {
              filetypes = { "blade", "php" },
              files = {
                associations = { "*.php", "*.blade.php" },
                maxSize = 5000000,
              },
            },
          },
          --[[ phpstan = {
            enabled = false,
          },
          psalm = {
            enabled = false,
          }, ]]
        },
        tailwindcss = {
          -- on_attach = function()
          --   require("tailwindcss-colors").buf_attach(0)
          -- end,
          root_dir = function(...)
            return require("lspconfig.util").root_pattern(".git")(...)
          end,
        },
        tsserver = {
          root_dir = function(...)
            return require("lspconfig.util").root_pattern(".git")(...)
          end,
          single_file_support = false,
          settings = {
            typescript = {
              inlayHints = {
                includeInlayParameterNameHints = "literal",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = false,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
            javascript = {
              inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
          },
        },
        volar = {
          filetypes = {
            "vue",
          },
        },
        yamlls = {
          settings = {
            yaml = {
              keyOrdering = false,
            },
          },
        },
      },
      setup = {},
    },
  },
}
