return {
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        python = { "black", "isort" },
      },
      formatters = {
        black = {
          command = "uv",
          args = { "run", "--all-groups", "black", "--stdin-filename", "$FILENAME", "-" },
          cwd = require("conform.util").root_file({ "pyproject.toml" }),
        },
        isort = {
          command = "uv",
          args = { "run", "--all-groups", "isort", "--stdout", "--filename", "$FILENAME", "-" },
          cwd = require("conform.util").root_file({ "pyproject.toml" }),
        },
      },
    },
  },
}
