-- Vim plugin for automatic time tracking and metrics generated from your programming activity.
-- https://github.com/wakatime/vim-wakatime
return {
  "wakatime/vim-wakatime",
  event = "BufReadPost", -- Load after first buffer is read (still tracks accurately)
}
