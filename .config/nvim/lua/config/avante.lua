--[[ avante.lua
-- Configuration for avante.llm
--]]

local avante = require("avante")

-- Function to find the project root directory
local function get_project_root()
	-- Try to find git root
	local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
	if vim.v.shell_error == 0 and git_root ~= "" then
		return git_root
	end
	-- Fall back to current working directory
	return vim.fn.getcwd()
end

avante.setup({
	mode = "agentic",
	provider = "claude-code",
	behaviour = {
		enable_fastapply = true, -- Enable Fast Apply feature
	},
	providers = {
		claude = {
			endpoint = "https://api.anthropic.com",
			model = "claude-sonnet-4-5-20250929",
			timeout = 30000, -- Timeout in milliseconds
			extra_request_body = {
				temperature = 1,
				max_tokens = 20000,
			},
		},
		gemini = {
			endpoint = "https://generativelanguage.googleapis.com/v1beta/models",
			model = "gemini-2.5-flash",
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
			model = "morph-v3-fast",
		},
	},
	acp_providers = {
		["claude-code"] = {
			command = "npx",
			args = { "@zed-industries/claude-code-acp" },
			env = {
				NODE_NO_WARNINGS = "1",
				ANTHROPIC_API_KEY = os.getenv("ANTHROPIC_API_KEY"),
			},
		},
		["gemini-cli"] = {
			command = "gemini",
			args = { "--experimental-acp" },
			env = {
				NODE_NO_WARNINGS = "1",
				GEMINI_API_KEY = os.getenv("GEMINI_API_KEY"),
			},
		},
	},
	rag_service = { -- RAG Service configuration
		enabled = true, -- Enables the RAG service
		host_mount = get_project_root(), -- Host mount path for the rag service (Docker will mount this path)
		runner = "docker", -- Runner for the RAG service (can use docker or nix)
		llm = { -- Language Model (LLM) configuration for RAG service
			provider = "openai", -- LLM provider
			endpoint = "https://api.openai.com/v1", -- LLM API endpoint
			api_key = "OPENAI_API_KEY", -- Environment variable name for the LLM API key
			model = "gpt-5-mini", -- LLM model name
			extra = { -- Extra configuration options for the LLM (optional)
				temperature = 0.7, -- Controls the randomness of the output. Lower values make it more deterministic.
				max_tokens = 512, -- The maximum number of tokens to generate in the completion.
				-- system_prompt = "You are a helpful assistant.", -- A system prompt to guide the model's behavior.
				-- timeout = 120, -- Request timeout in seconds.
			},
		},
		embed = { -- Embedding model configuration for RAG service
			provider = "openai", -- Embedding provider
			endpoint = "https://api.openai.com/v1", -- Embedding API endpoint
			api_key = "OPENAI_API_KEY", -- Environment variable name for the embedding API key
			model = "text-embedding-3-large", -- Embedding model name
			extra = { -- Extra configuration options for the Embedding model (optional)
				dimensions = nil,
			},
		},
		docker_extra_args = "", -- Extra arguments to pass to the docker command
	},
	web_search_engine = {
		provider = "tavily",
		proxy = nil,
		providers = {
			tavily = {
				api_key_name = "TAVILY_API_KEY",
				extra_request_body = {
					include_answer = "basic",
				},
				format_response_body = function(body)
					return body.answer, nil
				end,
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
