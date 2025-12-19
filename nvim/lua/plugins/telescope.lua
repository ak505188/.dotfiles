return {
  'nvim-telescope/telescope.nvim', tag = 'v0.2.0',
  dependencies = {
    'nvim-lua/plenary.nvim',
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make'
    }
  },
  keys = {
    { '<C-p>', '<cmd>Telescope find_files<cr>', desc = 'Telescope find files' },
    { '<leader>g', '<cmd>Telescope live_grep<cr>', desc = 'Telescope live grep' },
    { '<leader>b', '<cmd>Telescope buffers<cr>', desc = 'Telescope buffers' },
  }
}
