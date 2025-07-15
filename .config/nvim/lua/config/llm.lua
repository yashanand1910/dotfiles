--[[ llm.lua
-- Configuration for llm.nvim, a Neovim plugin for interacting with LLMs
--]]

local model = "GPT 4.1"
local modelCode = "gpt-4.1"

local Text = require("nui.text")
local llm = require("llm")
local tools = require("llm.tools")
llm.setup({
	url = "https://models.inference.ai.azure.com/chat/completions",
	model = modelCode,
	api_type = "openai",
	prompt = "You are an elite programmer. You are very concise and to the point.",

	save_session = true,
	max_history = 15,
	max_history_name_length = 20,
	fetch_key = function()
		return vim.env.GITHUB_KEY
	end,
	keys = {
		-- The keyboard mapping for the input window.
		["Input:Submit"] = { mode = { "n", "i" }, key = "<C-g>" },
		["Input:Cancel"] = { mode = { "n", "i" }, key = "<Esc>" },
		["Input:Resend"] = { mode = { "n", "i" }, key = "<C-r>" },
		-- Switch from the output window to the input window.
		["Focus:Input"] = { mode = "n", key = { "i", "<C-j>" } },
		-- Switch from the input window to the output window.
		["Focus:Output"] = { mode = { "n", "i" }, key = "<C-k>" },

		-- only works when "save_session = true"
		["Input:HistoryNext"] = { mode = { "n", "i" }, key = "<C-n>" },
		["Input:HistoryPrev"] = { mode = { "n", "i" }, key = "<C-p>" },
		["Input:HistoryDelete"] = { mode = { "n", "i" }, key = "<C-x>" },

		-- The keyboard mapping for the output and input windows in "float" style.
		["Session:Toggle"] = { mode = "n", key = "<leader>ac" },
		["Session:Close"] = { mode = "n", key = { "<C-c>", "<esc>", "q" } },
		["Session:Models"] = { mode = "n", key = { "<C-.>" } },

		-- Scroll
		["PageUp"] = { mode = { "i", "n" }, key = "<C-u>" },
		["PageDown"] = { mode = { "i", "n" }, key = "<C-d>" },
		["HalfPageUp"] = { mode = { "i", "n" }, key = "<C-e>" },
		["HalfPageDown"] = { mode = { "i", "n" }, key = "<C-y>" },
		["JumpToTop"] = { mode = "n", key = "gg" },
		["JumpToBottom"] = { mode = "n", key = "G" },
	},
	prefix = {
		user = { text = "  ", hl = "Title" },
		assistant = { text = "  ", hl = "Added" },
	},
	chat_ui_opts = {
		relative = "editor",
		position = "50%",
		size = {
			width = "80%",
			height = "80%",
		},
		win_options = {
			winblend = 0,
			winhighlight = "Normal:String,FloatBorder:Float",
		},
		input = {
			float = {
				border = {
					text = {
						top = Text("", "LlmYellowNormal"),
						top_align = "center",
					},
				},
				win_options = {
					winblend = 0,
					winhighlight = "Normal:String,FloatBorder:LlmYellowLight",
				},
				size = { height = "10%", width = "80%" },
				order = 2,
			},
			split = {
				relative = "editor",
				position = {
					row = "80%",
					col = "50%",
				},
				border = {
					text = {
						top = Text("", "LlmYellowNormal"),
						top_align = "center",
					},
				},
				win_options = {
					winblend = 0,
					winhighlight = "Normal:String,FloatBorder:LlmYellowLight",
				},
				size = { height = "10%", width = "80%" },
			},
		},
		output = {
			float = {
				border = {
					text = {
						top = Text(" " .. model .. " ", "LlmYellowNormal"),
						top_align = "right",
					},
				},
				size = { height = "90%", width = "80%" },
				order = 1,
				win_options = {
					winblend = 0,
					winhighlight = "Normal:Normal,FloatBorder:Title",
				},
			},
		},
		history = {
			float = {
				border = {
					text = {
						top = Text("", "LlmYellowNormal"),
						top_align = "center",
					},
				},
				size = { height = "100%", width = "20%" },
				win_options = {
					winblend = 0,
					winhighlight = "Normal:LlmBlueNormal,FloatBorder:Title",
				},
				order = 3,
			},
		},
	},
	-- popup window options
	popwin_opts = {
		relative = "cursor",
		enter = true,
		focusable = true,
		zindex = 50,
		position = {
			row = 0,
			col = 0,
		},
		size = {
			height = 30,
			width = "60%",
		},
		border = { text = { top = Text(" " .. model .. " ", "LlmYellowNormal"), top_align = "right" } },
		win_options = {
			winblend = 0,
			winhighlight = "Normal:Normal,FloatBorder:LlmBlueLight",
		},
		-- move popwin
		move = {
			left = {
				mode = "n",
				keys = "<left>",
				distance = 5,
			},
			right = {
				mode = "n",
				keys = "<right>",
				distance = 5,
			},
			up = {
				mode = "n",
				keys = "<up>",
				distance = 2,
			},
			down = {
				mode = "n",
				keys = "<down>",
				distance = 2,
			},
		},
	},

	app_handler = {
		Ask = {
			handler = tools.disposable_ask_handler,
			opts = {
				inline_assistant = true,
				language = "English",
				timeout = 30,
				win_options = {
					winblend = 0,
					winhighlight = "Normal:Normal,FloatBorder:Normal",
				},
				border = {
					text = {
						top = Text(" " .. model .. " ", "LlmYellowNormal"),
						top_align = "right",
					},
				},
				position = {
					row = 0,
					col = 0,
				},
				relative = "cursor",
				size = {
					width = "50%",
					height = 1,
				},
				enter = true,
				display = {
					mapping = {
						mode = "n",
						keys = { "d" },
					},
					action = nil,
				},
				-- copy_suggestion_code = {
				-- 	mapping = {
				-- 		mode = "n",
				-- 		keys = { "Y", "y" },
				-- 	},
				-- },
				accept = {
					mapping = {
						mode = "n",
						keys = { "C-g" },
					},
					action = nil,
				},
				reject = {
					mapping = {
						mode = "n",
						keys = { "C-c" },
					},
					action = nil,
				},
				close = {
					mapping = {
						mode = "n",
						keys = { "<esc>", "q" },
					},
					action = nil,
				},
			},
		},
		AttachToChat = {
			handler = tools.attach_to_chat_handler,
			opts = {
				is_codeblock = true,
				inline_assistant = true,
				language = "English",
				-- display diff
				display = {
					mapping = {
						mode = "n",
						keys = { "d" },
					},
					action = nil,
				},
				-- accept diff
				accept = {
					mapping = {
						mode = "n",
						keys = { "C-g" },
					},
					action = nil,
				},
				-- reject diff
				reject = {
					mapping = {
						mode = "n",
						keys = { "C-c" },
					},
					action = nil,
				},
				-- close diff
				close = {
					mapping = {
						mode = "n",
						keys = { "<esc>", "q" },
					},
					action = nil,
				},
			},
		},
	},
})
