return {
  -- Highlights Tailwind CSS class names when @tailwindcss/language-server is connected
  -- https://github.com/themaxmarchuk/tailwindcss-colors.nvim
  {
    "themaxmarchuk/tailwindcss-colors.nvim",
    config = function()
      require("tailwindcss-colors").setup()
    end,
  },
}
