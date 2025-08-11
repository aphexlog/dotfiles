-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
vim.opt.shell = "/bin/zsh"
vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "NONE" })
