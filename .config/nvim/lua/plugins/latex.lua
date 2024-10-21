local keymap = require("utils.keymap")
local bind = keymap.bind
local desc = keymap.desc

return {
  -- VimTeX: A modern Vim and neovim filetype plugin for LaTeX files.
  -- https://github.com/lervag/vimtex
  {
    "lervag/vimtex",
    init = function()
      -- vim.g.vimtex_view_method = "skim"
      vim.g.vimtex_compiler_engine = "lualatex"
      -- vim.g.maplocalleader = ","
      -- Do not auto open quickfix on compile erros
      vim.g.vimtex_quickfix_mode = 0
      -- Latex warnings to ignore
      vim.g.vimtex_quickfix_ignore_filters = {
        "Command terminated with space",
        "LaTeX Font Warning: Font shape",
        "Package caption Warning: The option",
        [[Underfull \\hbox (badness [0-9]*) in]],
        "Package enumitem Warning: Negative labelwidth",
        [[Overfull \\hbox ([0-9]*.[0-9]*pt too wide) in]],
        [[Package caption Warning: Unused \\captionsetup]],
        "Package typearea Warning: Bad type area settings!",
        [[Package fancyhdr Warning: \\headheight is too small]],
        [[Underfull \\hbox (badness [0-9]*) in paragraph at lines]],
        "Package hyperref Warning: Token not allowed in a PDF string",
        [[Overfull \\hbox ([0-9]*.[0-9]*pt too wide) in paragraph at lines]],
      }
      vim.g.vimtex_fold_enabled = 1
      vim.g.vimtex_fold_manual = 1

      -- add which-key mapping descriptions for VimTex
      vim.api.nvim_create_autocmd("FileType", {
        desc = "Set up VimTex Which-Key descriptions",
        group = vim.api.nvim_create_augroup("vimtex_mapping_descriptions", { clear = true }),
        pattern = "tex",
        callback = function(event)
          local opts = { buffer = event.buf, mode = "n", prefix = "<leader>" }
          local mappings = {
            l = {
              name = "+VimTex",
              a = "Show Context Menu",
              C = "Full Clean",
              c = "Clean",
              e = "Show Errors",
              G = "Show Status for All",
              g = "Show Status",
              i = "Show Info",
              I = "Show Full Info",
              k = "Stop VimTeX",
              K = "Stop All VimTeX",
              L = "Compile Selection",
              l = "Compile",
              m = "Show Imaps",
              o = "Show Compiler Output",
              q = "Show VimTeX Log",
              s = "Toggle Main",
              t = "Open Table of Contents",
              T = "Toggle Table of Contents",
              v = "View Compiled Document",
              X = "Reload VimTeX State",
              x = "Reload VimTeX",
            },
          }

          require("which-key").register(mappings, opts)
        end,
      })
    end,
    ft = "tex",
  },

  -- A Vim Plugin for Lively Previewing LaTeX PDF Output
  -- https://github.com/xuhdev/vim-latex-live-preview
  {
    "xuhdev/vim-latex-live-preview",
    ft = { "markdown", "tex" },
    keys = {
      { "<leader>np", "<cmd> LLPStartPreview <CR>", desc = "Start Preview", mode = { "n", "v" } },
    },
  },
}
