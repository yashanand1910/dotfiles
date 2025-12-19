--------- Keybinds ---------

local keymaps_opts = { silent = true, buffer = true }

-- 'q' to close buffer
vim.keymap.set("n", "q", ":quit<CR>", keymaps_opts)
