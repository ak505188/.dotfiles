-- Remove whitespace on file save if not markdown
-- https://vi.stackexchange.com/a/456
vim.api.nvim_command([[
  fun! StripTrailingWhiteSpace()
    " don't strip on these filetypes
    if &ft =~ 'markdown'
      return
    endif
    let l:save = winsaveview()
    :keeppatterns %s/\s\+$//e
    call winrestview(l:save)
  endfun
  autocmd bufwritepre * call StripTrailingWhiteSpace()
]])

-- Set .mdx to markdown filetype
vim.cmd([[
  autocmd BufNewFile,BufReadPost *.mdx set filetype=markdown.mdx
]])

-- Set .jsx to jsx filetype
-- vim.cmd([[
--   autocmd BufNewFile,BufReadPost *.jsx set filetype=jsx
-- ]])
-- treesitter doesnt want to start on jsx files because filetype is read a javascriptreact
-- This manually starts on jsx files
vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufReadPost' }, {
  pattern = { '*.jsx' },
  callback = function()
    vim.treesitter.start()
  end
})
