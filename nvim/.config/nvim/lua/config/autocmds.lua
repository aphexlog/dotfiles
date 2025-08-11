-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- Ensure terminal windows are transparent
vim.api.nvim_create_autocmd("TermOpen", {
  callback = function()
    vim.cmd("setlocal winhighlight=Normal:Normal,NormalNC:Normal")
  end,
})
