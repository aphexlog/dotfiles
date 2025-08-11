-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is going to dim the brightness of the terminal
local dimmer = { brightness = 0.1 }

-- For example, changing the color scheme:
-- config.color_scheme = "Vacuous 2 (terminal.sexy)"
config.color_scheme = "Catppuccin Mocha"
config.window_background_opacity = 0.85

config.hide_tab_bar_if_only_one_tab = true
config.font_size = 13.0
config.font = wezterm.font("JetBrains Mono")

config.leader = { key = "w", mods = "CTRL", timeout_milliseconds = 1000 }
-- Background image configuration

config.background = {
	{
		source = {
			File = wezterm.home_dir .. "/space.jpg",
		},
		hsb = dimmer,
		attachment = { Parallax = 0.1 },
	},
}

config.keys = {
	-- This will create a new split and run the `top` program inside it
	{
		key = "t",
		mods = "LEADER",
		action = wezterm.action.SplitVertical({
			args = { "top" },
		}),
	},
}

-- and finally, return the configuration to wezterm
return config
