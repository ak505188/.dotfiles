return {
  "hrsh7th/nvim-cmp",
  -- load cmp on InsertEnter
  event = "InsertEnter",
  -- these dependencies will only be loaded when cmp loads
  -- dependencies are always lazy-loaded unless specified otherwise
  dependencies = {
    "hrsh7th/cmp-nvim-lsp", -- nvim-cmp source for neovim's built-in language server client.
    "hrsh7th/cmp-buffer", -- buffer completions
    "hrsh7th/cmp-cmdline", -- cmdline completions
    "hrsh7th/cmp-nvim-lsp", -- nvim-cmp source for neovim's built-in language server client.
    "saadparwaiz1/cmp_luasnip", -- snippet completions
    "L3MON4D3/LuaSnip", --snippet engine
    "rafamadriz/friendly-snippets", -- a bunch of snippets to use
  },
  config = function()
    -- ...
  end,
}
