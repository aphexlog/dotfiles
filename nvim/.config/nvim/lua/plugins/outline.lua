return {
  "hedyhli/outline.nvim",
  cmd = "Outline",
  keys = {
    { "<leader>o", "<cmd>Outline<cr>", desc = "Toggle Outline" },
  },
  config = function()
    require("outline").setup({
      outline_window = {
        auto_resize = true,
      },
    })
  end,
}
