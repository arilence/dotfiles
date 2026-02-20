local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Disables moving the cursor with the arrow keys while in normal mode.
-- I originally did this to learn vim locomation and now just keep it around out of habit.
vim.api.nvim_set_keymap("n", "<Up>", "", { noremap = true })
vim.api.nvim_set_keymap("n", "<Down>", "", { noremap = true })
vim.api.nvim_set_keymap("n", "<Left>", "", { noremap = true })
vim.api.nvim_set_keymap("n", "<Right>", "", { noremap = true })

-- Smart vertical movement
-- Moves by actual lines when using a count (i.e. 5j or 3k)
-- But will move by visual lines when not using a count
-- Helpful when a line wraps and want to stay on the same logical line
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

-- Clear current search with //
map("n", "//", ":nohlsearch <CR>")

-- Toggle comments
map("n", "<C-/>", "gcc", { remap = true } )
map("v", "<C-/>", "gc", { remap = true })

-- Stay in visual mode when indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Prevents (P)aste from overwriting value in buffer. This is handy when pasting a
-- value to multiple locations.
map("v", "p", '"_dP')

-- Moving between splits (requires smart-splits.nvim plugin)
map('n', '<C-h>', require('smart-splits').move_cursor_left)
map('n', '<C-j>', require('smart-splits').move_cursor_down)
map('n', '<C-k>', require('smart-splits').move_cursor_up)
map('n', '<C-l>', require('smart-splits').move_cursor_right)

-- Resizing splits (requires smart-splits.nvim plugins)
map('n', '<A-h>', require('smart-splits').resize_left)
map('n', '<A-j>', require('smart-splits').resize_down)
map('n', '<A-k>', require('smart-splits').resize_up)
map('n', '<A-l>', require('smart-splits').resize_right)
