return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  keys = {
    { "<leader>fm", "<cmd>RenderMarkdown toggle<cr>", desc = "Toggle Markdown rendering" },
  },
  opts = {
    preset = "obsidian",
  },
}
