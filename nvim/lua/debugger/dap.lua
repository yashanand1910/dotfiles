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

local mason = require("mason-registry")

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

local delve = mason.get_package("delve")
local delve_path = delve.get_install_path(delve)
dap.adapters.go = {
	id = "go",
	type = "server",
	port = 38697,
	executable = {
		command = delve_path .. "/dlv",
		args = { "dap", "-l", ":38697" },
	},
}

local chrome_dbg_adapter = mason.get_package("chrome-debug-adapter")
local chrome_dbg_adapter_path = chrome_dbg_adapter.get_install_path(chrome_dbg_adapter)
dap.adapters.chrome = {
	type = "executable",
	command = "node",
	args = {
		chrome_dbg_adapter_path .. "/out/src/chromeDebug.js",
	},
}

-- INFO: see https://github.com/mfussenegger/nvim-dap/wiki/C-C---Rust-(via--codelldb)

local codelldb_adapter = mason.get_package("codelldb")
local codelldb_adapter_path = codelldb_adapter.get_install_path(codelldb_adapter)
dap.adapters.codelldb = {
	type = "server",
	port = "13000",
	executable = {
		command = codelldb_adapter_path .. "/extension/adapter/codelldb",
		args = { "--port", "13000" },
	},
	name = "codelldb",
}

local cpptools_adapter = mason.get_package("cpptools")
local cpptools_adapter_path = cpptools_adapter.get_install_path(cpptools_adapter)
dap.adapters.cppdbg = {
	id = "cppdbg",
	type = "executable",
	command = cpptools_adapter_path .. "/extension/debugAdapters/bin/OpenDebugAD7",
}

dap.adapters.rust = {
	id = "cppdbg",
	type = "executable",
	command = cpptools_adapter_path .. "/extension/debugAdapters/bin/OpenDebugAD7",
}

-- FIXME: ocaml debugger / doesn't work

-- -- dap.adapters.ocamlearlybird = {
-- -- 	type = "executable",
-- -- 	command = "node",
-- -- 	args = { vim.fn.expand("$HOME/work/ocamlearlybird/integrations/vscode/extension.js") },
-- -- }
