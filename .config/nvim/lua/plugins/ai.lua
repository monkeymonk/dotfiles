local keymap = require("utils.keymap")
local bind = keymap.bind
local desc = keymap.desc

return {
  -- ChatGPT Neovim Plugin: Effortless Natural Language Generation with OpenAI's ChatGPT API
  -- https://github.com/jackMort/ChatGPT.nvim
  {
    "jackMort/ChatGPT.nvim",
    event = "VeryLazy",
    config = function()
      require("chatgpt").setup()
    end,
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "folke/trouble.nvim",
      "nvim-telescope/telescope.nvim",
    },
    opts = {
      -- api_key_cmd = "echo $OPENAI_API_KEY",
      openai_edit_params = {
        model = "gpt-4o-mini",
      },
      openai_params = {
        model = "gpt-4o-mini",
      },
    },
  },

  -- Neovim plugin for intracting with GPT models from OpenAI
  -- https://github.com/Bryley/neoai.nvim
  {
    "Bryley/neoai.nvim",
    cmd = {
      "NeoAI",
      "NeoAIOpen",
      "NeoAIClose",
      "NeoAIToggle",
      "NeoAIContext",
      "NeoAIContextOpen",
      "NeoAIContextClose",
      "NeoAIInject",
      "NeoAIInjectCode",
      "NeoAIInjectContext",
      "NeoAIInjectContextCode",
    },
    config = function(_, opts)
      require("neoai").setup(opts)

      bind("nv", "<leader>xc", "<cmd> NeoAIContext <CR>", desc("NeoAIContext"))
      bind("nv", "<leader>xv", "<cmd> NeoAIToggle <CR>", desc("NeoAIToggle"))
    end,
    dependencies = "MunifTanjim/nui.nvim",
    event = "VeryLazy",
    opts = {
      models = {
        {
          name = "openai",
          model = "gpt-4o-mini",
          params = nil,
        },
      },
      prompts = {
        -- context_prompt = function(context)
        --   return "Hey, I'd like to provide some context for future "
        --     .. "messages. Here is the code/text that I want to refer "
        --     .. "to in our upcoming conversations:\n\n"
        --     .. context
        -- end,
      },
      shortcuts = {
        {
          name = "code_review",
          key = "<leader>xsc",
          desc = "Review code for best practices",
          use_context = true,
          prompt = [[
              Review the following code for best practices and suggest any improvements:
              {code}
            ]],
          modes = { "n", "v" },
          strip_function = nil,
        },
        {
          name = "textify",
          key = "<leader>xsr",
          desc = "Rewrite selection with AI",
          use_context = true,
          prompt = [[
              Please rewrite the text to make it more readable, clear,
              concise, and fix any grammatical, punctuation, or spelling
              errors
            ]],
          modes = { "v" },
          strip_function = nil,
        },
        {
          name = "gitcommit",
          key = "<leader>xsg",
          desc = "Generate git commit message",
          use_context = false,
          prompt = function()
            return [[
                Using the following git diff generate a consise and
                clear git commit message, with a short title summary
                that is 75 characters or less:
              ]] .. vim.fn.system("git diff --cached")
          end,
          modes = { "n" },
          strip_function = nil,
        },
        {
          name = "performance_optimization",
          key = "<leader>xsp",
          desc = "Analyze code performance",
          use_context = true,
          prompt = [[
              Analyze the following code for performance issues and suggest optimizations:
              {code}
            ]],
          modes = { "n", "v" },
        },
      },
      ui = { width = 40 },
    },
  },
}
