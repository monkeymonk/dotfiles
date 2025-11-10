return {
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
      "ravitemer/mcphub.nvim",
    },
    -- enabled = false,
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
        embed = { -- Configuration for the Embedding Model used by the RAG service
          provider = "openai", -- The Embedding provider ("openai")
          endpoint = "https://api.openai.com/v1", -- The Embedding API endpoint
          api_key = "OPENAI_API_KEY", -- The environment variable name for the Embedding API key
          model = "text-embedding-3-large", -- The Embedding model name (e.g., "text-embedding-3-small", "text-embedding-3-large")
          extra = { -- Extra configuration options for the Embedding model (optional)
            dimensions = nil,
          },
        },
        llm = { -- Configuration for the Language Model (LLM) used by the RAG service
          provider = "openai", -- The LLM provider ("openai")
          endpoint = "https://api.openai.com/v1", -- The LLM API endpoint
          api_key = "OPENAI_API_KEY", -- The environment variable name for the LLM API key
          model = "gpt-4o-mini", -- The LLM model name (e.g., "gpt-4o-mini", "gpt-3.5-turbo")
          extra = { -- Extra configuration options for the LLM (optional)
            temperature = 0.7, -- Controls the randomness of the output. Lower values make it more deterministic.
            max_tokens = 512, -- The maximum number of tokens to generate in the completion.
            -- system_prompt = "You are a helpful assistant.", -- A system prompt to guide the model's behavior.
            -- timeout = 120, -- Request timeout in seconds.
          },
        },
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
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      -- @see https://codecompanion.olimorris.dev/configuration/prompt-library.html
      --prompt_library = {},
      strategies = {
        chat = {
          adapter = "openai",
        },
        cmd = {
          adapter = "openai",
        },
        inline = {
          adapter = "openai",
        },
      },
    },
  },

  -- An MCP client for Neovim that seamlessly integrates MCP servers into your editing workflow with an intuitive interface for managing, testing, and using MCP servers with your favorite chat plugins.
  -- https://ravitemer.github.io/mcphub.nvim/
  {
    "ravitemer/mcphub.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    build = "npm install -g mcp-hub@latest", -- Installs `mcp-hub` node binary globally
    config = function()
      require("mcphub").setup({
        config = vim.fn.expand("~/.config/mcphub/servers.json"),
        log = {
          level = vim.log.levels.WARN, -- Adjust verbosity (DEBUG, INFO, WARN, ERROR)
          to_file = true, -- Log to ~/.local/state/nvim/mcphub.log
        },
        on_ready = function()
          vim.notify("MCP Hub backend server is initialized and ready.", vim.log.levels.INFO)
        end,
      })
    end,
    event = "VeryLazy",
  },
}
