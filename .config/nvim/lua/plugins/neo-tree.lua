return {
  -- This plugins prompts the user to pick a window and returns the window id of the picked window
  -- https://github.com/s1n7ax/nvim-window-picker
  {
    "s1n7ax/nvim-window-picker",
    config = function(_, opts)
      require("window-picker").setup(opts)
    end,
    event = "VeryLazy",
    name = "window-picker",
    opts = {
      filter_rules = {
        autoselect_one = true,
        -- filter using buffer options
        bo = {
          -- if the buffer type is one of following, the window will be ignored
          buftype = { "jumplist", "quickfix", "terminal" },
          -- if the file type is one of following, the window will be ignored
          filetype = { "neo-tree", "neo-tree-popup", "NvimTree", "notify", "snacks_notif" },
        },
        include_current_win = false,
      },
      hint = "floating-big-letter",
      picker_config = {
        floating_big_letter = {
          font = "ansi-shadow",
          -- @TODO: make a custom font
          -- @see https://github.com/s1n7ax/nvim-window-picker/blob/41cfaa428577c53552200a404ae9b3a0b5719706/lua/window-picker/hints/data/ansi-shadow.lua
          -- @see https://www.google.com/search?sca_esv=332c1457e26e21ac&q=pixel+art+alphabet&udm=2&fbs=AEQNm0CbCVgAZ5mWEJDg6aoPVcBgTlosgQSuzBMlnAdio07UCJQtmEkU6i-_BMZgWHB0gXBsp1FOhasv23lx-35-QOCW29mlVRlid8Kf_yHZgErmroOAl6jUc9HHkkkH6_CBc7hpIE9QiogFYvQMVDNW7jvnCohAAf1bR7EyQOgYVwbqXLpnJ8CkJlwMPJtusfZaIrfE5sk3AnBEO7rpHRTFA6bo01lB5w&sa=X&sqi=2&ved=2ahUKEwjD8Ifuwe-JAxWB_7sIHWjsIXsQtKgLegQIGhAB&biw=1972&bih=1305&dpr=1
          -- font = {
          --   a = {
          --     "  ▄███▄  ",
          --     "  █   █  ",
          --     "  █▐███  ",
          --     "  █   █  ",
          --     "  █   █  ",
          --   },
          --   b = {
          --     "  ████▄  ",
          --     "  █   █  ",
          --     "  █▐██   ",
          --     "  █   █  ",
          --     "  ████▀  ",
          --   },
          --   c = {
          --     "  ▄████  ",
          --     "  █      ",
          --     "  █      ",
          --     "  █      ",
          --     "  ▀████  ",
          --   },
          --   d = {
          --     "  ████▄  ",
          --     "  ▄   █  ",
          --     "  █   █  ",
          --     "  █   █  ",
          --     "  █   █  ",
          --     "  ████▀  ",
          --   },
          --   e = {
          --     "  ▄████  ",
          --     "  ▄      ",
          --     "  ███▌   ",
          --     "  █      ",
          --     "  ▀████  ",
          --   },
          -- f = table.concat({
          --   "  ▄████  ",
          --   "  ▄      ",
          --   "  ███▌   ",
          --   "  █      ",
          --   "  █      ",
          -- }, "\n"),
          -- g = table.concat({
          --   "  ▄████  ",
          --   "  █      ",
          --   "  █▐███  ",
          --   "  █   █  ",
          --   "  ▀███▀  ",
          -- }, "\n"),
          -- h = table.concat({
          --   "  █   █  ",
          --   "  █   █  ",
          --   "  █▐███  ",
          --   "  █   █  ",
          --   "  █   █  ",
          -- }, "\n"),
          -- i = table.concat({
          --   "  █████  ",
          --   "    ▄    ",
          --   "    █    ",
          --   "    █    ",
          --   "  █████  ",
          -- }, "\n"),
          --   i = [[]],
          --   j = [[]],
          --   k = [[]],
          --   l = [[]],
          --   m = [[]],
          --   n = [[]],
          --   o = [[]],
          --   p = [[]],
          --   q = [[]],
          --   r = [[]],
          --   s = [[]],
          --   t = [[]],
          --   u = [[]],
          --   v = [[]],
          --   w = [[]],
          --   x = [[]],
          --   y = [[]],
          --   z = [[]],
          --   ["0"] = [[]],
          --   ["1"] = [[]],
          --   ["2"] = [[]],
          --   ["3"] = [[]],
          --   ["4"] = [[]],
          --   ["5"] = [[]],
          --   ["6"] = [[]],
          --   ["7"] = [[]],
          --   ["8"] = [[]],
          --   ["9"] = [[]],
          -- },
        },
      },
    },
    version = "2.*",
  },

  {
    "nvim-neo-tree/neo-tree.nvim",
    dependencies = "s1n7ax/nvim-window-picker",
    opts = {
      window = {
        mappings = {
          ["<CR>"] = "open_with_window_picker",
          ["w"] = "open_with_window_picker",
        },
      },
    },
  },
}
