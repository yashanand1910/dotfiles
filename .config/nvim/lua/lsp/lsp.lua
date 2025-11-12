--[[ lsp.lua
-- Configuration for Neovim's built-in LSP
--]]
local config = vim.lsp.config
local status, mason_lspconfig = pcall(require, "mason-lspconfig")
if not status then
	return
end

--[[ set_diagnostics_config()
-- Initialize Vim diagnostics settings
--]]
---@diagnostic disable-next-line: unused-local, unused-function
local function set_diagnostics_config()
	vim.diagnostic.config({
		float = {
			border = "rounded",
			format = function(diagnostic)
				-- "ERROR (line n): message"
				return string.format(
					"%s (line %i): %s",
					vim.diagnostic.severity[diagnostic.severity],
					diagnostic.lnum,
					diagnostic.message
				)
			end,
		},
	})
end

-- List of LSP servers used later
-- Always check the memory usage of each language server. :LSpInfo to identify LSP server
-- and use "sudo lsof -p PID" to check for associated files
local server_list = {
	"bashls",
	"clangd",
	"lua_ls",
	"jsonls",
	"dockerls",
	"yamlls",
	"rust_analyzer",
}

-- nvim_cmp capabilities
local cmp_capability = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

-- Let Mason-lspconfig handle LSP setup
mason_lspconfig.setup({
	ensure_installed = server_list,
	automatic_enable = true,
})

config("clangd", {
	capabilities = cmp_capability,
	on_attach = on_attach,
	filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
})

config("lua_ls", {
	capabilities = cmp_capability,
	on_attach = on_attach,
	settings = {
		-- https://github.com/CppCXY/EmmyLuaCodeStyle/blob/master/lua.template.editorconfig
		Lua = {
			format = {
				enable = false,
			},
			diagnostics = {
				globals = { "vim", "on_attach" }, --> Make diagnostics tolerate vim.fun.stuff
			},
			workspace = {
				library = vim.api.nvim_get_runtime_file("lua", true), --> Expose some Neovim API
				checkThirdParty = false, --> Disable third party library check
			},
			telemetry = {
				enable = false,
			},
		},
	},
})

config("docker_compose_language_service", {
	capabilities = cmp_capability,
	on_attach = on_attach,
})

config("pylsp", {
	settings = {
		pylsp = {
			plugins = {
				mccabe = { enabled = false, threshold = 30 },
				pycodestyle = { maxLineLength = 100 },
			},
		},
	},
})

-- -- NOTE: Workaround for clangd encoding issue (see https://github.com/jose-elias-alvarez/null-ls.nvim/issues/428)
-- local capabilities = vim.lsp.protocol.make_client_capabilities()
-- config("clangd", { capabilities = capabilities })
