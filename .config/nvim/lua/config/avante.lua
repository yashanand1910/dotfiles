--[[ avante.lua
-- Configuration for avante.llm
--]]

local avante = require("avante")

avante.setup({
	mode = "agentic",
	provider = "claude-code",
	auto_suggestions_provider = nil,
	memory_summary_provider = nil,
	tokenizer = "tiktoken",
	system_prompt = nil,
	override_prompt_dir = nil,
	rules = {
		project_dir = nil, ---@type string | nil (could be relative dirpath)
		global_dir = os.getenv("HOME") .. "/code", ---@type string | nil (could be relative dirpath)
	},
	behaviour = {
		enable_fastapply = true, -- Enable Fast Apply feature
	},
	rag_service = { -- RAG Service configuration
		enabled = true, -- Enables the RAG service
		host_mount = os.getenv("HOME") .. "/code", -- Host directory to mount into the RAG service container
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
		docker_extra_args = "", -- Extra arguments to pass to the docker command
	},
	providers = {
		claude = {
			endpoint = "https://api.anthropic.com",
			model = "claude-opus-5",
			timeout = 30000, -- Timeout in milliseconds
			extra_request_body = {
				temperature = 1,
				max_tokens = 20000,
			},
		},
		gemini = {
			endpoint = "https://generativelanguage.googleapis.com/v1beta/models",
			model = "gemini-3-pro-preview",
			-- timeout = 30000, -- Timeout in milliseconds
			context_window = 1048576,
			use_ReAct_prompt = true,
			extra_request_body = {
				generationConfig = {
					temperature = 0.75,
				},
			},
		},
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
				-- ANTHROPIC_API_KEY = os.getenv("ANTHROPIC_API_KEY"),
				-- ANTHROPIC_BASE_URL = os.getenv("ANTHROPIC_BASE_URL"),
				ACP_PATH_TO_CLAUDE_CODE_EXECUTABLE = vim.fn.exepath("claude"),
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
			hint = "<leader>ah",
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
})
