return {
  "kyazdani42/nvim-tree.lua",
  dependencies = {
    'nvim-tree/nvim-web-devicons',
    lazy = true
  },
  keys = {
    { '<Leader>f', '<cmd>NvimTreeToggle<cr>', desc = "Toggle File Tree" }
  }
}
