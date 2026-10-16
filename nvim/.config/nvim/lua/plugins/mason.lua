return {

  "mason-org/mason.nvim",
  cmd = "Mason",
  keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
  build = ":MasonUpdate",
  opts_extend = { "ensure_installed" },
  opts = {
    -- Go tools require a Go installation; the other tools are self-contained.
    ensure_installed = vim.list_extend({
      "stylua",
      "shfmt",
      "lua-language-server",
      "pyright",
      "terraform-ls",
      "jq",
      "tailwindcss-language-server",
      "eslint-lsp",
      "json-lsp", -- Added JSON LSP server
    }, vim.fn.executable("go") == 1 and { "gopls" } or {}),
  },
}
