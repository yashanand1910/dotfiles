--[[ init.lua ]]

-- Try catch for modules
local function safe_require(module)
	local status, loaded_module = pcall(require, module)
	if status then
		return loaded_module
	end
	vim.notify("Error loading the module: " .. module, vim.log.levels.ERROR)
	vim.notify(loaded_module)
	return nil
end

-- Core config modules
safe_require("core")
safe_require("plugins")

-- UI elements
local highlights = safe_require("ui.highlights")
if highlights then
	highlights.setup()
end
local statusline = safe_require("ui.statusline")
if statusline then
	statusline.setup()
end
safe_require("ui.notifications")

-- LSP configurations
safe_require("lsp.lsp")
safe_require("lsp.completion")
safe_require("lsp.formatter")

-- Plugin configurations
safe_require("config.treesitter")
safe_require("config.oil")
safe_require("config.llm")
safe_require("config.avante")

-- Miscellaneous configurations
safe_require("misc")

-- Keybindings
safe_require("keybinds")

-- Theme config modules
safe_require("theme")

-- Debugger configurations
safe_require("debugger.dap")
