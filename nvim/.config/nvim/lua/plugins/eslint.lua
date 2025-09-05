return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        eslint = {
          root_dir = function(fname)
            local util = require("lspconfig.util")
            return util.root_pattern(
              ".eslintrc.js",
              ".eslintrc.cjs",
              ".eslintrc.yaml",
              ".eslintrc.yml",
              ".eslintrc.json",
              "eslint.config.js",
              "package.json"
            )(fname)
          end,
          settings = {
            workingDirectory = { mode = "auto" },
            format = { enable = true },
            lint = { enable = true },
            useESLintClass = true,
          },
          on_attach = function(client, bufnr)
            -- Ensure ESLint handles both linting and formatting
            client.server_capabilities.documentFormattingProvider = true
            client.server_capabilities.documentRangeFormattingProvider = true
          end,
        },
      },
    },
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        javascript = {},
        javascriptreact = {},
        typescript = {},
        typescriptreact = {},
      },
    },
  },
}
