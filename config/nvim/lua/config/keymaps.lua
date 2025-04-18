-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Clear current search with //
vim.keymap.set("n", "//", ":nohlsearch <CR>")

-- Stay in visual mode when indenting
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- Prevents (P)aste from overwriting value in buffer. This is handy when pasting a
-- value to multiple locations.
vim.keymap.set("v", "p", '"_dP')

-- Change the default Split Window Right
vim.keymap.del("n", "<leader>|")
vim.keymap.set("n", "<leader>\\", "<C-W>v", { desc = "Split Window Right", remap = true })

-- Remove the default "Open Terminal window"
vim.keymap.del("n", "<C-_>")
