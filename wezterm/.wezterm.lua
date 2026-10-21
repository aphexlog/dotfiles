-- ##############################################################################
-- # WezTerm Configuration
-- ##############################################################################

local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Linux runs under Hyprland; macOS keeps its native window chrome and terminal
-- database defaults.
local is_macos = wezterm.target_triple:find("darwin") ~= nil

-- ##############################################################################
-- # Appearance
-- ##############################################################################

-- Neon Circuit: midnight surfaces with violet, electric blue, and mint accents.
local palette = {
  background = "#0b1020",
  surface = "#141b30",
  selection = "#34305a",
  foreground = "#c8d6f4",
  muted = "#7b8bad",
  blue = "#6ea8ff",
  purple = "#b794ff",
  green = "#65e6b4",
  cyan = "#68d9ef",
  red = "#ff7b98",
  yellow = "#e7cf8b",
}

-- Keep error/warning colors recognizable while emphasizing the cool spectrum.
config.colors = {
  foreground = palette.foreground,
  background = palette.background,
  cursor_bg = palette.green,
  cursor_fg = palette.background,
  cursor_border = palette.green,
  compose_cursor = palette.purple,
  selection_fg = palette.foreground,
  selection_bg = palette.selection,
  scrollbar_thumb = palette.surface,
  split = "#2b3654",
  ansi = {
    "#1b243b",
    palette.red,
    palette.green,
    palette.yellow,
    palette.blue,
    palette.purple,
    palette.cyan,
    palette.foreground,
  },
  brights = {
    palette.muted,
    "#ff9db3",
    "#92f5cc",
    "#f5e2aa",
    "#9bc4ff",
    "#d1b5ff",
    "#96edff",
    "#eef4ff",
  },
  tab_bar = {
    background = palette.background,
    inactive_tab_edge = palette.background,
    active_tab = {
      bg_color = "#24213d",
      fg_color = palette.purple,
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = palette.background,
      fg_color = palette.muted,
    },
    inactive_tab_hover = {
      bg_color = palette.surface,
      fg_color = palette.blue,
    },
    new_tab = {
      bg_color = palette.background,
      fg_color = palette.green,
    },
    new_tab_hover = {
      bg_color = palette.surface,
      fg_color = palette.green,
    },
  },
}

-- Preserve the font size, with Nerd Font glyphs for prompts and terminal tools.
-- JetBrains Mono stays primary because it is installed everywhere; the Nerd Font
-- build is only a fallback, so machines without it keep the same metrics.
config.font = wezterm.font_with_fallback({ "JetBrains Mono", "JetBrainsMono Nerd Font" })
config.font_size = 13.0
config.line_height = 1.05
config.bold_brightens_ansi_colors = false

-- Let Hyprland handle resizing without a client-side title bar or border. macOS
-- keeps its normal traffic-light title bar: WezTerm documents that NONE breaks
-- resize/minimise and window focus there.
config.window_decorations = is_macos and "TITLE | RESIZE" or "NONE"
config.window_background_opacity = 0.96
config.window_padding = {
  left = 20,
  right = 20,
  top = 16,
  bottom = 16,
}
config.enable_scroll_bar = false
config.inactive_pane_hsb = { saturation = 0.9, brightness = 0.8 }

-- Compact tabs stay out of the way until there is more than one.
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true
config.tab_max_width = 28

-- Mint cursor and matching command-palette surfaces.
config.default_cursor_style = "SteadyBar"
config.cursor_thickness = 2
config.command_palette_bg_color = palette.surface
config.command_palette_fg_color = palette.foreground

-- ##############################################################################
-- # Terminal Settings
-- ##############################################################################

-- TERM variable (supports 256 colors and proper rendering). The wezterm terminfo
-- entry is installed by the Linux package; macOS has no such entry unless it was
-- added by hand with `tic`, so keep the portable default there.
config.term = is_macos and "xterm-256color" or "wezterm"

-- Pick up edits to this Stow-managed configuration without restarting shells.
config.automatically_reload_config = true

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
