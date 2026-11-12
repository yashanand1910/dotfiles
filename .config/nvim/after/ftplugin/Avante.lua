-- avante's own ftplugin/Avante.lua forces nowrap on the result window,
-- overriding its windows.wrap option; this runs after it.
vim.opt_local.wrap = true

-- The markdown query's conceal_lines makes every edit reparse all injections
-- once per row (quadratic), freezing long chats for tens of seconds per update.
-- Disable it for this buffer. The highlighter is started after ftplugins run
-- and re-enables _conceal_line whenever an injection is added, so block writes.
local buf = vim.api.nvim_get_current_buf()
vim.schedule(function()
	local hl = vim.treesitter.highlighter.active[buf]
	if not hl or rawget(hl, "_no_conceal_line") then
		return
	end
	rawset(hl, "_conceal_line", nil)
	rawset(hl, "_no_conceal_line", true)
	setmetatable(hl, {
		__index = getmetatable(hl),
		__newindex = function(t, k, v)
			if k ~= "_conceal_line" then
				rawset(t, k, v)
			end
		end,
	})
end)
