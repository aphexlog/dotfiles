-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

-- Keep GTK scaling neutral and enlarge the portrait display slightly.
local omarchy_gdk_scale = 1

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
hl.monitor({ output = "DP-12", mode = "3840x2160@60", position = "0x0", scale = 1, transform = 0 })
hl.monitor({ output = "DP-7", mode = "3840x2160@60", position = "3840x0", scale = 1.2, transform = 1 })

-- Keep the first two workspaces ordered from left to right.
hl.workspace_rule({ workspace = "1", monitor = "DP-12", default = true, persistent = true })
hl.workspace_rule({ workspace = "2", monitor = "DP-7", default = true, persistent = true })

-- Configure a specific monitor.
-- hl.monitor({ output = "DP-2", mode = "2560x1440@144", position = "0x0", scale = 1 })

-- Portrait/rotated secondary monitor (transform: 1 = 90°, 3 = 270°).
-- hl.monitor({ output = "DP-2", mode = "preferred", position = "auto", scale = 1, transform = 1 })
--
