local map = LazyVim.safe_keymap_set

-- Picker keymaps
map("n", "<leader>t", "<Nop>", { desc = "Pickers" })
map("n", "<leader>tt", function() Snacks.picker.todo_comments() end, { desc = "Todo" })
map("n", "<leader>tf", function() Snacks.picker.files() end, { desc = "Find Files" })
map("n", "<leader>tg", function() Snacks.picker.grep() end, { desc = "Search Text" })
map("n", "<leader>tb", function() Snacks.picker.buffers() end, { desc = "Buffers" })

-- jump windows with Ctrl + h/j/k/l
map("n", "<C-h>", ":wincmd h<CR>", { noremap = true, silent = true })
map("n", "<C-j>", ":wincmd j<CR>", { noremap = true, silent = true })
map("n", "<C-k>", ":wincmd k<CR>", { noremap = true, silent = true })
map("n", "<C-l>", ":wincmd l<CR>", { noremap = true, silent = true })

-- shirft + Ctrl + h/l to move bwtwn buffers
map("n", "<S-h>", ":bprevious<CR>", { noremap = true, silent = true })
map("n", "<S-l>", ":bnext<CR>", { noremap = true, silent = true })

-- create split windows
map("n", "<leader>wv", ":vsplit<CR>", { noremap = true, silent = true })
map("n", "<leader>wh", ":split<CR>", { noremap = true, silent = true })
map("n", "<leader>wx", ":close<CR>", { noremap = true, silent = true }) -- close current split window

-- Vim Debug keymaps (debugging Neovim itself)
map("n", "<leader>d", "Vim Debug", { noremap = true, silent = true }) -- Header
map("n", "<leader>dm", ":messages<CR>", { desc = "Messages" })
map("n", "<leader>dh", ":checkhealth<CR>", { desc = "Health Check" })
map("n", "<leader>dl", ":Lazy<CR>", { desc = "Lazy" })
map("n", "<leader>di", ":LspInfo<CR>", { desc = "LSP Info" })
map("n", "<leader>dr", function()
  vim.cmd("LspRestart")
  vim.notify("LSP servers restarted")
end, { desc = "LSP Restart" })

-- Code Debug keymaps (debugging your code)
map("n", "<leader>x", "Code Debug", { noremap = true, silent = true }) -- Header
map("n", "<leader>xd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
map("n", "<leader>xq", vim.diagnostic.setloclist, { desc = "Quickfix Diagnostics" })
