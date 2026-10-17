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
      action = hl.dsp.window.resize()
    end
  end

  hl.dispatch(action)
end)
