-- ##############################################################################
-- # Status Line Appearance
-- ##############################################################################

return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    -- Match the editor palette and soften the transitions between sections.
    opts.options.theme = "catppuccin"
    opts.options.globalstatus = true
    opts.options.component_separators = ""
    opts.options.section_separators = { left = "", right = "" }

    -- Cap both ends of the mode and clock badges with rounded edges.
    opts.sections.lualine_a = {
      -- Give the leading cap a neutral background instead of the mode color.
      {
        function()
          return " "
        end,
        color = function()
          return { bg = require("catppuccin.palettes").get_palette("mocha").base }
        end,
        separator = "",
        padding = 0,
      },
      {
        "mode",
        separator = { left = "", right = "" },
        padding = 1,
      },
    }
    opts.sections.lualine_z = {
      {
        function()
          return os.date("%H:%M")
        end,
        separator = { left = "", right = "" },
        padding = 1,
      },
    }
  end,
}
