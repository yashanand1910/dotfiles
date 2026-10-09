--[[ misc.lua
-- Collection of all miscellaneous features
--]]

local utils = require("utils")

-- local NVIM_CONFIG_PATH = vim.opt.runtimepath:get()[1]

do
	vim.api.nvim_create_user_command("Notepad", utils.launch_notepad, { nargs = 0 })
end

-- Route vim.ui.open (gx, :Browse, oil, plugins) through scripts/open-url so
-- links open on the iPad when attached from Rootshell
do
	local ui_open = vim.ui.open
	vim.ui.open = function(path, opt)
		return ui_open(path, vim.tbl_extend("keep", opt or {}, { cmd = { "open-url" } }))
	end
end

do
	vim.api.nvim_create_user_command("Browse", function(opts)
		vim.ui.open(opts.args)
	end, { nargs = 1 })
end
