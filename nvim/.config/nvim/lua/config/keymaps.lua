local map = LazyVim.safe_keymap_set

-- Telescope keymaps
map("n", "<leader>t", "Telescope", { noremap = true, silent = true }) -- This just provides a readable header
map("n", "<leader>tt", ":TodoTelescope<CR>", { noremap = true, silent = true })
map("n", "<leader>tf", ":Telescope find_files<CR>", { noremap = true, silent = true })
map("n", "<leader>tg", ":Telescope live_grep<CR>", { noremap = true, silent = true })
map("n", "<leader>tb", ":Telescope buffers<CR>", { noremap = true, silent = true })

-- Copilot keymaps
map("n", "<leader>cp", "Copilot", { noremap = true, silent = true }) -- This just provides a readable header
map("n", "<leader>cpc", ":CopilotChatToggle<CR>", { noremap = true, silent = true })
map("n", "<leader>cps", ":CopilotChatSave<CR>", { noremap = true, silent = true })
map("n", "<leader>cpp", ":CopilotPanel<CR>", { noremap = true, silent = true })

-- jump windows with Ctrl + h/j/k/l
map("n", "<C-h>", ":wincmd h<CR>", { noremap = true, silent = true })
map("n", "<C-j>", ":wincmd j<CR>", { noremap = true, silent = true })
map("n", "<C-k>", ":wincmd k<CR>", { noremap = true, silent = true })
map("n", "<C-l>", ":wincmd l<CR>", { noremap = true, silent = true })

-- shirft + Ctrl + h/l to move bwtwn buffers
map("n", "<S-h>", ":bprevious<CR>", { noremap = true, silent = true })
map("n", "<S-l>", ":bnext<CR>", { noremap = true, silent = true })
