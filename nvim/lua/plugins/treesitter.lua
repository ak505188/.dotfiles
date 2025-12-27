-- Copied from https://github.com/mbwilding/nvim/blob/main/lua/plugins/treesitter.lua
-- Mostly iffy on the filetypes detection method
return {
  'nvim-treesitter/nvim-treesitter',
  lazy = false,
  branch = 'main',
  build = ':TSUpdate',
  config = function()
    -- Collect all available parsers
    local queries_dir = vim.fn.stdpath('data') .. '/lazy/nvim-treesitter/runtime/queries'
    local file_types = {}
    for name, type in vim.fs.dir(queries_dir) do
      if type == 'directory' then
        table.insert(file_types, name)
      end
    end

    local TS = require('nvim-treesitter')

    -- Install file type parsers
    TS.install(file_types)

    -- Automatically activate
    vim.api.nvim_create_autocmd('FileType', {
      pattern = file_types,
      callback = function()
        -- Highlights
        vim.treesitter.start()
        -- Folds
        vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
        vim.wo[0][0].foldmethod = 'expr'
        -- Indentation
        vim.bo.indentexpr = 'v:lua.require"nvim-treesitter".indentexpr()'
      end,
    })
  end,
}
