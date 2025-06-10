--[[ dap.lua
-- This file configures the DAP family of plugins
--]]

-- DAP UI opn/close automatically

local dap, dapui = require("dap"), require("dapui")

-- dap.listeners.after.event_initialized["dapui_config"] = function()
--   dapui.open()
-- end
dap.listeners.before.event_terminated["dapui_config"] = function()
	dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
	dapui.close()
end

-- Adapter configurations

local function load_launchjs()
	require("dap.ext.vscode").load_launchjs(".vscode/launch.json", {
		chrome = { "typescript", "javascript", "typescriptreact" },
		codelldb = { "c", "cpp", "rust" },
		cppdbg = { "c", "cpp" },
		ocamlearlybird = { "ocaml" },
		go = { "go" },
		debugpy = { "python" },
	})
end

pcall(load_launchjs) -- XXX: ignore errors for now

-- Load vscode launch.json configs

dap.adapters.debugpy = {
	type = "executable",
	command = "python3",
	args = { "-m", "debugpy.adapter" },
}
dap.adapters.python = dap.adapters.debugpy
-- Add some default configurations
local pyconfig = dap.configurations.python or {}
dap.configurations.python = pyconfig
table.insert(pyconfig, {
	type = "python",
	request = "launch",
	name = "Launch command",
	program = "${file}",
	args = function()
		local args_string = vim.fn.input("ARGS: ")
		return vim.split(args_string, " +")
	end,
	console = "integratedTerminal",
	justMyCode = false,
	-- pythonPath = debugpy_path .. "/venv/bin/python",
})

dap.adapters.go = {
	id = "go",
	type = "server",
	port = 38697,
	executable = {
		command = vim.fn.exepath("dlv"),
		args = { "dap", "-l", ":38697" },
	},
}

dap.adapters.chrome = {
	type = "executable",
	command = "node",
	args = {
		vim.fn.expand("$MASON/bin/chrome-debug-adapter") .. "/out/src/chromeDebug.js",
	},
}

-- INFO: see https://github.com/mfussenegger/nvim-dap/wiki/C-C---Rust-(via--codelldb)

dap.adapters.codelldb = {
	type = "server",
	port = "13000",
	executable = {
		command = vim.fn.expand("$MASON/bin/codelldb") .. "/extension/adapter/codelldb",
		args = { "--port", "13000" },
	},
	name = "codelldb",
}

dap.adapters.cppdbg = {
	id = "cppdbg",
	type = "executable",
	command = vim.fn.expand("$MASON/bin/cpptools") .. "/extension/debugAdapters/bin/OpenDebugAD7",
}
dap.adapters.rust = {
	id = "cppdbg",
	type = "executable",
	command = vim.fn.expand("$MASON/bin/cpptools"),
}

-- FIXME: ocaml debugger / doesn't work

-- -- dap.adapters.ocamlearlybird = {
-- -- 	type = "executable",
-- -- 	command = "node",
-- -- 	args = { vim.fn.expand("$HOME/work/ocamlearlybird/integrations/vscode/extension.js") },
-- -- }
