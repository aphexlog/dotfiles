return {
  "goolord/alpha-nvim",
  lazy = false,
  priority = 1000,
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local status_ok, alpha = pcall(require, "alpha")
    if not status_ok then
      return
    end

    local dashboard = require("alpha.themes.dashboard")

    dashboard.file_icons = "devicons"
    dashboard.section.header.val = require("ascii_art.skullandaxe")

    dashboard.section.buttons.val = {
      dashboard.button("f", "👽  Find Files", ":lua Snacks.picker.files()<CR>"),
      dashboard.button("e", "🎄  New File", ":ene <BAR> startinsert <CR>"),
      dashboard.button("r", "🧙  Recent Files", ":lua Snacks.picker.recent()<CR>"),
      dashboard.button("t", "🛸  Search Text", ":lua Snacks.picker.grep()<CR>"),
      dashboard.button("q", "🎃  Quit", ":qa<CR>"),
      dashboard.button("c", "⚙️  Config", ":lua Snacks.picker.files({ cwd = vim.fn.stdpath('config') })<CR>"),
    }

    dashboard.section.footer.val = "Welcome home Aphexlog"
    dashboard.section.header.opts.hl = "Include"
    dashboard.section.buttons.opts.hl = "Keyword"
    dashboard.section.footer.opts.hl = "Type"
    dashboard.opts.opts.noautocmd = true

    alpha.setup(dashboard.opts)
  end,
}
