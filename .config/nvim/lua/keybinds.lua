--[[ keybinds.lua
-- All the keybindings, including whichkey bindings are defined here.
--]]

local keymap = vim.keymap
local telescope = require("telescope")
local builtin = require("telescope.builtin")
-- Telescope layout modes
local get_cursor = require("telescope.themes").get_cursor({})
-- Load telescope extensions
telescope.load_extension("file_browser")
telescope.load_extension("dap")

-- TODO: Reorganize for which-key (https://github.com/folke/which-key.nvim)

-- Leader --
keymap.set({ "n", "v" }, "<Space>", "<Nop>", { noremap = true }) --> Unbind space
vim.g.mapleader = " " --> Space as the leader key

--[[ url_handler()
-- Find the URL in the current line and open it in a browser if possible
--]]
local function url_handler()
	-- <something>://<something that aren't >,;)>
	local url = string.match(vim.fn.getline("."), "[a-z]*://[^ >,;)]*")
	if url ~= nil then
		vim.cmd("silent exec '!xdg-open " .. url .. "'")
	else
		vim.notify("No URI found in the current line")
	end
end

-- {{{ Keybinding table
local key_opt = {
	-- Convenience --
	{ "n", "gx", url_handler, "Open URL under the cursor" },
	{ "n", "\\d", '"_d', "Delete without yanking" },
	{ "v", "\\d", '"_d', "Delete without yanking" },
	{ "n", "<A-j>", ":m .+1<CR>==", "Move current line down" },
	{ "n", "<A-k>", ":m .-2<CR>==", "Move current line up" },
	{ "i", "<A-j>", "<Esc>:m .+1<CR>==gi", "Move current line down" },
	{ "i", "<A-k>", "<Esc>:m .-2<CR>==gi", "Move current line up" },
	{ "v", "<A-j>", ":m '>+1<CR>gv-gv", "Move current block down" },
	{ "v", "<A-k>", ":m '<-2<CR>gv-gv", "Move current block up" },
	{ "n", "<leader>r", ":IncRename ", "Replace word under cursor" },
	{
		"n",
		"<leader>R",
		":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>",
		"Replace word under cursor",
	},
	{ "n", "<C-d>", "<C-d>zz", "Scroll down half page and recenter" },
	{ "n", "<C-u>", "<C-u>zz", "Scroll up half page and recenter" },
	{ "i", "<C-e>", "<C-o>A", "Jump to end of line" },
	{ "i", "<C-a>", "<C-o>I", "Jump to start of line" },
	{ "i", "<C-c>", "<Esc>", "Exit insert mode" },

	-- Notepad --
	{ "n", "<leader>N", ":Notepad<CR>", "Open notepad" },

	-- Search & navigation --
	{ "n", "<leader>h", ":noh<CR>", "Clear search highlights" },
	{
		"n",
		"<leader>sp",
		function()
			builtin.registers()
		end,
		"Search registers",
	},
	{
		"n",
		"<leader>sk",
		function()
			builtin.keymaps()
		end,
		"Search keymaps",
	},
	{
		"n",
		"<leader>f",
		-- git_files() will fail in non-git repositories
		function()
			local status, _ = pcall(builtin.git_files, { show_untracked = true })
			if not status then
				builtin.find_files({ no_ignore = true, hidden = true })
			end
		end,
		"Search git files",
	},
	{
		"n",
		"<leader>sf",
		function()
			builtin.find_files({ no_ignore = true, hidden = true })
		end,
		"Search files",
	},
	{
		"n",
		"<leader>sg",
		function()
			builtin.live_grep()
		end,
		"Live grep",
	},
	{
		"n",
		"<leader>ss",
		function()
			builtin.builtin()
		end,
		"Search builtin options",
	},
	{
		"n",
		"<leader>se",
		function()
			telescope.extensions.file_browser.file_browser()
		end,
		"Browse files",
	},
	{
		"n",
		"<leader>sh",
		function()
			builtin.help_tags()
		end,
		"Search help",
	},
	{
		"n",
		"<leader>sl",
		function()
			builtin.resume()
		end,
		"Last search result",
	},
	{
		"n",
		"<leader>sc",
		function()
			builtin.colorscheme()
		end,
		"Search colorschemes",
	},
	{
		"n",
		"<leader>e",
		function()
			require("oil").toggle_float()
		end,
		"File tree float toggle (oil)",
	},
	{ "n", "<leader>E", ":NvimTreeFindFileToggle<CR>", "File tree toggle" },

	-- Git --
	{ "n", "<leader>gDD", ":DiffviewOpen<CR>", "Git diff view open" },
	{ "n", "<leader>gDQ", ":DiffviewClose<CR>", "Git diff view close" },
	{ "n", "<leader>gDc", ":DiffviewFileHistory %<CR>", "Git diff view current file history" },
	{ "n", "<leader>gDC", ":DiffviewFileHistory<CR>", "Git diff view file history" },
	{ "n", "<leader>gs", ":G<CR>", "Git status" },
	{ "n", "<leader>gd", ":Gvdiffsplit<CR>", "Git diff current file" },
	{
		"n",
		"<leader>gc",
		function()
			builtin.git_commits()
		end,
		"Git commits",
	},
	{ "n", "<leader>ga", ":G add %<CR>", "Git add current file" },
	{ "n", "<leader>gA", ":G add .<CR>", "Git add all" },
	{
		"n",
		"<leader>gCC",
		":G commit -c HEAD<CR>",
		"Git commit (using last commit)",
	},
	{ "n", "<leader>gCN", ":G commit<CR>", "Git commit" },
	{ "n", "<leader>gCA", ":G commit<CR>", "Git commit --amend" },
	{ "n", "<leader>gp", ":G -c pull.default=current pull<CR>", "Git pull" },
	{ "n", "<leader>gP", ":G -c pull.default=current push<CR>", "Git push" },
	{ "n", "<leader>gl", ":Gclog<CR>", "Git log" },
	{ "n", "<leader>gb", ":G blame<CR>", "Git blame" },
	{ "n", "<leader>gB", ":GBrowse<CR>", "Git browse" },
	{
		"n",
		"<leader>gy",
		function()
			require("gitlinker").get_buf_range_url(
				"n",
				{ action_callback = require("gitlinker.actions").copy_to_clipboard }
			)
		end,
		"Git yank permalink",
	},
	{
		"v",
		"<leader>gy",
		function()
			require("gitlinker").get_buf_range_url(
				"v",
				{ action_callback = require("gitlinker.actions").copy_to_clipboard }
			)
		end,
		"Git yank permalink",
	},
	{
		"n",
		"<leader>gY",
		function()
			require("gitlinker").get_buf_range_url(
				"n",
				{ action_callback = require("gitlinker.actions").open_in_browser }
			)
		end,
		"Git yank permalink",
	},
	{
		"v",
		"<leader>gY",
		function()
			require("gitlinker").get_buf_range_url(
				"v",
				{ action_callback = require("gitlinker.actions").open_in_browser }
			)
		end,
		"Git yank permalink",
	},

	-- GitHub --
	{ "n", "<leader>oa", ":Octo actions<CR>", "GitHub search commands" },
	{ "n", "<leader>opl", ":Octo pr list<CR>", "GitHub PR list" },
	{ "n", "<leader>opa", ":Octo pr create<CR>", "GitHub PR create" },
	{ "n", "<leader>opp", ":Octo pr checkout<CR>", "GitHub PR checkout" },
	{ "n", "<leader>opM", ":Octo pr merge<CR>", "GitHub PR merge" },
	{ "n", "<leader>ors", ":Octo review start<CR>", "GitHub PR start review" },
	{ "n", "<leader>orx", ":Octo review close<CR>", "GitHub PR close review" },
	{ "n", "<leader>orS", ":Octo review submit<CR>", "GitHub PR submit review" },
	{ "n", "<leader>orr", ":Octo review resume<CR>", "GitHub PR resume review" },
	{ "n", "<leader>ord", ":Octo review discard<CR>", "GitHub PR discard review" },

	-- Testing --
	{ "n", "<leader>tt", ":TestNearest<CR>", "Test nearest" },
	{ "n", "<leader>tc", ":TestClass<CR>", "Test class" },
	{ "n", "<leader>tf", ":TestFile<CR>", "Test file" },
	{ "n", "<leader>ts", ":TestSuite<CR>", "Test suite" },
	{ "n", "<leader>tv", ":TestVisit<CR>", "Test visit" },

	-- Debugging --
	{
		"n",
		"<leader>ds",
		function()
			require("dap").continue()
		end,
		"Debugger start",
	},
	{
		"n",
		"<leader>du",
		function()
			require("dapui").toggle()
		end,
		"Debugger UI toggle",
	},
	{
		"n",
		"<leader>dK",
		function()
			require("dapui").eval()
		end,
		"Debugger evaluate expression",
	},
	{
		"n",
		"<leader>db",
		function()
			require("dap").toggle_breakpoint()
		end,
		"Debugger toggle breakpoint",
	},
	{
		"n",
		"<leader>dd",
		function()
			telescope.extensions.dap.commands()
		end,
		"Debugger search commands",
	},
	{
		"n",
		"<leader>dlv",
		function()
			telescope.extensions.dap.variables()
		end,
		"Debugger variables list",
	},
	{
		"n",
		"<leader>dlf",
		function()
			telescope.extensions.dap.frames()
		end,
		"Debugger frames list",
	},
	{
		"n",
		"<leader>dlb",
		function()
			require("dapui").float_element("breakpoints", {
				title = "Breakpoints",
				position = "center",
				enter = true,
				height = 40,
				width = 100,
			})
		end,
		"Debugger breakpoints",
	},
	{
		"n",
		"<leader>dls",
		function()
			require("dapui").float_element("scopes", {
				title = "Scopes",
				position = "center",
				enter = true,
				height = 40,
				width = 100,
			})
		end,
		"Debugger scopes",
	},
	{
		"n",
		"<leader>dlr",
		function()
			require("dapui").float_element("repl", {
				title = "REPL",
				position = "center",
				enter = true,
				height = 40,
				width = 100,
			})
		end,
		"Debugger console",
	},
	{
		"n",
		"<leader>dlc",
		function()
			require("dapui").float_element("console", {
				title = "Console",
				position = "center",
				enter = true,
				height = 40,
				width = 100,
			})
		end,
		"Debugger console",
	},
	{
		"n",
		"<leader>dc",
		function()
			require("dap").run_to_cursor()
		end,
		"Debugger continue till cursor",
	},
	{
		"n",
		"<leader>do",
		function()
			require("dap").step_over()
		end,
		"Debugger step over",
	},
	{
		"n",
		"<leader>di",
		function()
			require("dap").step_into()
		end,
		"Debugger step into",
	},
	{
		"n",
		"<leader>dO",
		function()
			require("dap").step_out()
		end,
		"Debugger step out",
	},
	{
		"n",
		"<leader>dB",
		function()
			require("dap").step_back()
		end,
		"Debugger step back",
	},
	{
		"n",
		"<leader>dp",
		function()
			require("dap").pause()
		end,
		"Debugger pause thread",
	},

	-- Comments --
	{ "n", "<leader>xl", ":TodoTelescope<CR>", "TODO comments list" },
	{
		"n",
		"<leader>xj",
		function()
			require("todo-comments").jump_next()
		end,
		"TODO jump to next",
	},
	{
		"n",
		"<leader>xk",
		function()
			require("todo-comments").jump_prev()
		end,
		"TODO jump to previous",
	},

	-- Spell check --
	{
		"i",
		"<C-s>",
		"<C-g>u<ESC>[s1z=`]a<C-g>u",
		"[s]pell: fix nearest spelling error and put the cursor back",
	},
	{
		"n",
		"<C-s>",
		function()
			builtin.spell_suggest(get_cursor)
		end,
		"[s]pell: toggle spell suggestion window for the word under the cursor",
	},
	{
		"n",
		"<leader>S",
		function()
			vim.cmd([[ setlocal spell! ]])
			vim.g.spellcheck_status = vim.api.nvim_get_option_value("spell", { scope = "local" })
		end,
		"[s]pell [t]oggle: turn spell check on/off for the current buffer",
	},

	-- Buffer --
	{ "n", "<C-Up>", ":resize -2<CR>", "Buffer resize up" },
	{ "n", "<C-Down>", ":resize +2<CR>", "Buffer resize down" },
	{ "n", "<C-Left>", ":vertical resize -2<CR>", "Buffer resize left" },
	{ "n", "<C-Right>", ":vertical resize +2<CR>", "Buffer resize right" },
	{ "n", "<C-w>x", ":split<CR>", "Split current buffer horizontally" },
	{ "n", "<C-w>v", ":vsplit<CR>", "Split current buffer vertically" },
	{
		"n",
		"<leader>bl",
		function()
			builtin.buffers()
		end,
		"[b]uffer: open the buffer list",
	},
	{ "n", "<S-h>", "<CMD>bprevious<CR>", "Navigate to prev buffer" },
	{ "n", "<S-l>", "<CMD>bnext<CR>", "Navigate to next buffer" },
	{
		"n",
		"<leader>k",
		":ls<CR>:echo '[nvim] Choose a buf to delete (blank: choose curr buf, RET: confirm, ESC: cancel)'<CR>:bdelete<SPACE>",
		"[k]ill : Choose a buffer to kill",
	},
	{
		"n",
		"<C-h>",
		"<C-w>h",
		"Switch to left split buffer",
	},
	{
		"n",
		"<C-l>",
		"<C-w>l",
		"Switch to right split buffer",
	},
	{
		"n",
		"<C-j>",
		"<C-w>j",
		"Switch to bottom split buffer",
	},
	{
		"n",
		"<C-k>",
		"<C-w>k",
		"Switch to top split buffer",
	},
	{
		"n",
		"<leader>bd",
		":%bd|e#|bd#<CR>",
		"Close all buffers but this one",
	},

	-- Window --
	{
		"n",
		"<leader>w",
		":w<CR>",
		"Write",
	},
	{
		"n",
		"<leader>W",
		":wa<CR>",
		"Write all",
	},
	{
		"n",
		"<leader>q",
		":q<CR>",
		"Quit",
	},
	{
		"n",
		"<leader>Q",
		":qa<CR>",
		"Quit all",
	},
	{
		"n",
		"<leader>c",
		":bp<bar>sp<bar>bn<bar>bd<CR>",
		"Buffer close",
	},

	-- Tab --
	{
		"n",
		"<leader>bt",
		":ls<CR>:echo '[nvim] Choose a buf to create a new tab w/ (blank: choose curr buf, RET: confirm, ESC: cancel)'<CR>:tab sb<SPACE>",
		"[t]ab: create a new tab",
	},

	-- LSP --
	{
		"n",
		"K",
		function()
			vim.lsp.buf.hover()
		end,
		"Open manual/doc",
	},
	{
		"n",
		"gd",
		function()
			vim.lsp.buf.definition()
		end,
		"Goto definition",
	},
	{
		"n",
		"gr",
		function()
			builtin.lsp_references()
		end,
		"Search references",
	},
	{
		"n",
		"<leader>lj",
		function()
			vim.diagnostic.goto_next()
		end,
		"Jump to next diagnostic",
	},
	{
		"n",
		"<leader>lk",
		function()
			vim.diagnostic.goto_prev()
		end,
		"Jump to prev diagnostic",
	},
	{
		"n",
		"<leader>ll",
		function()
			builtin.diagnostics()
		end,
		"Search diagnostics",
	},
	{
		"n",
		"<leader>lf",
		function()
			require("conform").format()
		end,
		"Format",
	},
	{
		"n",
		"<leader>la",
		function()
			vim.lsp.buf.code_action()
		end,
		"Code action",
	},
	{
		"n",
		"<leader>ls",
		function()
			builtin.lsp_document_symbols()
		end,
		"Search symbols",
	},
	{
		"n",
		"<leader>lm",
		function()
			builtin.man_pages()
		end,
		"Search man pages",
	},
	{ "n", "<leader>lc", ":Copilot panel<CR>", "Copilot panel" },
	{
		"n",
		"<leader>lX",
		function()
			-- vim.cmd("LspStop")
			vim.diagnostic.config({ virtual_text = false, signs = false, underline = false })
		end,
		"Disable LSP diagnostics/signs",
	},
	{
		"n",
		"<leader>lS",
		function()
			vim.diagnostic.config({ virtual_text = true, signs = true, underline = true })
			-- vim.cmd("LspStart")
		end,
		"Enable LSP diagnostics/signs",
	},

	-- Config --
	{
		"n",
		"<leader>Cc",
		function()
			require("telescope.builtin").find_files({
				cwd = "~/.config/nvim",
				prompt_title = "Nvim Config",
				hidden = true,
			})
		end,
		"Open nvim lsp config directory",
	},
	{
		"n",
		"<leader>Ci",
		":tabnew ~/.config/nvim/init.lua<CR>",
		"Open nvim config (init.lua)",
	},
	{
		"n",
		"<leader>Cp",
		":tabnew ~/.config/nvim/lua/plugins.lua<CR>",
		"Open nvim plugins (plugins.lua)",
	},
	{
		"n",
		"<leader>Ck",
		":tabnew ~/.config/nvim/lua/keybinds.lua<CR>",
		"Open nvim keybinds (keybinds.lua)",
	},
	{
		"n",
		"<leader>Cd",
		":tabnew ~/.config/nvim/lua/debugger/dap.lua<CR>",
		"Open nvim debugger config (dap.lua)",
	},
	{
		"n",
		"<leader>CL",
		":tabnew ~/.config/nvim/lua/lsp/lsp.lua<CR>",
		"Open nvim lsp config (lsp.lua)",
	},
	{ "n", "<leader>Cf", ":ConformInfo<CR>", "Formatter info" },
	{ "n", "<leader>Cm", ":Mason<CR>", "Open Mason" },
	{ "n", "<leader>Cl", ":Lazy<CR>", "Open Lazy" },

	-- Terminal --
	{ "t", "<ESC>", "<C-\\><C-n>", "[ESC]: exit insert mode for the terminal" },
	{
		"n",
		"<leader>T",
		function() --> will be overriden in misc.lua terminal location picker
			vim.cmd("topleft " .. math.ceil(vim.fn.winheight(0) * (1 / 3)) .. "sp | term")
		end,
		"Open terminal",
	},
	{ "n", "<leader>vn", ":VimuxPromptCommand<CR>", "Tmux new command" },
	{ "n", "<leader>vc", ":VimuxClearTerminalScreen<CR>", "Tmux clear" },
	{ "n", "<leader>vi", ":VimuxInspectRunner<CR>", "Tmux inspect" },
	{ "n", "<leader>vv", ":VimuxRunLastCommand<CR>", "Tmux last command" },

	-- Avante --
	{ "n", "<leader>as", ":AvanteToggle<CR>", "Avante toggle" },
	{ "n", "<leader>aa", ":AvanteAsk<CR>", "Avante ask" },
	{ "n", "<leader>ac", ":AvanteClear<CR>", "Avante clear" },
	{ "n", "<leader>an", ":AvanteChatNew<CR>", "Avante new" },
	{ "n", "<leader>am", ":AvanteModels<CR>", "Avante models" },
	{ "n", "<leader>al", ":AvanteHistory<CR>", "Avante history" },
	{ "v", "<leader>ad", ":LLMAppHandler Ask<CR>", "LLM ask" },
	{ "v", "<leader>ae", ":LLMSelectedTextHandler explain<CR>", "LLM explain" },

	-- Leetcode --
	{ "n", "<leader>LL", ":LBQuestions<CR>", "LeetCode questions" },
	{ "n", "<leader>Lq", ":LBQuestion<CR>", "LeetCode question" },
	{ "n", "<leader>Lx", ":LBClose<CR>", "LeetCode close" },
	{ "n", "<leader>Lt", ":LBTest<CR>", "LeetCode test" },
	{ "n", "<leader>Ls", ":LBSubmit<CR>", "LeetCode submit" },
}
-- }}}

-- Set keybindings
for _, v in ipairs(key_opt) do
	-- non-recursive mapping, call commands silently
	local opts = { noremap = true, silent = true }
	-- Add optional description to the table if provided
	if v[4] then
		opts.desc = v[4]
	end
	-- Set keybinding
	keymap.set(v[1], v[2], v[3], opts)
end
