--[[theme.lua
-- Theme configuration, such as colorscheme etc.
--]]

local icons = require("icons")

-- Transparency

vim.g.transparent_enabled = true

-- Colorscheme --

vim.cmd([[
try
  colorscheme tokyonight-moon
catch
  colorscheme default
endtry
]])

-- Brighten line numbers for Tokyonight

if (vim.g.colors_name or ""):match("^tokyonight") then
	local colors = require("tokyonight.colors").setup()
	-- Set bright colors for Comments
	vim.api.nvim_set_hl(0, "Comment", { fg = colors.dark5, italic = true })
end

-- Notify config

---@diagnostic disable-next-line: missing-fields
require("notify").setup({
	-- Animation style
	stages = "static",
	-- Render style for notifications
	render = "compact",
})

-- DAP coloring/icons

-- vim.highlight.create("DapBreakpoint", { ctermbg = 0, guifg = "#993939", guibg = "#31353f" }, false)
-- vim.highlight.create("DapLogPoint", { ctermbg = 0, guifg = "#61afef", guibg = "#31353f" }, false)
-- vim.highlight.create("DapStopped", { ctermbg = 0, guifg = "#98c379", guibg = "#31353f" }, false)

vim.fn.sign_define("DapBreakpoint", {
	text = icons.diagnostics.Debug,
	texthl = "DiagnosticSignError",
	linehl = "DiagnosticSignError",
	numhl = "DiagnosticSignError",
})
vim.fn.sign_define("DapBreakpointCondition", {
	text = icons.diagnostics.Question,
	texthl = "DiagnosticSignError",
	linehl = "DiagnosticSignError",
	numhl = "DiagnosticSignError",
})
vim.fn.sign_define(
	"DapBreakpointRejected",
	{ text = icons.diagnostics.Error, texthl = "DiagnosticSignError", linehl = "", numhl = "DiagnosticSignError" }
)
vim.fn.sign_define(
	"DapLogPoint",
	{ text = icons.diagnostics.Trace, texthl = "DiagnosticSignWarn", linehl = "", numhl = "DiagnosticSignWarn" }
)
vim.fn.sign_define("DapStopped", {
	text = icons.ui.Triangle,
	texthl = "DiagnosticSignWarn",
	linehl = "DiagnosticSignWarn",
	numhl = "DiagnosticSignWarn",
})
