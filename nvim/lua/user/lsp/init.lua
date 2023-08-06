local lspconfig_ok, lspconfig = pcall(require, "lspconfig")
if not lspconfig_ok then
  print "lspconfig not okay"
	return
end

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

mason.setup()
mason_lspconfig.setup()
mason_lspconfig.setup_handlers({
  function (server_name) -- default handler (optional)
    lspconfig[server_name].setup({})
  end,
})

require("user.lsp.handlers").setup()
