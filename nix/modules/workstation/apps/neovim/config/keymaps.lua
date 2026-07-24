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
map("n", "<C-/>", "gcc", { remap = true })
map("v", "<C-/>", "gc", { remap = true })

-- Stay in visual mode when indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Moving between splits (requires smart-splits.nvim plugin)
local smart_splits = require("smart-splits")
map("n", "<C-h>", smart_splits.move_cursor_left, { desc = "Move to left split", noremap = true })
map("n", "<C-j>", smart_splits.move_cursor_down, { desc = "Move to lower split", noremap = true })
map("n", "<C-k>", smart_splits.move_cursor_up, { desc = "Move to upper split", noremap = true })
map("n", "<C-l>", smart_splits.move_cursor_right, { desc = "Move to right split", noremap = true })
-- Resizing splits (requires smart-splits.nvim plugin)
map("n", "<A-h>", smart_splits.resize_left, { desc = "Resize split left", noremap = true })
map("n", "<A-j>", smart_splits.resize_down, { desc = "Resize split down", noremap = true })
map("n", "<A-k>", smart_splits.resize_up, { desc = "Resize split up", noremap = true })
map("n", "<A-l>", smart_splits.resize_right, { desc = "Resize split right", noremap = true })

-- Prevents (P)aste from overwriting value in buffer. This is handy when pasting a
-- value to multiple locations.
map("v", "p", 'P')

-- Snacks.nvim - Collection of QoL Plugins
map('n', '<C-o>', require('snacks').picker.smart, { desc = "Smart Find Files", noremap = true })
map('n', '<C-S-f>', function() require('snacks').picker.resume('grep') end, { desc = "Grep Files", noremap = true })
map('n', '<C-]>', require('snacks').picker.explorer, { desc = "Toggle file explorer", noremap = true })
map('n', '<leader>gg', require('snacks').lazygit.open, { desc = "Open Lazygit Popup", noremap = true })
map('n', '<leader>z', function() require('snacks').zen.zoom() end, { desc = "Toggle split fullscreen", noremap = true })
