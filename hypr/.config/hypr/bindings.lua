-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Summon the keyboard-navigable Chrono calendar.
o.bind("SUPER + ALT + C", "Chrono calendar", "omarchy-shell shell toggle aphexlog.clock")

-- Open OLauncher directly in Apps.
hl.unbind("SUPER + SPACE")
o.bind("SUPER + SPACE", "OLauncher", [[omarchy-shell shell toggle olauncher '{"filter":"apps"}']])
o.bind("ALT + SPACE", "OLauncher", [[omarchy-shell shell toggle olauncher '{"filter":"apps"}']])

-- Drag a screenshot region and copy it directly to the clipboard.
o.bind("SUPER + CTRL + SHIFT + 4", "Region screenshot to clipboard", "omarchy capture screenshot region copy")

-- Replace move-to-workspace-5 with region recording; press again to finish.
hl.unbind("SUPER + SHIFT + code:14")
hl.unbind("SUPER + SHIFT + 5")
o.bind("SUPER + SHIFT + 5", "Region recording to clipboard", "$HOME/.local/bin/record-region-clipboard")

-- Replace Calculator with the requested lock shortcut.
hl.unbind("SUPER + CTRL + Q")
o.bind("SUPER + CTRL + Q", "Lock computer", "omarchy system lock")

-- ##############################################################################
-- # Cyber Scratchpad Terminal
-- ##############################################################################

-- Show/hide a persistent terminal above the current workspace.
o.bind("SUPER + GRAVE", "Cyber scratchpad terminal", "$HOME/.local/bin/cyber-scratchpad")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")

-- Close the active window with SUPER + Q only.
hl.unbind("SUPER + W")
o.bind("SUPER + Q", "Close window", hl.dsp.window.close())

-- Toggle the active Athena bar, falling back to Omarchy when Athena is stopped.
hl.unbind("SUPER + SHIFT + SPACE")
o.bind("SUPER + SHIFT + SPACE", "Toggle top bar", "$HOME/.local/bin/athena-bar toggle")

-- ##############################################################################
-- # Desktop Controls
-- ##############################################################################

-- Open the desktop control center (previously disabled display settings).
o.rebind("SUPER + CTRL + D", "Desktop controls", "omarchy-shell shell toggle aphexlog.controls")

-- Keep scaling and output changes in the panel, where their targets are visible.
hl.unbind("SUPER + SLASH")
hl.unbind("SUPER + ALT + SLASH")
hl.unbind("SUPER + CTRL + Delete")
hl.unbind("SUPER + CTRL + ALT + Delete")

-- ##############################################################################
-- # Per-Monitor Wallpapers
-- ##############################################################################

-- Replace the stock Background switcher with the custom set for each monitor.
hl.unbind("SUPER + CTRL + SPACE")
o.bind("SUPER + CTRL + SPACE", "Per-monitor wallpaper picker", "$HOME/.local/bin/wallpaper-monitor-pick")

-- ##############################################################################
-- # Clipboard and Selection
-- ##############################################################################

-- Complement Omarchy's universal SUPER + C/V bindings with select all.
o.bind("SUPER + A", "Select all", function()
  hl.dispatch(hl.dsp.send_key_state({ mods = "CTRL", key = "A", state = "down" }))
  hl.timer(function()
    hl.dispatch(hl.dsp.send_key_state({ mods = "CTRL", key = "A", state = "up" }))
  end, { timeout = 50, type = "oneshot" })
end)

-- ##############################################################################
-- # Undo and Redo
-- ##############################################################################

-- Forward standard undo/redo shortcuts to the focused application.
o.bind("SUPER + Z", "Undo", function()
  hl.dispatch(hl.dsp.send_key_state({ mods = "CTRL", key = "Z", state = "down" }))
  hl.timer(function()
    hl.dispatch(hl.dsp.send_key_state({ mods = "CTRL", key = "Z", state = "up" }))
  end, { timeout = 50, type = "oneshot" })
end)

o.bind("SUPER + SHIFT + Z", "Redo", function()
  hl.dispatch(hl.dsp.send_key_state({ mods = "CTRL SHIFT", key = "Z", state = "down" }))
  hl.timer(function()
    hl.dispatch(hl.dsp.send_key_state({ mods = "CTRL SHIFT", key = "Z", state = "up" }))
  end, { timeout = 50, type = "oneshot" })
end)

-- ##############################################################################
-- # Window Dragging
-- ##############################################################################

-- Extend Super + left-drag (previously move-only) with edge resizing.
hl.unbind("SUPER + mouse:272")
o.bind("SUPER + mouse:272", "Move window or resize near an edge", function()
  local action = hl.dsp.window.drag()
  local window = hl.get_active_window()
  local cursor = hl.get_cursor_pos()

  if window and cursor and window.fullscreen == 0 then
    local position = window.at
    local size = window.size
    local x = cursor.x - position.x
    local y = cursor.y - position.y
    local grab = hl.get_config("general.border_size") + hl.get_config("general.extend_border_grab_area")
    local near_window = x >= -grab and x <= size.x + grab
      and y >= -grab and y <= size.y + grab
    local near_edge = x <= grab or x >= size.x - grab
      or y <= grab or y >= size.y - grab

    if near_window and near_edge then
      action = hl.dsp.window.resize({ keep_aspect_ratio = false })
    end
  end

  hl.dispatch(action)
end)

-- Start interactive resizing from the pointer's current position.
o.rebind("SUPER + mouse:273", "Resize window", function()
  hl.dispatch(hl.dsp.window.resize({ keep_aspect_ratio = false }))
end)

-- Dictation keys from before Alt + Space and Right Alt became the defaults.
-- Remove these lines to give the keys back to applications.
if o.dictation_installed and o.dictation_installed() then
  o.bind("SUPER + CTRL + X", "Toggle dictation", "omarchy-dictation toggle")
  o.bind_hold("F9", "Start dictation (push-to-talk)", "omarchy-dictation start", "Stop dictation (push-to-talk)", "omarchy-dictation stop")
end
