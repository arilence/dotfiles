-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Show a vertical line at the text column dictated by the value 'textwidth'
vim.opt.colorcolumn = "+1"

-- Show whitespace
vim.opt.list = true
vim.opt.listchars = "tab:▸ ,trail:."

-- EditorConfig is enabled by default, but just in case
vim.g.editorconfig = true
