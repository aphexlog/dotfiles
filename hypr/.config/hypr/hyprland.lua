-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- Omarchy's bootstrap keeps path setup out of this user config.
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")

-- Disable all Omarchy default bindings. Add your own in hypr/bindings.lua.
-- omarchy_default_bindings = false
--
-- Or disable only bindings for Omarchy's preinstalled apps/web apps while
-- keeping core window-manager bindings:
-- omarchy_preinstalled_bindings = false

-- Load Omarchy defaults.
require("default.hypr.omarchy")

-- Put your personal overrides in these files. They're loaded after Omarchy's
-- defaults so package updates can improve the defaults without rewriting your
-- ~/.config/hypr files.
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- Add any other personal Hyprland configuration below.
-- o.window("qemu", { workspace = "5" })

-- ##############################################################################
-- # Steam Game Placement
-- ##############################################################################

-- Launch Steam games centered on the left monitor at half its width and height.
-- Ignore game-requested fullscreen and X11 geometry changes after placement.
o.window("^steam_app_[0-9]+$", {
  monitor = "DP-12",
  float = true,
  fullscreen = false,
  fullscreen_state = "0 0",
  size = { "monitor_w*0.5", "monitor_h*0.5" },
  center = true,
  suppress_event = "fullscreen maximize fullscreenoutput x11configurerequest",
  persistent_size = false,
})
