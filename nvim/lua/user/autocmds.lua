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
