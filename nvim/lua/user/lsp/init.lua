vim.lsp.config('shopify_theme_ls', {
  cmd = {
    'shopify',
    'theme',
    'language-server',
  },
  filetypes = { 'liquid' },
  root_markers = {
    '.shopifyignore',
    '.theme-check.yml',
    '.theme-check.yaml',
    'shopify.theme.toml',
    'vite.config.js',
    'slate.config.js'
  },
  settings = {},
})

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

require('user.lsp.handlers')
