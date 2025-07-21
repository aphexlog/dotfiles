return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    filesystem = {
      filtered_items = {
        visible = false,
        show_hidden_count = true,
        hide_dotfiles = true,
        hide_gitignored = true,
        hide_by_name = {
          -- '.git',
          -- '.DS_Store',
          -- 'thumbs.db',
        },
        never_show = {},
      },
    },
    window = {
      mappings = {
        ["P"] = "toggle_preview",
        ["Y"] = function(state)
          local node = state.tree:get_node()
          local filepath = node:get_id()
          -- Copy the absolute path to the system clipboard
          vim.fn.setreg("+", filepath)
          -- Optionally, display a message to confirm the action
          vim.notify("Copied absolute path to clipboard:\n" .. filepath)
        end,
        ["<C-y>"] = function(state)
          local node = state.tree:get_node()
          local filename = node:get_id():match("([^/]+)$")
          -- Copy the filename to the system clipboard
          vim.fn.setreg("+", filename)
          -- Optionally, display a message to confirm the action
          vim.notify("Copied filename to clipboard:\n" .. filename)
        end,
      },
    },
  },
}
