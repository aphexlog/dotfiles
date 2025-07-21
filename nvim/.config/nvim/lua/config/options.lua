-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.autoformat = true
vim.g.lazygit_config = true

local opt = vim.opt

opt.wrap = true -- Wrap lines
opt.mouse = "a" -- Enable mouse mod
opt.smartcase = true -- Don't ignore case with capitals
opt.smartindent = true -- Insert indents automatically
opt.wildmode = "longest:full,full" -- Command-line completion mode
opt.virtualedit = "block" -- Allow cursor to move where there is no text in visual block mode
opt.tabstop = 2 -- Number of spaces tabs count for
opt.linebreak = true -- Wrap lines at convenient points
opt.expandtab = true -- Use spaces instead of tabs
opt.cursorline = true -- Enable highlighting of the current line
opt.confirm = true -- Confirm to save changes before exiting modified buffer
