return {
  {
    "luk400/vim-jukit",
    ft = { "python", "json", "ipynb" },
    init = function()
      -- Use system python3
      vim.g.python3_host_prog = vim.fn.exepath("python3")
      vim.g.jukit_shell_cmd = "ipython3"
      vim.g._jukit_python_os_cmd = "python3"
      -- Use nvimterm to avoid terminal issues
      vim.g.jukit_terminal = "nvimterm"
      vim.g.jukit_auto_output_hist = 0
      vim.g.jukit_use_tcomment = 0
      -- disable defaults and prevent E121
      vim.g.jukit_mappings = 0
      vim.g.jukit_outhist_buf = -1
    end,
    config = function()
      local km = vim.keymap.set
      local base_opts = { noremap = true, silent = true }

      -- Navigate between cells
      km(
        "n",
        "<leader>jj",
        ":call jukit#cells#jump_to_next_cell()<CR>",
        vim.tbl_extend("force", base_opts, { desc = "Jukit: Next cell" })
      )
      km(
        "n",
        "<leader>jk",
        ":call jukit#cells#jump_to_previous_cell()<CR>",
        vim.tbl_extend("force", base_opts, { desc = "Jukit: Previous cell" })
      )

      -- History group (<leader>j h *)
      km("n", "<leader>jh", "", vim.tbl_extend("force", base_opts, { desc = "History" }))
      km(
        "n",
        "<leader>jhs",
        ":call jukit#splits#history()<CR>",
        vim.tbl_extend("force", base_opts, { desc = "Jukit: Open history" })
      )
      km(
        "n",
        "<leader>jhd",
        ":call jukit#splits#close_history()<CR>",
        vim.tbl_extend("force", base_opts, { desc = "Jukit: Close history" })
      )
      km(
        "n",
        "<leader>jha",
        ":call jukit#splits#toggle_auto_hist()<CR>",
        vim.tbl_extend("force", base_opts, { desc = "Jukit: Toggle auto-history" })
      )

      -- Output & Both splits
      km("n", "<leader>jo", "", vim.tbl_extend("force", base_opts, { desc = "Output" }))
      km(
        "n",
        "<leader>jos",
        ":call jukit#splits#output()<CR>",
        vim.tbl_extend("force", base_opts, { desc = "Jukit: Open output" })
      )
      km(
        "n",
        "<leader>johs",
        ":call jukit#splits#output_and_history()<CR>",
        vim.tbl_extend("force", base_opts, { desc = "Jukit: Open output+history" })
      )
      km(
        "n",
        "<leader>jod",
        ":call jukit#splits#close_output_split()<CR>",
        vim.tbl_extend("force", base_opts, { desc = "Jukit: Close output" })
      )
      km(
        "n",
        "<leader>johd",
        ":call jukit#splits#close_output_and_history(1)<CR>",
        vim.tbl_extend("force", base_opts, { desc = "Jukit: Close both" })
      )

      -- Run code: block, line, all, selection
      km(
        "n",
        "<leader>jb",
        ":call jukit#send#section()<CR>",
        vim.tbl_extend("force", base_opts, { desc = "Jukit: Run block" })
      )
      km(
        "n",
        "<leader>ja",
        ":call jukit#send#line()<CR>",
        vim.tbl_extend("force", base_opts, { desc = "Jukit: Run line" })
      )
      km(
        "n",
        "<leader>jA",
        ":call jukit#send#all()<CR>",
        vim.tbl_extend("force", base_opts, { desc = "Jukit: Run all" })
      )
      km(
        "v",
        "<leader>ja",
        ":call jukit#send#selection()<CR>",
        vim.tbl_extend("force", base_opts, { desc = "Jukit: Run selection" })
      )

      -- Create new cells
      km("n", "<leader>jc", "", vim.tbl_extend("force", base_opts, { desc = "Create" }))
      km(
        "n",
        "<leader>jcc",
        ":call jukit#cells#create_below(0)<CR>",
        vim.tbl_extend("force", base_opts, { desc = "Jukit: New code cell" })
      )
      km(
        "n",
        "<leader>jcC",
        ":call jukit#cells#create_above(0)<CR>",
        vim.tbl_extend("force", base_opts, { desc = "Jukit: New code cell above" })
      )
      km(
        "n",
        "<leader>jcm",
        ":call jukit#cells#create_below(1)<CR>",
        vim.tbl_extend("force", base_opts, { desc = "Jukit: New comment cell" })
      )
      km(
        "n",
        "<leader>jcM",
        ":call jukit#cells#create_above(1)<CR>",
        vim.tbl_extend("force", base_opts, { desc = "Jukit: New comment cell above" })
      )

      -- Layout
      km(
        "n",
        "<leader>jl",
        ":call jukit#layouts#set_layout()<CR>",
        vim.tbl_extend("force", base_opts, { desc = "Jukit: Apply layout" })
      )

      -- Convert: notebook <-> .py
      km("n", "<leader>jn", "", vim.tbl_extend("force", base_opts, { desc = "Convert" }))
      km(
        "n",
        "<leader>jnb",
        ":call jukit#convert#notebook_convert('jupyter-notebook')<CR>",
        vim.tbl_extend("force", base_opts, { desc = "Jukit: Convert to notebook" })
      )
      km(
        "n",
        "<leader>jnp",
        ":call jukit#convert#notebook_convert()<CR>",
        vim.tbl_extend("force", base_opts, { desc = "Jukit: Convert to Python script" })
      )
    end,
  },
}
