-- ##############################################################################
-- # Diffview: diff the working tree against the repo's default branch
-- ##############################################################################

-- Resolve the remote's default branch (e.g. origin/main or origin/master).
-- Falls back to common names if the remote HEAD isn't set, then to "main".
local function default_branch()
  -- Preferred: ask git what origin/HEAD points to
  local head = vim.fn.systemlist({
    "git",
    "symbolic-ref",
    "--short",
    "refs/remotes/origin/HEAD",
  })
  if vim.v.shell_error == 0 and head[1] and head[1] ~= "" then
    return head[1] -- already in "origin/<branch>" form
  end

  -- Fallback: probe the usual suspects for an existing remote branch
  for _, name in ipairs({ "main", "master", "develop", "trunk" }) do
    vim.fn.system({ "git", "rev-parse", "--verify", "--quiet", "origin/" .. name })
    if vim.v.shell_error == 0 then
      return "origin/" .. name
    end
  end

  return "origin/main"
end

-- Open a three-dot diff (merge-base) of HEAD against the default branch.
-- `current_file` limits the view to the buffer's file when true.
local function diff_default(current_file)
  local base = default_branch()
  local cmd = "DiffviewOpen " .. base .. "...HEAD"
  if current_file then
    cmd = cmd .. " -- " .. vim.fn.fnameescape(vim.fn.expand("%:p"))
  end
  vim.cmd(cmd)
end

return {
  "sindrets/diffview.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = {
    "DiffviewOpen",
    "DiffviewClose",
    "DiffviewToggleFiles",
    "DiffviewFileHistory",
  },
  keys = {
    {
      "<leader>gd",
      function()
        diff_default(true)
      end,
      desc = "Diff current file vs default branch",
    },
    {
      "<leader>gD",
      function()
        diff_default(false)
      end,
      desc = "Diff project vs default branch",
    },
    { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Close Diffview" },
  },
  opts = {},
}
