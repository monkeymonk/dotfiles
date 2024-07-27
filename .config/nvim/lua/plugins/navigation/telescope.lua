local keymap = require("utils.keymap")
local bind = keymap.bind
local desc = keymap.desc

-- Find, Filter, Preview, Pick. All lua, all the time.
-- https://github.com/nvim-telescope/telescope.nvim
return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  cmd = "Telescope",
  config = function(_, opts)
    local telescope = require("telescope")
    local actions = require("telescope.actions")

    opts.defaults.mappings.i = {
      ["<C-k>"] = actions.move_selection_previous, -- move to prev result
      ["<C-j>"] = actions.move_selection_next, -- move to next result
      ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
    }

    -- default for on_project_selected = find project files
    -- opts.extensions.project.on_project_selected = function(prompt_bufnr)
    --   local project_actions = require("telescope._extensions.project.actions")
    --   project_actions.change_working_directory(prompt_bufnr, false)
    -- end

    telescope.setup(opts)

    local extensions = {
      "file_browser",
      "fzf",
      -- "import",
      "media",
      -- "project",
    }
    for _, ext in ipairs(extensions) do
      telescope.load_extension(ext)
    end
  end,
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-telescope/telescope-file-browser.nvim",
    -- "nvim-telescope/telescope-project.nvim",
    -- "nvim-telescope/telescope-dap.nvim",
    "dharmx/telescope-media.nvim",
    "nvim-tree/nvim-web-devicons",
    -- "piersolenski/telescope-import.nvim",
  },
  keys = {
    {
      "<leader>.",
      function()
        require("telescope.builtin").find_files({
          hidden = true,
          no_ignore = false,
        })
      end,
      desc = "Find files",
    },
    {
      "<leader>/",
      function()
        require("telescope.builtin").live_grep({
          hidden = true,
        })
      end,
      desc = "Find text in files",
    },
    {
      "<leader>?",
      function()
        require("telescope.builtin").live_grep({
          cwd = vim.fn.expand("%:p:h"),
          hidden = true,
        })
      end,
      desc = "Find text in files",
    },
    {
      "<leader>ff",
      function()
        require("telescope.builtin").find_files({
          hidden = true,
          no_ignore = false,
        })
      end,
      desc = "Find files",
    },
    {
      "<leader>fb",
      function()
        require("telescope.builtin").buffers()
      end,
      desc = "Find in open buffers",
    },
    {
      "<leader>fB",
      function()
        require("telescope.builtin").file_browser({
          path = "%:p:h",
          select_buffer = true,
        })
      end,
      desc = "Find in directory",
    },
    {
      "<leader>fd",
      function()
        require("telescope.builtin").diagnostics()
      end,
      desc = "Find buffers diagnostics",
    },
    {
      "<leader>fD",
      function()
        require("telescope.builtin").treesitter()
      end,
      desc = "Find in function names, variables, etc (Treesitter)",
    },
    { "<leader>,", false },
    { "<leader>`", false },
    {
      "<leader>bb",
      function()
        require("telescope.builtin").buffers({
          sort_lastused = true,
          sort_mru = true,
        })
      end,
      desc = "Switch buffer",
    },
    {
      "<leader>cs",
      function()
        require("telescope.builtin").current_buffer_fuzzy_find()
      end,
      desc = "Find in current buffer",
    },
    {
      "<leader>hh",
      function()
        require("telescope.builtin").help()
      end,
      desc = "Find in help",
    },
    {
      "<leader>hm",
      function()
        require("telescope.builtin").man_pages()
      end,
      desc = "Find in man pages",
    },
    {
      "<leader>hr",
      function()
        require("telescope.builtin").registers()
      end,
      desc = "Find in registers",
    },
    {
      "<leader>hk",
      function()
        require("telescope.builtin").keymaps()
      end,
      desc = "Find in keymaps",
    },
    {
      "<leader>ho",
      function()
        require("telescope.builtin").vim_options()
      end,
      desc = "Find in vim options",
    },
    {
      "<leader>hc",
      function()
        require("telescope.builtin").commands()
      end,
      desc = "Find in commands",
    },
  },
  opts = {
    defaults = {
      mappings = {},
      path_display = { "truncate " },
    },
    extensions = {
      file_browser = {
        hijack_netrw = true,
        theme = "ivy",
      },
      fzf = {
        fuzzy = true,
      },
      -- import = {
      --   insert_at_top = true,
      -- },
      media = {},
      -- project = {
      --   base_dirs = {
      --     "~/works/cherrypulp/",
      --     "~/works/monkeymonk/",
      --     "~/works/tools/",
      --     "~/works/sandboxes/",
      --   },
      --   hidden_files = true,
      -- },
    },
    pickers = {
      diagnostics = {
        initial_mode = "normal",
        layout_config = {
          preview_cutoff = 9999,
        },
        theme = "dropdown",
      },
    },
  },
}
