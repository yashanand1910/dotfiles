--[[ plugins.lua
-- This file does:
--   - Initialize the list of plug-ins to be installed
--   - Bootstrap Lazy plugin manager and install plug-inskey
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
	-- ANSI colorizer for text (used for DAP console filetype)
	{
		"m00qek/baleia.nvim",
		version = "*",
		config = function()
			vim.g.baleia = require("baleia").setup({})

			-- Command to colorize the current buffer
			vim.api.nvim_create_user_command("BaleiaColorize", function()
				vim.g.baleia.once(vim.api.nvim_get_current_buf())
			end, { bang = true })

			-- Command to show logs
			vim.api.nvim_create_user_command("BaleiaLogs", vim.g.baleia.logger.show, { bang = true })
		end,
	},

	-- Buffer & tabs scoping
	{
		"akinsho/bufferline.nvim",
		version = "*",
		dependencies = "nvim-tree/nvim-web-devicons",
		opts = {
			options = {
				themable = true,
				show_buffer_close_icons = false,
				show_close_icon = false,
				diagnostics = "nvim_lsp",
				update_in_insert = true,
				always_show_bufferline = true,
			},
		},
	},
	{
		"tiagovla/scope.nvim",
		config = true,
	},
	{
		"christoomey/vim-tmux-navigator", --> Navigate between Vim and Tmux panes
		enabled = false,
		cmd = {
			"TmuxNavigateLeft",
			"TmuxNavigateDown",
			"TmuxNavigateUp",
			"TmuxNavigateRight",
			"TmuxNavigatePrevious",
		},
		keys = {
			{ "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
			{ "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
			{ "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
			{ "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
			{ "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
		},
	},

	-- File, search
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		build = ":TSUpdate",
	}, --> Incremental highlighting
	{
		"nvim-telescope/telescope.nvim", --> Expandable fuzzy finer
		opts = {
			defaults = {
				layout_strategy = "flex",
			},
		},
		config = true,
	},
	{ "nvim-telescope/telescope-file-browser.nvim" }, --> File browser extension for Telescope
	{
		"nvim-tree/nvim-tree.lua",
		dependencies = "nvim-tree/nvim-web-devicons",
		config = true,
	},
	{
		"stevearc/oil.nvim", --> Manage files like Vim buffer; currently testing!
		opts = {},
		dependencies = { "nvim-tree/nvim-web-devicons" },
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
		version = "34e67cc2d247e9b9271e2b54baeb6d4f6d1035bb", -- TODO: revert when main is fixed (by those morons)
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
			"nvim-tree/nvim-web-devicons",
		},
		opts = {
			suppress_missing_scope = {
				projects_v2 = true,
			},
			picker_config = {
				mappings = {
					copy_sha = { lhs = "<leader>oU", desc = "copy commit SHA to system clipboard" },
					copy_url = { lhs = "<leader>ou", desc = "copy url to system clipboard" },
				},
			},
			mappings = {
				pull_request = {
					copy_sha = { lhs = "<leader>oU", desc = "copy commit SHA to system clipboard" },
					copy_url = { lhs = "<leader>ou", desc = "copy url to system clipboard" },
					checkout_pr = { lhs = "<leader>opp", desc = "checkout PR" },
					add_reviewer = { lhs = "<leader>va", desc = "add reviewer" },
					remove_reviewer = { lhs = "<leader>vd", desc = "remove reviewer request" },
					review_start = { lhs = "<leader>vs", desc = "start a review for the current PR" },
					review_resume = { lhs = "<leader>vr", desc = "resume a pending review for the current PR" },
				},
				review_thread = {
					copy_sha = { lhs = "<leader>oU", desc = "copy commit SHA to system clipboard" },
					copy_url = { lhs = "<leader>ou", desc = "copy url to system clipboard" },
					close_review_tab = { lhs = "<leader>q", desc = "Close review tab" },
				},
				review_diff = {
					copy_sha = { lhs = "<leader>oU", desc = "copy commit SHA to system clipboard" },
					copy_url = { lhs = "<leader>ou", desc = "copy url to system clipboard" },
					close_review_tab = { lhs = "<leader>q", desc = "Close review tab" },
					submit_review = { lhs = "<leader>vs", desc = "submit review" },
					discard_review = { lhs = "<leader>vd", desc = "discard review" },
					add_comment = { lhs = "<leader>ca", desc = "add comment" },
					add_reply = { lhs = "<leader>cr", desc = "add reply" },
					add_suggestion = { lhs = "<leader>sa", desc = "add suggestion" },
					delete_comment = { lhs = "<leader>cd", desc = "delete comment" },
				},
				file_panel = {
					close_review_tab = { lhs = "<leader>q", desc = "Close review tab" },
				},
			},
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
	-- {
	-- 	"iamcco/markdown-preview.nvim",
	-- 	cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
	-- 	ft = { "markdown" },
	-- 	build = function()
	-- 		vim.fn["mkdp#util#install"]()
	-- 	end,
	-- },
	{
		-- Make sure to set this up properly if you have lazy=true
		"MeanderingProgrammer/render-markdown.nvim",
		opts = {
			file_types = { "markdown", "Avante", "octo" },
		},
		ft = { "markdown", "Avante", "octo" },
	},

	{
		"smjonas/inc-rename.nvim", --> Incremental rename
		config = true,
	},
	{
		"folke/which-key.nvim", --> Keybindings helper
		dependencies = "echasnovski/mini.nvim",
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
		config = true,
	},
	{
		"folke/todo-comments.nvim", --> TODO comments highlighting
		dependencies = "nvim-lua/plenary.nvim",
		config = true,
		opts = {
			keywords = {
				FIX = {
					icon = " ", -- icon used for the sign, and in search results
					color = "error", -- can be a hex color, or a named color (see below)
					alt = { "FIXME", "BUG", "FIXIT", "ISSUE" }, -- a set of other keywords that all map to this FIX keywords
					-- signs = false, -- configure signs for some keywords individually
				},
				TODO = { icon = " ", color = "info" },
				HACK = { icon = " ", color = "warning" },
				WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
				PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
				NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
				TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
			},

			highlight = {
				pattern = [[.*<(KEYWORDS)\s*]],
			},
			search = {
				pattern = [[\b(KEYWORDS)]],
			},
		},
	},
	{
		"Kurama622/llm.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim" },
		cmd = { "LLMSessionToggle", "LLMSelectedTextHandler", "LLMAppHandler" },
		config = true,
	},
	{
		"yetone/avante.nvim",
		build = "make",
		event = "VeryLazy",
		version = "v0.0.29", -- Never set this value to "*"! Never!
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			--- The below dependencies are optional,
			"echasnovski/mini.pick", -- for file_selector provider mini.pick
			"nvim-telescope/telescope.nvim", -- for file_selector provider telescope
			"hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
			"ibhagwan/fzf-lua", -- for file_selector provider fzf
			"stevearc/dressing.nvim", -- for input provider dressing
			"folke/snacks.nvim", -- for input provider snacks
			"nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
			-- "zbirenbaum/copilot.lua", -- for providers='copilot'
			{
				-- support for image pasting
				"HakonHarnes/img-clip.nvim",
				event = "VeryLazy",
				opts = {
					-- recommended settings
					default = {
						embed_image_as_base64 = false,
						prompt_for_file_name = false,
						drag_and_drop = {
							insert_mode = true,
						},
					},
				},
			},
		},
	},

	-- LSP
	{
		"j-hui/fidget.nvim",
		config = true,
	},
	"stevearc/conform.nvim",
	"neovim/nvim-lspconfig", --> Neovim default LSP engine
	{
		"williamboman/mason.nvim", --> LSP Manager
		config = true,
	},
	{
		"williamboman/mason-lspconfig.nvim",
	}, --> Bridge between Mason and lspconfig
	{
		"L3MON4D3/LuaSnip", --> Snippet engine that accepts VS Code style snippets
		build = "make install_jsregexp",
		config = true, --> Load snippets from friendly snippets
	},
	"saadparwaiz1/cmp_luasnip", --> nvim_cmp and LuaSnip bridge
	"hrsh7th/cmp-nvim-lsp", --> nvim-cmp source for LSP engine
	"hrsh7th/cmp-buffer", --> nvim-cmp source for buffer words
	"hrsh7th/cmp-path", --> nvim-cmp source for file path
	"hrsh7th/cmp-cmdline", --> nvim-cmp source for :commands
	"hrsh7th/cmp-nvim-lua", --> nvim-cmp source for Neovim API
	"hrsh7th/nvim-cmp", --> Completion Engine
	"SergioRibera/cmp-dotenv",
	"petertriho/cmp-git",
	"github/copilot.vim", --> GitHub Copilot

	-- Debugging

	"mfussenegger/nvim-dap",
	{
		"rcarriga/nvim-dap-ui",
		dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
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
		opts = {
			language = "cpp",
		},
		config = true,
	},
	{
		"folke/neodev.nvim", --> For configuring lua_ls for nvim config files
		opts = {
			library = { plugins = { "nvim-dap-ui" }, types = true },
		},
		config = true,
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
