-- Noice config for messages, cmdline, and popupmenu

require("noice").setup({
	lsp = {
		progress = {
			enabled = false,
		},
		signature = {
			enabled = false,
		},
		-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
		override = {
			["vim.lsp.util.convert_input_to_markdown_lines"] = true,
			["vim.lsp.util.stylize_markdown"] = true,
			["cmp.entry.get_documentation"] = true,
		},
		throttle = 1000 / 5,
	},
	-- you can enable a preset for easier configuration
	presets = {
		bottom_search = false, -- use a classic bottom cmdline for search
		command_palette = false, -- position the cmdline and popupmenu together
		long_message_to_split = false, -- long messages will be sent to a split
		inc_rename = false, -- enables an input dialog for inc-rename.nvim
		lsp_doc_border = false, -- add a border to hover docs and signature help
	},
	cmdline = {
		view = "cmdline",
	},
	messages = {
		enabled = true,
	},
	popupmenu = {
		enabled = true,
	},
	routes = {
		{
			-- XXX: filter write messages (see https://github.com/folke/noice.nvim/issues/568)
			filter = {
				event = "msg_show",
				any = {
					{ find = "%d+L, %d+B" },
					{ find = "; after #%d+" },
					{ find = "; before #%d+" },
					{ find = "%d fewer lines" },
					{ find = "%d more lines" },
				},
			},
			opts = { skip = true },
		},
	},
})
