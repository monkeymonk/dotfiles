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

  {
    "HakonHarnes/img-clip.nvim",
    cmd = "PasteImage",
    opts = {
      dir_path = "assets", -- directory path to save images to, can be relative (cwd or current file) or absolute
      file_name = "%Y-%m-%d-%H-%M-%S", -- file name format (see lua.org/pil/22.1.html)
      url_encode_path = false, -- encode spaces and special characters in file path
      use_absolute_path = false, -- expands dir_path to an absolute path
      prompt_for_file_name = true, -- ask user for file name before saving, leave empty to use default
      show_dir_path_in_prompt = false, -- show dir_path in prompt when prompting for file name
      use_cursor_in_template = true, -- jump to cursor position in template after pasting
      insert_mode_after_paste = true, -- enter insert mode after pasting the markup code
      relative_to_current_file = false, -- make dir_path relative to current file rather than the cwd

      template = "$FILE_PATH", -- default template

      -- file-type specific options
      -- any options that are passed here will override the global config
      -- for instance, setting use_absolute_path = true for markdown will
      -- only enable that for this particular file type
      -- the key (e.g. "markdown") is the filetype (output of "set filetype?")

      markdown = {
        url_encode_path = true,
        template = "![$CURSOR]($FILE_PATH)",
      },

      html = {
        template = '<img src="$FILE_PATH" alt="$CURSOR">',
      },

      tex = {
        template = [[
    \begin{figure}[h]
      \centering
      \includegraphics[width=0.8\textwidth]{$FILE_PATH}
      \caption{$CURSOR}
      \label{fig:$LABEL}
    \end{figure}
        ]],
      },

      typst = {
        template = [[
#figure(
      image("$FILE_PATH", width: 80%),
      caption: [$CURSOR],
    ) <fig-$LABEL>
        ]],
      },

      rst = {
        template = [[
    .. image:: $FILE_PATH
      :alt: $CURSOR
      :width: 80%
        ]],
      },

      asciidoc = {
        template = 'image::$FILE_PATH[width=80%, alt="$CURSOR"]',
      },

      org = {
        template = [=[
#+BEGIN_FIGURE
    [[file:$FILE_PATH]]
#+CAPTION: $CURSOR
#+NAME: fig:$LABEL
#+END_FIGURE
        ]=],
      },

      wiki = {
        template = '{{local="$FILE_PATH}"}',
      },
    },
  },
}
