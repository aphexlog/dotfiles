return {
  "vuki656/review.nvim",
  lazy = true,
  cmd = "Review",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  keys = {
    { "<leader>rv", "<cmd>Review<cr>", desc = "Toggle review" },
  },
  opts = {},
}
