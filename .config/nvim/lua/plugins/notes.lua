local keymap = require("utils.keymap")
local bind = keymap.bind
local desc = keymap.desc

return {
  -- abolish.vim: Work with several variants of a word at once
  -- https://github.com/tpope/vim-abolish
  { "tpope/vim-abolish" },

  -- Correct common typos and misspellings as you type in Vim
  -- https://github.com/panozzaj/vim-autocorrect
  {
    "panozzaj/vim-autocorrect",
    event = { "BufReadPre", "BufNewFile" },
  },

  -- An asynchronous grammar checker for Neovim using LanguageTool
  -- https://github.com/vigoux/LanguageTool.nvim
  { "vigoux/LanguageTool.nvim" },

  -- Use any external translate command/API in nvim.
  -- https://github.com/uga-rosa/translate.nvim
  { "uga-rosa/translate.nvim" },

  -- Modernity meets insane extensibility. The future of organizing your life in Neovim.
  -- https://github.com/nvim-neorg/neorg
  -- https://github.com/nvim-neorg/neorg-telescope
  -- https://github.com/nvim-neorg/neorg/blob/main/doc/neorg.norg
  -- https://github.com/nvim-neorg/neorg/wiki/Tangling
  {
    "nvim-neorg/neorg",
    config = function(_, opts)
      require("neorg").setup(opts)

      local function findNotes()
        local action_state = require("telescope.actions.state")
        local actions = require("telescope.actions")
        local Path = require("plenary.path")
        local folder = vim.fn.expand("~/notes/")

        require("telescope.builtin").find_files({
          attach_mappings = function(prompt_bufnr, map)
            -- Creates a file using the telescope input prompt.
            -- Useful to quickly create a file if nothing exists.
            local create_file = function()
              -- It ain't pretty... But maybe it's good enough...? T.T
              local current_picker = action_state.get_current_picker(prompt_bufnr)
              local input = folder .. current_picker:_get_prompt() .. ".norg"

              local file = Path:new(input)
              if file:exists() then
                return
              end
              file:touch({ parents = true })

              actions.close(prompt_bufnr)
              vim.cmd("e " .. file .. "| w")
            end

            map("i", "<C-e>", create_file)
            return true
          end,
          cwd = folder,
        })
      end

      _G.FindNotes = findNotes

      bind("nv", "<leader>ni", "<cmd> Neorg index <CR>", desc("Index"))
      bind("nv", "<leader>nn", "<cmd> Neorg workspace notes <CR>", desc("Workspace Notes"))
      bind("nv", "<leader>ns", "<cmd> Neorg workspace scratches <CR>", desc("Workspace Scratches"))
      bind("nv", "<leader>nw", "<cmd> Neorg workspace work <CR>", desc("Workspace Work"))
      bind("nv", "<leader>nt", "<cmd> Neorg tangle current-file <CR>", desc("Tangle current file"))
      bind("nv", "<leader>nv", "<cmd> Neorg toggle-concealer <CR>", desc("Toggle concealer"))
      bind("nv", "<leader>nS", "<cmd> Neorg generate-workspace-summary <CR>", desc("Generate workspace summary"))
      bind("nv", "<leader>nk", "<cmd> Neorg keybind <CR>", desc("Keybind"))
      bind("nv", "<leader>nm", "<cmd> Neorg inject-metadata <CR>", desc("Inject metadata"))
      bind("nv", "<leader>nq", "<cmd> Neorg return <CR>", desc("Quit Neorg"))
      bind("nv", "<leader>nl", "<cmd> lua FindNotes() <CR>", desc("Find notes"))
      bind("nv", "<leader>ne", "<cmd> Neorg exec cursor <CR>", desc("Execute code under cursor"))
      bind("nv", "<leader>nE", "<cmd> Neorg exec current-file <CR>", desc("Execute all blocks in the file"))
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-neorg/neorg-telescope",
      {
        "vhyrro/luarocks.nvim",
        config = true,
        priority = 1000,
      },
      -- code block execution for neorg (similar to org-eval)
      -- https://github.com/laher/neorg-exec
      "laher/neorg-exec",
    },
    lazy = false,
    opts = {
      load = {
        ["core.defaults"] = {}, -- Loads default behaviour
        ["core.concealer"] = {}, -- Adds pretty icons to your documents
        ["core.completion"] = {
          config = { engine = "nvim-cmp" },
        },
        ["core.dirman"] = { -- Manages Neorg workspaces
          config = {
            default_workspace = "notes",
            workspaces = {
              notes = "~/notes",
              scratches = "~/notes/scratches",
              work = "~/notes/work",
            },
          },
        },
        ["core.integrations.nvim-cmp"] = {},
        ["core.integrations.telescope"] = {},
        ["core.summary"] = {},
        ["external.exec"] = {},
      },
    },
    version = "*",
  },

  -- A VIM syntax highlighting plugin for the Fountain screenplay format
  -- https://github.com/kblin/vim-fountain
  { "kblin/vim-fountain" },

  -- Effortlessly embed images into any markup language, like LaTeX, Markdown or Typst
  -- https://github.com/HakonHarnes/img-clip.nvim
  {
    "HakonHarnes/img-clip.nvim",
    cmd = "PasteImage",
    event = "VeryLazy",
    keys = {
      { "<leader>np", "<cmd>PasteImage<cr>", desc = "Paste image from system clipboard" },
      {
        "<leader>nP",
        function()
          local telescope = require("telescope.builtin")
          local actions = require("telescope.actions")
          local action_state = require("telescope.actions.state")

          telescope.find_files({
            attach_mappings = function(_, map)
              local function embed_image(prompt_bufnr)
                local entry = action_state.get_selected_entry()
                local filepath = entry[1]
                actions.close(prompt_bufnr)

                local img_clip = require("img-clip")
                img_clip.paste_image(nil, filepath)
              end

              map("i", "<CR>", embed_image)
              map("n", "<CR>", embed_image)

              return true
            end,
          })
        end,
        desc = "Select and embed image",
      },
    },
  },
}