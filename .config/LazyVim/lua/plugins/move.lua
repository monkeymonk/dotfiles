return {
  -- Gain the power to move lines and blocks and auto-indent them!
  -- https://github.com/fedepujol/move.nvim
  {
    "fedepujol/move.nvim",
    keys = {
      -- Moves a line up or down
      {
        "<A-Up>",
        "<cmd> MoveLine(-1) <CR>",
        desc = "Move line up",
        mode = "n",
      },
      {
        "<A-Down>",
        "<cmd> MoveLine(1) <CR>",
        desc = "Move line down",
        mode = "n",
      },
      -- Moves the character under the cursor, left or right
      {
        "<A-Left>",
        "<cmd> MoveHChar(-1) <CR>",
        desc = "Move character(s) left",
        mode = "n",
      },
      {
        "<A-Right>",
        "<cmd> MoveHChar(1) <CR>",
        desc = "Move character(s) right",
        mode = "n",
      },
      -- Moves the word under the cursor forwards or backwards
      {
        "wf",
        "<cmd> MoveWord(1) <CR>",
        desc = "Move word forward",
        mode = "n",
      },
      {
        "wb",
        "<cmd> MoveWord(-1) <CR>",
        desc = "Move word backward",
        mode = "n",
      },
      -- Note: <cmd> is not working for those methods (why?)
      -- Moves a selected block of text, up or down
      {
        "<A-Up>",
        ":MoveBlock(-1) <CR>",
        desc = "Move block up",
        mode = "v",
      },
      {
        "<A-Down>",
        ":MoveBlock(1) <CR>",
        desc = "Move block down",
        mode = "v",
      },
      -- Moves a visual area, left or right
      {
        "<A-Right>",
        ":MoveHBlock(1) <CR>",
        desc = "Move block up",
        mode = "v",
      },
      {
        "<A-Left>",
        ":MoveHBlock(-1) <CR>",
        desc = "Move block down",
        mode = "v",
      },
    },
    opts = {
      line = {
        enable = true,
        indent = true,
      },
      block = {
        enable = true,
        indent = true,
      },
      word = {
        enable = true,
      },
      char = {
        enable = true,
      },
    },
  },
}
