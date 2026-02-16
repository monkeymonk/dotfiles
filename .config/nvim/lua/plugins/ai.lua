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
    lazy = false, -- Avante needs to load for autocomplete
    opts = function()
      local mcphub = require("mcphub")

      -- Detect if Ollama is running
      local function ollama_available()
        local available = vim.fn.executable("ollama") == 1
        if available then
          vim.notify("Ollama detected! Using Ollama for autocomplete", vim.log.levels.INFO)
        else
          vim.notify("Ollama not found. Falling back to OpenAI", vim.log.levels.WARN)
        end
        return available
      end

      return {
        -- 🔁 AUTO SUGGESTIONS (AUTOCOMPLETE) - DISABLED TO AVOID OPENAI CHARGES
        auto_suggestions_provider = "ollama",

        behaviour = {
          auto_suggestions = false, -- DISABLED: No autocomplete (saves OpenAI credits)
          support_paste_from_clipboard = true,
        },

        -- PROVIDERS
        provider = "ollama",

        providers = {
          -- 🔥 OLLAMA (LOCAL)
          ollama = {
            model = "qwen2.5-coder:7b",
            is_env_set = require("avante.providers.ollama").check_endpoint_alive,
          },

          -- ☁️ OPENAI (FALLBACK / TOOLS / RAG)
          openai = {
            endpoint = "https://api.openai.com/v1",
            model = "gpt-4o-mini",
          },
        },

        -- RAG / EMBEDDINGS - DISABLED TO AVOID OPENAI CHARGES
        -- If you want RAG features, you'll need OpenAI API key
        -- embed = {
        --   provider = "openai",
        --   endpoint = "https://api.openai.com/v1",
        --   api_key = "OPENAI_API_KEY",
        --   model = "text-embedding-3-large",
        -- },

        -- LLM FOR TOOLS - DISABLED TO AVOID OPENAI CHARGES
        -- llm = {
        --   provider = "openai",
        --   endpoint = "https://api.openai.com/v1",
        --   api_key = "OPENAI_API_KEY",
        --   model = "gpt-4o-mini",
        --   extra = {
        --     temperature = 0.7,
        --     max_tokens = 512,
        --   },
        -- },

        -- MCP / TOOLS
        custom_tools = function()
          return {
            require("mcphub.extensions.avante").mcp_tool(),
          }
        end,

        disabled_tools = { "read_file", "create_file", "delete_file", "bash" },

        suggestion = {
          debounce = 200,
          throttle = 200,
        },

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
    cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      strategies = {
        chat = {
          adapter = "ollama",
        },
        cmd = {
          adapter = "ollama",
        },
        inline = {
          adapter = "ollama",
        },
      },

      adapters = {
        -- 🔥 OLLAMA
        ollama = {
          schema = {
            model = {
              default = "deepseek-coder-v2:lite",
            },
          },
          env = {
            url = "http://localhost:11434/v1",
            api_key = "ollama", -- dummy
          },
        },

        -- ☁️ OPENAI (OPTIONAL FALLBACK)
        openai = {
          schema = {
            model = {
              default = "gpt-4o-mini",
            },
          },
          env = {
            api_key = "OPENAI_API_KEY",
          },
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
