-- ##############################################################################
-- # WezTerm Configuration
-- ##############################################################################

local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- ##############################################################################
-- # Appearance
-- ##############################################################################

-- Color scheme
config.color_scheme = "Catppuccin Mocha"
config.window_background_opacity = 0.85

-- Font
config.font = wezterm.font("JetBrains Mono")
config.font_size = 13.0

-- Tabs
config.hide_tab_bar_if_only_one_tab = true

-- Background image
local dimmer = { brightness = 0.1 }
config.background = {
	{
		source = {
			File = wezterm.home_dir .. "/pirates.png",
		},
		hsb = dimmer,
		attachment = { Parallax = 0.1 },
	},
}

-- ##############################################################################
-- # Terminal Settings
-- ##############################################################################

-- TERM variable (supports 256 colors and proper rendering)
config.term = "wezterm"

-- ##############################################################################
-- # Key Bindings
-- ##############################################################################

-- Leader key: Ctrl+w (1 second timeout)
config.leader = { key = "w", mods = "CTRL", timeout_milliseconds = 1000 }

config.keys = {
	-- Split and run top (Leader+t)
	{
		key = "t",
		mods = "LEADER",
		action = wezterm.action.SplitVertical({
			args = { "top" },
		}),
	},
	
	-- Toggle fullscreen (Ctrl+Shift+f)
	{
		key = "f",
		mods = "CTRL|SHIFT",
		action = wezterm.action.ToggleFullScreen,
	},
	
	-- Toggle native macOS fullscreen (Ctrl+Cmd+f)
	{
		key = "f",
		mods = "CTRL|CMD",
		action = wezterm.action.ToggleFullScreen,
	},
}

return config
