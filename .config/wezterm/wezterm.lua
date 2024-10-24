local wezterm = require("wezterm")
local h = require("utils/helpers")
local c = require("utils/color_scheme")
local config = wezterm.config_builder()

-- @see https://github.com/catppuccin/wezterm
config.color_scheme = c.get_color_scheme()
config.font = wezterm.font("FiraCode Nerd Font")
config.enable_tab_bar = false
config.use_fancy_tab_bar = false
config.window_background_opacity = 0.8

config.set_environment_variables = {
	-- BAT_THEME = "Catppuccin-mocha",
	LC_ALL = "en_US.UTF-8",
}

config.adjust_window_size_when_changing_font_size = false
config.debug_key_events = false
-- config.window_decorations = "RESIZE"
config.window_padding = {
	bottom = 0,
	left = 0,
	right = 0,
	top = 0,
}

-- Bindings
-- config.disable_default_key_bindings = true
config.keys = {
	{
		key = "Space",
		mods = "CTRL|SHIFT",
		action = wezterm.action.DisableDefaultAssignment,
	},
	{
		key = "P",
		mods = "SHIFT|CTRL",
		action = wezterm.action.ActivateCommandPalette,
	},
}

config.mouse_bindings = {
	-- Ctrl-click will open the link under the mouse cursor
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "CTRL",
		action = wezterm.action.OpenLinkAtMouseCursor,
	},
}

-- Disable Tabs (we use TMUX instead)
config.enable_tab_bar = false
config.show_new_tab_button_in_tab_bar = false
config.tab_bar_at_bottom = false
config.tab_max_width = 32
config.use_fancy_tab_bar = false

return config
