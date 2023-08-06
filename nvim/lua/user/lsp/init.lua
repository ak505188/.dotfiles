local lspconfig_ok, _ = pcall(require, "lspconfig")
if not lspconfig_ok then
	return
end

local mason_ok, mason = pcall(require, "mason")
if not mason_ok then
	return
end

local mason_lspconfig_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
if not mason_lspconfig_ok then
	return
end

mason.setup()
mason_lspconfig.setup()

require("user.lsp.handlers").setup()
