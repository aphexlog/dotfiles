return {
  "hrsh7th/nvim-cmp",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp", -- LSP suggestions
    "L3MON4D3/LuaSnip", -- Snippet engine
    "saadparwaiz1/cmp_luasnip", -- Snippet adapter
  },
  enabled = true,
  opts = function(_, opts)
    local cmp = require("cmp")

    -- Ensure opts is a table
    opts = opts or {}

    -- Fix `autocomplete` issue
    opts.completion = {
      autocomplete = {
        require("cmp.types").cmp.TriggerEvent.InsertEnter,
        require("cmp.types").cmp.TriggerEvent.TextChanged,
      },
    }

    -- Ensure opts.mapping is a table before extending
    opts.mapping = vim.tbl_deep_extend("force", opts.mapping or {}, {
      ["<C-Space>"] = cmp.mapping.complete(), -- Trigger completion menu
      ["<C-y>"] = cmp.mapping.confirm({ select = true }), -- Confirm selection
      ["<CR>"] = cmp.mapping.confirm({ select = false }), -- Only confirm explicitly selected item
      ["<Tab>"] = cmp.mapping.select_next_item(), -- Move down in the menu
      ["<S-Tab>"] = cmp.mapping.select_prev_item(), -- Move up in the menu
      ["<C-j>"] = cmp.mapping.select_next_item(), -- Alternative: Move down
      ["<C-k>"] = cmp.mapping.select_prev_item(), -- Alternative: Move up
    })

    -- Set up sorting priorities
    opts.sorting = {
      priority_weight = 100,
      comparators = {
        cmp.config.compare.offset,
        cmp.config.compare.exact,
        cmp.config.compare.score,
        cmp.config.compare.kind,
        cmp.config.compare.sort_text,
        cmp.config.compare.length,
        cmp.config.compare.order,
      },
    }

    -- Define completion sources
    opts.sources = cmp.config.sources({
      { name = "nvim_lsp" },
      { name = "luasnip" },
      { name = "buffer" },
      { name = "path" },
    })

    return opts
  end,
}
