local mason_ok, mason = pcall(require, "mason")
if not mason_ok then
  print "mason not okay"
	return
end

local mason_lspconfig_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
if not mason_lspconfig_ok then
  print "mason_lspconfig not okay"
	return
end

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
        library = vim.api.nvim_get_runtime_file('', true)
      }
    }
  }
})

mason.setup()
mason_lspconfig.setup()
require('user.lsp.handlers').setup()
