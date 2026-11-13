-- Change the default Omarchy look'n'feel.

-- ##############################################################################
-- # PHX Midnight Circuit Window Styling
-- ##############################################################################

-- Crisp cyan-to-magenta edges tie windows into the paired desktop bars.
hl.config({
  general = {
    gaps_in = 6,
    gaps_out = 12,
    border_size = 2,
    col = {
      active_border = { colors = { "rgba(00e5ffdd)", "rgba(f072ffdd)" }, angle = 35 },
      inactive_border = "rgba(254253aa)",
    },

    -- Require a Super-modified drag rather than resizing on ordinary taps.
    resize_on_border = false,
  },
  -- Tighter corners, ink-dark shadows, and a quieter inactive treatment.
  decoration = {
    rounding = 8,
    shadow = {
      enabled = true,
      range = 20,
      render_power = 3,
      color = "rgba(030810bb)",
    },
    blur = {
      enabled = true,
      size = 4,
      passes = 2,
    },
    dim_inactive = true,
    dim_strength = 0.04,
  },
})

-- Keep opening animations smooth and restrained.
hl.animation({ leaf = "windowsIn", enabled = true, speed = 5.5, bezier = "easeOutQuint", style = "popin 98%" })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#general
-- hl.config({
--   general = {
--     -- No gaps between windows or borders.
--     gaps_in = 0,
--     gaps_out = 0,
--     border_size = 0,
--
--     -- Change to niri-like side-scrolling layout.
--     layout = "scrolling",
--   },
-- })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#decoration
-- hl.config({
--   decoration = {
--     -- Use round window corners.
--     rounding = 8,
--
--     -- Dim unfocused windows (0.0 = no dim, 1.0 = fully dimmed).
--     dim_inactive = true,
--     dim_strength = 0.15,
--   },
-- })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#animations
-- hl.config({
--   animations = {
--     -- Disable all animations.
--     enabled = false,
--   },
-- })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#layout
-- hl.config({
--   layout = {
--     -- Avoid overly wide single-window layouts on wide screens.
--     single_window_aspect_ratio = { 1, 1 },
--   },
-- })

-- https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/
-- hl.config({
--   scrolling = {
--     -- See only one column per screen instead of two.
--     column_width = 0.97,
--   },
-- })

-- Opt another application in to Omarchy's standard transparency.
-- Find its class with: hyprctl clients
-- o.transparent_window("my-app")
-- o.transparent_window("my-app", "0.9 0.85") -- Custom active/inactive opacity.
