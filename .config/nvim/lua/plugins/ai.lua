return {
  -- ChatGPT Neovim Plugin: Effortless Natural Language Generation with OpenAI's ChatGPT API
  -- https://github.com/jackMort/ChatGPT.nvim
  -- {
  --   "jackMort/ChatGPT.nvim",
  --   event = "VeryLazy",
  --   config = function()
  --     require("chatgpt").setup()
  --   end,
  --   dependencies = {
  --     "MunifTanjim/nui.nvim",
  --     "nvim-lua/plenary.nvim",
  --     "folke/trouble.nvim",
  --     "nvim-telescope/telescope.nvim",
  --   },
  --   opts = {
  --     -- api_key_cmd = "echo $OPENAI_API_KEY",
  --     openai_edit_params = {
  --       model = "gpt-4o-mini",
  --     },
  --     openai_params = {
  --       model = "gpt-4o-mini",
  --     },
  --   },
  -- },

  -- Neovim plugin for intracting with GPT models from OpenAI
  -- https://github.com/Bryley/neoai.nvim
  -- {
  --   "Bryley/neoai.nvim",
  --   cmd = {
  --     "NeoAI",
  --     "NeoAIOpen",
  --     "NeoAIClose",
  --     "NeoAIToggle",
  --     "NeoAIContext",
  --     "NeoAIContextOpen",
  --     "NeoAIContextClose",
  --     "NeoAIInject",
  --     "NeoAIInjectCode",
  --     "NeoAIInjectContext",
  --     "NeoAIInjectContextCode",
  --   },
  --   dependencies = "MunifTanjim/nui.nvim",
  --   event = "VeryLazy",
  --   keys = {
  --     { "<leader>aNd", "<cmd> NeoAIContext <CR>", desc = "NeoAIContext", mode = { "n", "v" } },
  --     { "<leader>aNv", "<cmd> NeoAIToggle <CR>", desc = "NeoAIToggle", mode = { "n", "v" } },
  --   },
  --   opts = {
  --     models = {
  --       {
  --         name = "openai",
  --         model = "gpt-4o-mini",
  --         params = nil,
  --       },
  --     },
  --     prompts = {
  --       -- context_prompt = function(context)
  --       --   return "Hey, I'd like to provide some context for future "
  --       --     .. "messages. Here is the code/text that I want to refer "
  --       --     .. "to in our upcoming conversations:\n\n"
  --       --     .. context
  --       -- end,
  --     },
  --     shortcuts = {
  --       {
  --         name = "code_review",
  --         key = "<leader>aNr",
  --         desc = "Review code for best practices",
  --         use_context = true,
  --         prompt = [[
  --             Review the following code for best practices and suggest any improvements:
  --             {code}
  --           ]],
  --         modes = { "n", "v" },
  --         strip_function = nil,
  --       },
  --       {
  --         name = "textify",
  --         key = "<leader>and",
  --         desc = "Rewrite selection with AI",
  --         use_context = true,
  --         prompt = [[
  --             Please rewrite the text to make it more readable, clear,
  --             concise, and fix any grammatical, punctuation, or spelling
  --             errors
  --           ]],
  --         modes = { "v" },
  --         strip_function = nil,
  --       },
  --       {
  --         name = "gitcommit",
  --         key = "<leader>aNg",
  --         desc = "Generate git commit message",
  --         use_context = false,
  --         prompt = function()
  --           return [[
  --               Using the following git diff generate a consise and
  --               clear git commit message, with a short title summary
  --               that is 75 characters or less:
  --             ]] .. vim.fn.system("git diff --cached")
  --         end,
  --         modes = { "n" },
  --         strip_function = nil,
  --       },
  --       {
  --         name = "performance_optimization",
  --         key = "<leader>aNp",
  --         desc = "Analyze code performance",
  --         use_context = true,
  --         prompt = [[
  --             Analyze the following code for performance issues and suggest optimizations:
  --             {code}
  --           ]],
  --         modes = { "n", "v" },
  --       },
  --     },
  --     ui = { width = 40 },
  --   },
  -- },

  -- Use your Neovim like using Cursor AI IDE!
  -- https://github.com/yetone/avante.nvim
  {
    "yetone/avante.nvim",
    build = "make",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      -- "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
      "ibhagwan/fzf-lua", -- for file_selector provider fzf
      "folke/snacks.nvim", -- for input provider snacks
      "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
      {
        -- support for image pasting
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
    event = "VeryLazy",
    keys = {
      {
        "<leader>a+",
        function()
          local tree_ext = require("avante.extensions.nvim_tree")
          tree_ext.add_file()
        end,
        desc = "Select file in NvimTree",
        ft = "NvimTree",
      },
      {
        "<leader>a-",
        function()
          local tree_ext = require("avante.extensions.nvim_tree")
          tree_ext.remove_file()
        end,
        desc = "Deselect file in NvimTree",
        ft = "NvimTree",
      },
    },
    lazy = false,
    opts = function()
      local mcphub = require("mcphub")
      return {
        auto_suggestions_provider = "openai",
        behaviour = {
          auto_suggestions = true,
          support_paste_from_clipboard = true,
        },
        -- Tell Avante to expose its completion sources for blink
        compat = { "avante_commands", "avante_mentions", "avante_files" }, -- :contentReference[oaicite:0]{index=0}
        -- Expose MCP tools so the LLM can call them
        custom_tools = function()
          return {
            require("mcphub.extensions.avante").mcp_tool(),
          }
        end,
        debug = false,
        disabled_tools = { "read_file", "create_file", "delete_file", "bash" },
        --[[ mappings = {
        ask = "<leader>xaa",
        edit = "<leader>xae",
        refresh = "<leader>xar",
        focus = "<leader>xaf",
        toggle = {
          default = "<leader>xat",
          debug = "<leader>xad",
          hint = "<leader>xah",
          suggestion = "<leader>xas",
          repomap = "<leader>xaR",
        },
      }, ]]
        provider = "openai",
        providers = {
          openai = {
            endpoint = "https://api.openai.com/v1",
            model = "gpt-4o-mini",
          },
        },
        suggestion = { debounce = 300, throttle = 300 },
        -- Let the LLM “see” which MCP servers & tools are available
        system_prompt = function()
          local hub = mcphub.get_hub_instance()
          return hub and hub:get_active_servers_prompt() or ""
        end,
      }
    end,
    version = false,
  },

  -- @TODO: https://github.com/David-Kunz/gen.nvim

  -- AI-powered coding, seamlessly in Neovim
  -- https://github.com/olimorris/codecompanion.nvim
  -- {
  --   "olimorris/codecompanion.nvim",
  --   config = true,
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --     "nvim-treesitter/nvim-treesitter",
  --   },
  --   opts = {
  --     strategies = {
  --       chat = {
  --         adapter = "openai",
  --       },
  --       inline = {
  --         adapter = "openai",
  --       },
  --     },
  --   },
  -- },

  -- Free, ultrafast Copilot alternative for Vim and Neovim
  -- https://github.com/Exafunction/windsurf.vim
  -- {
  --   "Exafunction/windsurf.vim",
  --   event = "BufEnter",
  -- },

  -- An MCP client for Neovim that seamlessly integrates MCP servers into your editing workflow with an intuitive interface for managing, testing, and using MCP servers with your favorite chat plugins.
  -- https://ravitemer.github.io/mcphub.nvim/
  {
    "ravitemer/mcphub.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    build = "npm install -g mcp-hub@latest", -- Installs `mcp-hub` node binary globally
    config = function()
      require("mcphub").setup()
    end,
  },
}
