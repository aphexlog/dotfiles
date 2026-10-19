-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

-- Keep GTK scaling neutral and enlarge the portrait display slightly.
local omarchy_gdk_scale = 1

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))

-- Per-monitor layout rules stay out of this file on purpose. It is version
-- controlled, and the displays here sit behind a DisplayPort MST hub whose
-- connector numbering shifts (DP-12/DP-7 became DP-13/DP-8) whenever the hub
-- topology is rebuilt, so anything keyed to a connector name silently stops
-- matching. It happened once, unnoticed, and the layout quietly fell back to
-- defaults.
--
-- Configure monitors at runtime instead, either from the Omarchy Display panel
-- or with `hyprctl eval 'hl.monitor({...})'`. Note that runtime changes are NOT
-- persisted: they last only for the session, so keep anything you want to come
-- back after a reboot in a file. If a rule does belong in a file, key it to the
-- monitor rather than its connector:
--
--   hl.monitor({ output = "desc:LG Electronics LG Ultra HD 0x0000DCEF",
--                mode = "3840x2160@60", position = "0x450", scale = 1, transform = 0 })
--
-- Machine-specific rules like that one live in ~/.config/hypr/monitors-local.lua,
-- which is required (when present) from hyprland.lua and kept out of this repo.
--
-- Check what actually matched with: hyprctl monitors all
-- The unqualified connector names below (DP-2) are the only ones safe to commit,
-- because they are commented examples rather than this machine's hardware.

-- Configure a specific monitor.
-- hl.monitor({ output = "DP-2", mode = "2560x1440@144", position = "0x0", scale = 1 })

-- Portrait/rotated secondary monitor (transform: 1 = 90°, 3 = 270°).
-- hl.monitor({ output = "DP-2", mode = "preferred", position = "auto", scale = 1, transform = 1 })
--
