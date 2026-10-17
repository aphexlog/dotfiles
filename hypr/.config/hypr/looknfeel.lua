-- Change the default Omarchy look'n'feel.

-- ##############################################################################
-- # Futuristic Window Styling
-- ##############################################################################

-- Neon focus borders and generous spacing keep tiled windows distinct.
hl.config({
  general = {
    gaps_in = 6,
    gaps_out = 12,
    border_size = 2,
    col = {
      active_border = { colors = { "rgba(55ddffff)", "rgba(a78bffff)" }, angle = 45 },
      inactive_border = "rgba(454b6688)",
    },

    -- Require a Super-modified drag rather than resizing on ordinary taps.
    resize_on_border = false,
  },
  -- Round the silhouette and add depth without reducing text opacity.
  decoration = {
    rounding = 16,
    shadow = {
      enabled = true,
      range = 24,
      render_power = 3,
      color = "rgba(080b20aa)",
    },
    blur = {
      enabled = true,
      size = 6,
      passes = 2,
    },
    dim_inactive = true,
    dim_strength = 0.08,
  },
})

-- Keep opening animations smooth and restrained.
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "popin 94%" })

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
