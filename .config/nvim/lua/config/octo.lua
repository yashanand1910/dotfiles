--[[ octo.lua
-- Configuration for octo.nvim, GitHub integration
--]]
require("octo").setup({
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
			add_reviewer = { lhs = "<leader>ora", desc = "add reviewer" },
			remove_reviewer = { lhs = "<leader>ord", desc = "remove reviewer request" },
			review_start = { lhs = "<leader>ors", desc = "start a review for the current PR" },
			review_resume = { lhs = "<leader>orr", desc = "resume a pending review for the current PR" },
		},
		review_thread = {
			copy_sha = { lhs = "<leader>oU", desc = "copy commit SHA to system clipboard" },
			copy_url = { lhs = "<leader>ou", desc = "copy url to system clipboard" },
			close_review_tab = { lhs = "<leader>q", desc = "Close review tab" },
			select_next_entry = { lhs = "<Tab>", desc = "move to next changed file" },
			select_prev_entry = { lhs = "<S-Tab>", desc = "move to previous changed file" },
		},
		review_diff = {
			copy_sha = { lhs = "<leader>oU", desc = "copy commit SHA to system clipboard" },
			copy_url = { lhs = "<leader>ou", desc = "copy url to system clipboard" },
			close_review_tab = { lhs = "<leader>q", desc = "Close review tab" },
			submit_review = { lhs = "<leader>ors", desc = "submit review" },
			discard_review = { lhs = "<leader>ord", desc = "discard review" },
			add_comment = { lhs = "<leader>ca", desc = "add comment" },
			add_reply = { lhs = "<leader>cr", desc = "add reply" },
			add_suggestion = { lhs = "<leader>sa", desc = "add suggestion" },
			delete_comment = { lhs = "<leader>cd", desc = "delete comment" },
			select_next_entry = { lhs = "<Tab>", desc = "move to next changed file" },
			select_prev_entry = { lhs = "<S-Tab>", desc = "move to previous changed file" },
		},
		file_panel = {
			close_review_tab = { lhs = "<leader>q", desc = "Close review tab" },
			select_next_entry = { lhs = "<Tab>", desc = "move to next changed file" },
			select_prev_entry = { lhs = "<S-Tab>", desc = "move to previous changed file" },
		},
	},
})

-- <details> folds show the raw <summary> HTML as the fold line, e.g.
-- "▶ <h3>Summary</h3> …". Strip the tags so only the text is left.
local folds = require("octo.folds")
local parse_details_blocks = folds.parse_details_blocks
folds.parse_details_blocks = function(...)
	local blocks = parse_details_blocks(...)
	for _, block in ipairs(blocks) do
		local summary = vim.trim((block.summary:gsub("<[^>]*>", "")))
		block.summary = summary ~= "" and summary or "Details"
	end
	return blocks
end

-- Octo windows wrap, and wrapping counts concealed text (long image URLs,
-- HTML tags), so those lines get empty continuation rows. Drop the showbreak
-- marker there so the empty rows don't each show a "↪".
vim.api.nvim_create_autocmd("BufWinEnter", {
	group = vim.api.nvim_create_augroup("octo_showbreak", { clear = true }),
	pattern = "octo://*",
	command = "setlocal showbreak=NONE",
})
