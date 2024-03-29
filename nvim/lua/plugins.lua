--[[ plugins.lua
-- This file does:
--   - Initialize the list of plug-ins to be installed
--   - Bootstrap Lazy plugin manager and install plug-ins
--   - Initialize plug-ins using each setup() function
--   - For some plug-ins, provide a small configuration work in `config`
--     This is limited to basic config, and extensive config for some plug-ins will be done elsewhere
--   - For some plug-ins, install external dependencies
--]]

-- Plug-in list
local plugins = {
	-- dependencies
	"nvim-lua/plenary.nvim", --> Lua function library for Neovim (used by Telescope)
	"nvim-tree/nvim-web-devicons", --> Icons for barbar, Telescope, and more

	-- UI
	"MunifTanjim/nui.nvim", --> A UI library many are dependent on
	"rcarriga/nvim-notify", --> Pretty notifications
	{
		"folke/noice.nvim", --> Replaces UI for messages, cmdline, and popupmenu
		event = "VeryLazy",
		dependencies = {
			-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
			"MunifTanjim/nui.nvim",
			-- OPTIONAL:
			--   `nvim-notify` is only needed, if you want to use the notification view.
			--   If not available, we use `mini` as the fallback
			"rcarriga/nvim-notify",
		},
	},
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		opts = {
			dim_inactive = true,
			-- transparent = true,
			on_highlights = function(hl, c)
				local prompt = "#2d3149"
				hl.TelescopeNormal = {
					bg = c.bg_dark,
					fg = c.fg_dark,
				}
				hl.TelescopeBorder = {
					bg = c.bg_dark,
					fg = c.bg_dark,
				}
				hl.TelescopePromptNormal = {
					bg = prompt,
				}
				hl.TelescopePromptBorder = {
					bg = prompt,
					fg = prompt,
				}
				hl.TelescopePromptTitle = {
					bg = prompt,
					fg = prompt,
				}
				hl.TelescopePreviewTitle = {
					bg = c.bg_dark,
					fg = c.bg_dark,
				}
				hl.TelescopeResultsTitle = {
					bg = c.bg_dark,
					fg = c.bg_dark,
				}
			end,
		},
	},
	"projekt0n/github-nvim-theme",
	"xiyaowong/transparent.nvim",

	-- Buffer & tabs scoping
	{
		"akinsho/bufferline.nvim",
		version = "*",
		dependencies = "nvim-tree/nvim-web-devicons",
		config = true,
	},
	{
		"tiagovla/scope.nvim",
		config = true,
	},

	-- File, search
	{ "nvim-treesitter/nvim-treesitter" }, --> Incremental highlighting
	{
		"nvim-telescope/telescope.nvim", --> Expandable fuzzy finer
		config = function()
			require("telescope").setup({
				defaults = {
					layout_strategy = "flex",
				},
			})
		end,
	},
	{ "nvim-telescope/telescope-file-browser.nvim" }, --> File browser extension for Telescope
	{
		"nvim-tree/nvim-tree.lua",
		requires = "nvim-tree/nvim-web-devicons",
		config = true,
	},
	{
		"stevearc/oil.nvim", --> Manage files like Vim buffer; currently testing!
		config = true,
	},

	-- Formatting & linting
	"mfussenegger/nvim-lint",
	"editorconfig/editorconfig-vim",

	-- Git
	{
		"lewis6991/gitsigns.nvim", --> Git information
		config = true,
	},
	"sindrets/diffview.nvim",
	"tpope/vim-fugitive",
	"tpope/vim-rhubarb", --> Enables :Gbrowse
	{
		"pwntester/octo.nvim", --> GitHub integration
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
			"nvim-tree/nvim-web-devicons",
		},
		config = true,
	},
	{
		"petertriho/cmp-git",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
	},
	{
		"ruifm/gitlinker.nvim",
		dependencies = "nvim-lua/plenary.nvim",
		config = true,
	},

	-- Terminal
	{
		"preservim/vimux",
		config = function()
			vim.g["VimuxHeight"] = "30"
			vim.g["VimuxOrientation"] = "h"
		end,
	},

	-- Convenience
	{
		"smjonas/inc-rename.nvim", --> Incremental rename
		config = true,
	},
	{
		"folke/which-key.nvim", --> Keybindings helper
		event = "VeryLazy",
		config = true,
	},
	{
		"windwp/nvim-autopairs", --> Autopair
		config = true,
	},
	"tpope/vim-surround",
	"tpope/vim-commentary", --> Commenting region
	{
		"norcalli/nvim-colorizer.lua", --> Color highlighter
		config = function()
			require("colorizer").setup()
		end,
	},
	{
		"folke/todo-comments.nvim", --> TODO comments highlighting
		dependencies = "nvim-lua/plenary.nvim",
		config = true,
	},
	{
		"jackMort/ChatGPT.nvim",
		event = "VeryLazy",
		config = function()
			require("chatgpt").setup()
		end,
		dependencies = {
			"MunifTanjim/nui.nvim",
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
		},
	},

	-- LSP
	{
		"stevearc/conform.nvim",
		opts = {},
	},
	{ "neovim/nvim-lspconfig" }, --> Neovim default LSP engine
	{
		"williamboman/mason.nvim", --> LSP Manager
		config = true,
	},
	"williamboman/mason-lspconfig.nvim", --> Bridge between Mason and lspconfig
	{
		"L3MON4D3/LuaSnip", --> Snippet engine that accepts VS Code style snippets
		config = true, --> Load snippets from friendly snippets
	},
	"saadparwaiz1/cmp_luasnip", --> nvim_cmp and LuaSnip bridge
	"hrsh7th/cmp-nvim-lsp", --> nvim-cmp source for LSP engine
	"hrsh7th/cmp-buffer", --> nvim-cmp source for buffer words
	"hrsh7th/cmp-path", --> nvim-cmp source for file path
	"hrsh7th/cmp-cmdline", --> nvim-cmp source for :commands
	"hrsh7th/cmp-nvim-lua", --> nvim-cmp source for Neovim API
	"hrsh7th/nvim-cmp", --> Completion Engine
	"github/copilot.vim", --> GitHub Copilot
	{
		"nvimdev/lspsaga.nvim", --> LSP improvements (mainly breadcrumb)
		config = function()
			require("lspsaga").setup({})
		end,
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
	},

	-- Debugging
	"mfussenegger/nvim-dap",
	{
		"rcarriga/nvim-dap-ui",
		dependencies = { "mfussenegger/nvim-dap" },
		config = true,
	},
	"nvim-telescope/telescope-dap.nvim",
	{
		"theHamsta/nvim-dap-virtual-text",
		config = true,
	},

	-- Testing
	{
		"vim-test/vim-test",
		config = function()
			vim.g["test#strategy"] = "vimux"
			-- vim.g["test#neovim#term_position"] = "right 25"
			-- vim.g["test#preserve_screen"] = 0
			-- NOTE: Workaround if jest autodetection fails
			vim.g["test#javascript#jest#executable"] = "yarn test"
			vim.g["test#javascript#runner"] = "jest"
		end,
	},

	-- Text editing
	{
		"iamcco/markdown-preview.nvim", --> MarkdownPreview to toggle
		build = function()
			vim.fn["mkdp#util#install"]()
		end, --> Binary installation for markdown-preview
		ft = { "markdown" },
	},
	{
		"lervag/vimtex", --> LaTeX integration
		config = function()
			vim.g.tex_flavor = "latex"
			vim.g.vimtex_compiler_method = "latexmk"
			vim.g.vimtex_view_method = "skim"
			vim.g.vimtex_view_skim_sync = 1
			vim.g.vimtex_view_skim_activate = 1
		end,
		ft = { "plaintex", "tex" },
	},

	-- Misc
	{
		"Dhanus3133/LeetBuddy.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
		},
		config = function()
			require("leetbuddy").setup({
				language = "cpp",
			})
		end,
	},
	{
		"folke/neodev.nvim", --> For configuring lua_ls for nvim config files
		opts = {},
		config = function()
			require("neodev").setup({
				library = { plugins = { "nvim-dap-ui" }, types = true },
			})
		end,
	},
}

--- {{{ Lazy.nvim installation
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup(plugins)
--- }}}
