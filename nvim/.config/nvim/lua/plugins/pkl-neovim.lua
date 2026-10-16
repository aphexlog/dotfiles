return {
  "apple/pkl-neovim",
  lazy = true,
  ft = "pkl",
  dependencies = {
    {
      "nvim-treesitter/nvim-treesitter",
      build = function(_)
        vim.cmd("TSUpdate")
      end,
    },
    "L3MON4D3/LuaSnip",
  },
  build = function()
    require("pkl-neovim").init()

    -- Wait for parser installation with the current Treesitter API.
    require("nvim-treesitter").install({ "pkl" }):wait(300000)
  end,
  config = function()
    -- Set up snippets.
    require("luasnip.loaders.from_snipmate").lazy_load()
  end,
}
