--[[ formatter.lua
-- Configuration for formatter
--]]

local formatter = require("conform")

formatter.setup({
	formatters_by_ft = {
		lua = { "stylua" },
		yaml = { "prettier" },
		json = { "prettier" },
		jsonc = { "prettier" },
		html = { "prettier" },
		javascript = { "prettier" },
		typescript = { "prettier" },
		typescriptreact = { "prettier" },
		python = { "blue", "isort" },
		c = { "clang_format" },
		cpp = { "clang_format" },
		cuda = { "clang_format" },
		tex = { "latexindent" },
		ocaml = { "ocamlformat" },
		go = { "gofumpt" },
		cmake = { "cmake_format" },
		zsh = { "beautysh", "shellcheck" },
		sh = { "beautysh", "shellcheck" },
		bash = { "beautysh", "shellcheck" },
		make = { "shellcheck" },
		markdown = { "prettier", "cbfmt" },
		css = { "prettier" },
		scss = { "prettier" },
		proto = { "buf" },
	},
})

vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
