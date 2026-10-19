-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

-- Keep GTK scaling neutral and enlarge the portrait display slightly.
local omarchy_gdk_scale = 1

-- Match by monitor description, not connector name. These displays hang off a
-- DisplayPort MST hub, whose connector numbering shifts (DP-12/DP-7 became
-- DP-13/DP-8) whenever the hub topology is torn down and rebuilt, which
-- silently voided the old name-based rules.
local ultrahd = "desc:LG Electronics LG Ultra HD 0x0000DCEF"
local hdr4k = "desc:LG Electronics LG HDR 4K 0x0005CD72"

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
hl.monitor({ output = ultrahd, mode = "3840x2160@60", position = "0x450", scale = 1, transform = 0 })
hl.monitor({ output = hdr4k, mode = "3840x2160@60", position = "3840x0", scale = 1.2, transform = 1 })

-- Keep the first two workspaces ordered from left to right.
hl.workspace_rule({ workspace = "1", monitor = ultrahd, default = true, persistent = true })
hl.workspace_rule({ workspace = "2", monitor = hdr4k, default = true, persistent = true })

-- Configure a specific monitor.
-- hl.monitor({ output = "DP-2", mode = "2560x1440@144", position = "0x0", scale = 1 })

-- Portrait/rotated secondary monitor (transform: 1 = 90°, 3 = 270°).
-- hl.monitor({ output = "DP-2", mode = "preferred", position = "auto", scale = 1, transform = 1 })
--
