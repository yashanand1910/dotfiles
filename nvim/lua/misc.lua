--[[ misc.lua
-- Collection of all miscellaneous features
--]]

local utils = require("utils")

-- local NVIM_CONFIG_PATH = vim.opt.runtimepath:get()[1]

do
  vim.api.nvim_create_user_command("Notepad", utils.launch_notepad, { nargs = 0 })
end
