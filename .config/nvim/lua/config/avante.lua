--[[ avante.lua
-- Configuration for avante.llm
--]]

local avante = require("avante")

avante.setup({
	debug = false,
	log_level = vim.log.levels.WARN,
	mode = "agentic",
	provider = "claude-code",
	tokenizer = "tiktoken",
	system_prompt = nil,
	override_prompt_dir = nil,
	rules = {
		-- These must point at directories containing *.avanterules template files,
		-- not at the project root itself
		project_dir = ".avante/rules", -- relative to project root
		global_dir = os.getenv("HOME") .. "/.config/avante/rules",
	},
	behaviour = {
		auto_focus_sidebar = true,
		-- Broken with ACP providers: suggestion.lua looks up Providers["claude-code"],
		-- which doesn't exist as a completion provider, so every insert-mode trigger errors
		auto_suggestions = false, -- Experimental stage
		auto_suggestions_respect_ignore = false,
		auto_set_highlight_group = true,
		auto_set_keymaps = true,
		auto_apply_diff_after_generation = true,
		jump_result_buffer_on_finish = true,
		support_paste_from_clipboard = false,
		minimize_diff = true,
		enable_token_counting = true,
		use_cwd_as_project_root = false,
		auto_focus_on_diff_view = true,
		---@type boolean | string[] -- true: auto-approve all tools, false: normal prompts, string[]: auto-approve specific tools by name
		auto_approve_tool_permissions = true, -- Default: auto-approve all tools (no prompts)
		auto_check_diagnostics = true,
		allow_access_to_git_ignored_files = false,
		enable_fastapply = true, -- requires Morph + MORPH_API_KEY
		include_generated_by_commit_line = false,
		auto_add_current_file = true,
		confirmation_ui_style = "inline_buttons",
		acp_follow_agent_locations = true,
	},
	rag_service = { -- RAG Service configuration
		enabled = false, -- Enables the RAG service (see https://www.reddit.com/r/AI_Agents/comments/1ij4435/why_shouldnt_use_rag_for_your_ai_agents_and_what/)
		runner = "docker", -- Runner for the RAG service (can use docker or nix)
		llm = { -- Language Model (LLM) configuration for RAG service
			provider = "openai", -- LLM provider
			endpoint = "https://api.openai.com/v1", -- LLM API endpoint
			api_key = "OPENAI_API_KEY", -- Environment variable name for the LLM API key
			model = "gpt-5.6-luna", -- LLM model name
			extra = nil,
		},
		embed = { -- Embedding model configuration for RAG service
			provider = "openai", -- Embedding provider
			endpoint = "https://api.openai.com/v1", -- Embedding API endpoint
			api_key = "OPENAI_API_KEY", -- Environment variable name for the embedding API key
			model = "text-embedding-3-large", -- Embedding model name
			extra = { -- Extra configuration options for the Embedding model (optional)
				max_embedding_tokens = 512, -- Maximum tokens per chunk sent to the embedding model
			},
		},
	},
	providers = {
		-- claude = {
		-- 	endpoint = "https://api.anthropic.com",
		-- 	model = "claude-opus-5",
		-- 	timeout = 30000, -- Timeout in milliseconds
		-- 	extra_request_body = {
		-- 		temperature = 1,
		-- 		max_tokens = 20000,
		-- 	},
		-- },
		-- gemini = {
		-- 	endpoint = "https://generativelanguage.googleapis.com/v1beta/models",
		-- 	model = "gemini-3-pro-preview",
		-- 	-- timeout = 30000, -- Timeout in milliseconds
		-- 	context_window = 1048576,
		-- 	use_ReAct_prompt = true,
		-- 	extra_request_body = {
		-- 		generationConfig = {
		-- 			temperature = 0.75,
		-- 		},
		-- 	},
		-- },
		morph = {
			model = "morph-v3-large",
		},
	},
	acp_providers = {
		["gemini-cli"] = {
			command = "gemini",
			args = { "--experimental-acp" },
			env = {
				NODE_NO_WARNINGS = "1",
				GEMINI_API_KEY = os.getenv("GEMINI_API_KEY"),
			},
			auth_method = "gemini-api-key",
		},
		["claude-code"] = {
			command = "npx",
			args = { "-y", "@agentclientprotocol/claude-agent-acp" },
			env = {
				NODE_NO_WARNINGS = "1",
				-- ANTHROPIC_API_KEY = os.getenv("ANTHROPIC_API_KEY"), -- Use claude code that's logged-in
				-- ANTHROPIC_BASE_URL = os.getenv("ANTHROPIC_BASE_URL"),
				-- Wrapper around `claude` that appends --allowedTools Grep,Glob: the
				-- 2.1.28x default tool preset drops those tools and search falls back to
				-- verbose Bash grep. See scripts/claude-acp.
				ACP_PATH_TO_CLAUDE_CODE_EXECUTABLE = vim.fn.expand("~/code/dotfiles/scripts/claude-acp"),
				ACP_PERMISSION_MODE = "bypassPermissions",
			},
		},
	},
	mappings = {
		---@class AvanteConflictMappings
		diff = {
			ours = "co",
			theirs = "ct",
			all_theirs = "cT",
			both = "cA",
			cursor = "cc",
			next = "]x",
			prev = "[x",
		},
		suggestion = {
			accept = "<M-l>",
			next = "<M-]>",
			prev = "<M-[>",
			dismiss = "<C-]>",
		},
		jump = {
			next = "]]",
			prev = "[[",
		},
		submit = {
			normal = "<CR>",
			insert = "<C-s>",
		},
		cancel = {
			normal = { "<C-c>", "<Esc>", "q" },
			insert = { "<C-c>" },
		},
		-- NOTE: The following will be safely set by avante.nvim
		ask = "<leader>aa",
		new_ask = "<leader>an",
		edit = "<leader>ae",
		refresh = "<leader>ar",
		focus = "<leader>af",
		stop = "<leader>aS",
		toggle = {
			default = "<leader>at",
			debug = "<leader>ad",
			suggestion = "<leader>as",
			repomap = "<leader>aR",
		},
		sidebar = {
			next_prompt = "]p",
			prev_prompt = "[p",
			apply_all = "A",
			apply_cursor = "a",
			retry_user_request = "r",
			edit_user_request = "e",
			switch_windows = "<C-tab>",
			reverse_switch_windows = "<C-S-tab>",
			toggle_code_window = "<C-l>",
			remove_file = "d",
			add_file = "@",
			close = { "q" },
			close_from_input = { normal = "q" },
			toggle_code_window_from_input = { normal = "<C-l>", insert = "<C-l>" },
		},
		files = {
			add_current = "<leader>ab", -- Add current buffer to selected files
			add_all_buffers = "<leader>aB", -- Add all buffer files to selected files
		},
		select_model = "<leader>a?", -- Select model command
		select_history = "<leader>ah", -- Select history command
		confirm = {
			focus_window = "<C-w>a",
			code = "c",
			resp = "r",
			input = "i",
		},
	},
	selector = {
		-- Used by history (<leader>ah), model (<leader>a?), and @file pickers.
		-- Telescope: <CR> opens directly, <C-Del> deletes a history entry,
		-- preview pane renders the conversation as markdown.
		provider = "telescope",
		provider_opts = {},
	},
	input = {
		provider = "snacks", -- floating input popup instead of cmdline vim.ui.input
		provider_opts = {},
	},
	prompt_logger = { -- logs prompts to disk (timestamped, for replay/debugging)
		enabled = true, -- toggle logging entirely
		log_dir = vim.fn.stdpath("cache"), -- directory where logs are saved
		max_entries = 100, -- the uplimit of entries that can be sotred
		next_prompt = {
			normal = "<C-n>", -- load the next (newer) prompt log in normal mode
			insert = "<C-n>",
		},
		prev_prompt = {
			normal = "<C-p>", -- load the previous (older) prompt log in normal mode
			insert = "<C-p>",
		},
	},
	windows = {
		sidebar_header = {
			include_model = true, -- show active provider/model in the sidebar header
		},
		input = {
			prefix = "",
			height = 1, -- starting point only; see the autocmds below
		},
	},
})

-- Keep the input window bare: no "Ask (<C-tab>: switch focus)" winbar and no
-- "Tokens: N; <C-s>: submit" floating hint. Neither has its own config toggle
-- (windows.sidebar_header.enabled would also drop the result header + model).
local Sidebar = require("avante.sidebar")
Sidebar.render_input = function() end
Sidebar.show_input_hint = function() end

-- Size the input window to its content: 1 line while focused, growing with the
-- text (wrapped lines included, capped at half the screen), and 0 lines once
-- it is empty and unfocused.
-- Neovim keeps the current window at >= 1 line regardless, so the collapse
-- happens when focus moves away (avante jumps to the result once a reply is
-- done). The result window has winfixheight from nui, so drop it while
-- resizing and let the result absorb the change. Also re-applied on
-- VimResized, since avante's own handler only re-applies widths and the row
-- redistribution would otherwise land on the input window.
vim.o.winminheight = 0 -- required for a 0-line window

local function fit_input_window()
	local sidebar = require("avante").get()
	if not sidebar or not sidebar:is_open() then
		return
	end
	local result, input = sidebar.containers.result, sidebar.containers.input
	if
		not (result and input and result.winid and input.winid)
		or not vim.api.nvim_win_is_valid(result.winid)
		or not vim.api.nvim_win_is_valid(input.winid)
	then
		return
	end
	local height
	local lines = vim.api.nvim_buf_get_lines(input.bufnr, 0, -1, false)
	if #lines == 1 and lines[1] == "" then
		height = vim.api.nvim_get_current_win() == input.winid and 1 or 0
	else
		-- Capped so a long prompt can't squeeze the result window out.
		height = math.min(vim.api.nvim_win_text_height(input.winid, {}).all, math.floor(vim.o.lines / 2))
	end
	vim.wo[result.winid].winfixheight = false
	vim.api.nvim_win_set_height(input.winid, height)
	vim.wo[result.winid].winfixheight = true
end

local group = vim.api.nvim_create_augroup("avante_fit_input_height", { clear = true })
vim.api.nvim_create_autocmd("VimResized", { group = group, callback = fit_input_window })
vim.api.nvim_create_autocmd("FileType", {
	group = group,
	pattern = "AvanteInput",
	callback = function(ev)
		-- Scheduled so BufLeave runs after the window switch (the input is still
		-- the current window while BufLeave fires, which pins it at 1 line).
		local function fit_later()
			vim.schedule(fit_input_window)
		end
		vim.api.nvim_create_autocmd({ "BufEnter", "BufLeave", "TextChanged", "TextChangedI", "TextChangedP" }, {
			group = group,
			buffer = ev.buf,
			callback = fit_later,
		})
		fit_later()
	end,
})
