return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "github/copilot.vim" }, -- Required for Copilot integration
      { "nvim-lua/plenary.nvim" }, -- For async functions
    },
    build = "make tiktoken", -- Only on macOS or Linux
    opts = {
      enabled = true,
      auto_trigger = true,
      language = "en-US",
      window = {
        layout = "float",
        relative = "editor",
        width = 0.8,
        height = 0.8,
      },
      suggestion = {
        enabled = true,
        auto_trigger = true,
        hide_during_completion = false,
        debounce = 75,
        keymap = {
          accept = "<C-M-j>",
          accept_word = "<C-M-k>",
          accept_line = "<C-M-l>",
          next = "<C-M-n>",
          prev = "<C-M-p>",
          dismiss = "<C-M-h>",
        },
      },
      panel = {
        enabled = true,
        auto_refresh = true,
        keymap = {
          toggle = "<C-M-m>",
        },
      },
    },
    config = function(_, opts)
      -- Define a custom UUID function if not already present
      if not vim.fn.has("uuid") then
        vim.fn.uuid = function()
          local handle = io.popen("uuidgen")
          if handle then
            local result = handle:read("*a")
            handle:close()
            return result:gsub("\n", "")
          end
          return nil
        end
      end

      -- Initialize CopilotChat
      local copilot_chat = require("CopilotChat")
      if copilot_chat then
        copilot_chat.setup(opts)
      end

      -- Set up Copilot completion mappings
      vim.api.nvim_set_keymap("i", "<C-M-j>", 'copilot#Accept("<CR>")', { expr = true, silent = true })
      vim.api.nvim_set_keymap("i", "<C-M-k>", "copilot#AcceptWord()", { expr = true, silent = true })
      vim.api.nvim_set_keymap("i", "<C-M-l>", "copilot#AcceptLine()", { expr = true, silent = true })
      vim.api.nvim_set_keymap("i", "<C-M-n>", "copilot#Next()", { expr = true, silent = true })
      vim.api.nvim_set_keymap("i", "<C-M-p>", "copilot#Previous()", { expr = true, silent = true })
      vim.api.nvim_set_keymap("i", "<C-M-h>", "copilot#Dismiss()", { expr = true, silent = true })

      -- Keybinding to toggle CopilotChat
      vim.api.nvim_set_keymap("n", "<C-M-m>", ":CopilotChatToggle<CR>", { noremap = true, silent = true })
    end,
  },
}
