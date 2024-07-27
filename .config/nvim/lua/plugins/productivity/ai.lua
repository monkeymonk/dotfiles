local keymap = require("utils.keymap")
local bind = keymap.bind
local desc = keymap.desc

return {
  -- ChatGPT Neovim Plugin: Effortless Natural Language Generation with OpenAI's ChatGPT API
  -- https://github.com/jackMort/ChatGPT.nvim
  {
    "jackMort/ChatGPT.nvim",
    config = function()
      require("chatgpt").setup()
    end,
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "folke/trouble.nvim",
      "nvim-telescope/telescope.nvim",
    },
    event = "VeryLazy",
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
    config = function()
      require("neoai").setup({
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
            name = "textify",
            key = "<leader>as",
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
            key = "<leader>ag",
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
        },
        ui = { width = 40 },
      })

      bind("nv", "<leader>ac", "<cmd> NeoAIContext <CR>", desc("NeoAIContext"))
      bind("nv", "<leader>av", "<cmd> NeoAIToggle <CR>", desc("NeoAIToggle"))
    end,
    dependencies = "MunifTanjim/nui.nvim",
    event = "VeryLazy",
  },

  -- Experimental Sourcegraph + Cody plugin for Neovim
  -- https://github.com/sourcegraph/sg.nvim
  {
    "sourcegraph/sg.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
  },
}
