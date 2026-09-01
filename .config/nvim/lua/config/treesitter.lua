--[[ treesitter.lua
-- Configuration for the Neovim's built-in tree-sitter highlight
--]]
require("nvim-treesitter").install({
	"bash",
	"python",
	"go",
	"c",
	"cpp",
	"rust",
	"markdown",
	"markdown_inline",
	"regex",
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "sh", "bash", "python", "go", "c", "cpp", "rust", "markdown", "octo", "Avante", "AvanteInput" },
	callback = function(ev)
		local max_filesize = 100 * 1024
		local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(ev.buf))
		if ok and stats and stats.size > max_filesize then
			return
		end
		vim.treesitter.start(ev.buf)
	end,
})

vim.treesitter.language.register("markdown", { "octo", "Avante", "AvanteInput", "gitcommit" })
