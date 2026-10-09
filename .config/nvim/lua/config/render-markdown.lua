--[[ render-markdown.lua
-- Configuration for render-markdown.nvim, in-buffer markdown rendering
--]]

-- Inline HTML tags (common in GitHub PR/issue bodies) rendered like their
-- markdown equivalents: tags concealed, icon inlined, link text highlighted.
-- Needs the "html" tree-sitter parser (installed in config/treesitter.lua).
local html_tags = {
	img = { icon = "󰥶 ", highlight = "RenderMarkdownImage" },
	a = { icon = "󰌹 ", highlight = "RenderMarkdownLink", scope_highlight = "RenderMarkdownLink" },
}

-- The builtin html handler only matches `<tag>` start tags, so self-closing
-- `<img ... />` is skipped. This extends it with the same treatment.
local function self_closing_tags(ctx)
	local Context = require("render-markdown.request.context")
	local Marks = require("render-markdown.lib.marks")
	local ts = require("render-markdown.core.ts")

	local context = Context.get(ctx.buf)
	local config = context.config.html
	if not config.enabled then
		return {}
	end
	local marks = Marks.new(context, true)
	local query = ts.parse("html", "(element (self_closing_tag)) @tag")
	context.view:nodes(ctx.root, query, function(_, node)
		local tag = node:child("self_closing_tag")
		local name = tag and tag:child("tag_name")
		local tag_config = name and config.tag[name.text]
		if not tag_config then
			return
		end
		marks:over(config, true, node, { conceal = "" })
		if tag_config.icon and tag_config.highlight then
			marks:start(config, false, node, {
				virt_text = { { tag_config.icon, tag_config.highlight } },
				virt_text_pos = "inline",
			})
		end
	end)
	return marks:get()
end

require("render-markdown").setup({
	file_types = { "markdown", "Avante", "AvanteInput", "octo", "gitcommit" },
	html = { tag = html_tags },
	custom_handlers = {
		html = { extends = true, parse = self_closing_tags },
	},
})
