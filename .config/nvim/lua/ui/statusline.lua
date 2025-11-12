--[[ statusline.lua
-- Provide functions to build a Lua table and Luaeval string used for setting up Vim statusline
--
-- @requires ui.components for Statusline/Winbar components
--]]
local components = require("ui.components")

Statusline = {} --> global so that luaeval can keep calling build() function

--[[ build()
-- Build a table with statusline components
-- @return Lua table of Vim statusline components
--]]
---@diagnostic disable-next-line: duplicate-set-field
Statusline.build = function()
	return table.concat({
		-- Mode
		components.update_mode_colors(), --> Dynamically set the highlight depending on the current mode
		components.format_mode(),

		-- folder, file name, and status
		-- "%#PastelculaOrangeAccent# ",
		-- " ",
		-- vim.fn.fnamemodify(vim.fn.getcwd(), ":t"), --> current working directory

		-- File info
		-- "  ",
		-- "%f", --> Current file/path relative to the current folder
		-- "%m", --> [-] for read only, [+] for modified buffer
		-- "%r", --> [RO] for read only, I know it's redundant
		-- "%<", --> Truncation starts here (and to the left) if file is too long

		-- Git
		" %#PastelculaGreyAccent#",
		components.git_status(),

		-- Virutal env
		components.virtual_env(),

		-- Spacer
		"%#Normal#",
		"%=",

		-- LSP status
		components.lsp_status(),

		-- Spellcheck status
		"%#PastelculaLightGreyAccent#",
		components.spellcheck_status(),

		-- Linter status
		components.linter_status(),

		-- LSP server
		components.lsp_server(),

		-- Formatter
		components.formatter(),

		-- File information
		"%#PastelculaGreyAccent#",
		"   %Y ", --> Same as vim.bo.filetype:upper()

		components.ff_and_enc(),
		-- Location in the file
		"  %l:%c %P ", --> Line, column, and page percentage
	})
end

--[[ setup()
-- Set vim.o.statusline to luaeval of the build function
--]]
---@diagnostic disable-next-line: duplicate-set-field
Statusline.setup = function()
	vim.opt.statusline = "%{%v:lua.Statusline.build()%}"
end

return Statusline
