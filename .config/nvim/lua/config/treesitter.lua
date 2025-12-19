--[[ treesitter.lua
-- Configuration for the Neovim's built-in tree-sitter highlight
--]]
local treesitter = require("nvim-treesitter.configs")

---@diagnostic disable-next-line: missing-fields
treesitter.setup({
	ensure_installed = { "bash", "c", "lua", "markdown", "python", "go", "vim" },
	sync_install = false,
	auto_install = true,
	ignore_install = {},
	highlight = {
		enable = true,
		disable = function(_, buf)
			local max_filesize = 100 * 1024 -- 100 KB
			local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
			if ok and stats and stats.size > max_filesize then
				return true
			end
		end,
	},
})

-- Enable treesitter for Octo buffers
vim.treesitter.language.register("markdown", "octo")
