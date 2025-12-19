vim.lsp.config['shopify_theme_ls'] = {
  -- Filetypes to automatically attach to.
  filetypes = { 'liquid' },
  root_dir = vim.fn.getcwd(),
  root_markers = { 'slate.config.js' },
  name = 'shopify_theme_ls'
}

vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      workspace = {
        library = {
          "$VIMRUNTIME",
          "${3rd}/luv/library"
        }
      }
    }
  }
})

require('user.lsp.handlers').setup()
