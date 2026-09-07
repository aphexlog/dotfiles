return {

  "mason-org/mason.nvim",
  cmd = "Mason",
  keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
  build = ":MasonUpdate",
  opts_extend = { "ensure_installed" },
  opts = {
    ensure_installed = {
      "stylua",
      "shfmt",
      "lua-language-server",
      "pyright",
      "terraform-ls",
      "jq",
      "tailwindcss-language-server",
      "gopls",
      "eslint-lsp",
      "json-lsp", -- Added JSON LSP server
    },
  },
}
