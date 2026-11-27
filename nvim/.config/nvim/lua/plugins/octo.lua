return {
  "pwntester/octo.nvim",
  lazy = true,
  cmd = "Octo",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "folke/snacks.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
    picker = "snacks",
    enable_builtin = true,
    default_remote = { "origin" },
  },
  keys = {
    { "<leader>oi", "<cmd>Octo issue list<cr>", desc = "List GitHub Issues" },
    { "<leader>op", "<cmd>Octo pr list<cr>", desc = "List GitHub PullRequests" },
    { "<leader>od", "<cmd>Octo discussion list<cr>", desc = "List GitHub Discussions" },
    { "<leader>on", "<cmd>Octo notification list<cr>", desc = "List GitHub Notifications" },
    { "<leader>or", "<cmd>Octo review start<cr>", desc = "Start PR Review" },
  },
}
