local opt = vim.opt

-- Use true colour in the terminal; replaces legacy Vim terminal options that used to be here.
opt.termguicolors = true

-- Sets the leader key to use as a prefix for most things
vim.g.mapleader = " "

-- Show line numbers
opt.number = true

-- Show relative line numbers
opt.relativenumber = true

-- Enable cursorline
opt.cursorline = true

-- Show a singular global status bar at bottom instead of one for each open file
opt.laststatus = 3

-- Disable wordwrap
opt.wrap = false

-- Scroll wrapped lines by screen line; Snacks handles animated scrolling.
opt.smoothscroll = true

-- Start scrolling when we're getting close to margins
opt.scrolloff = 10
opt.sidescrolloff = 8
opt.sidescroll = 1

-- Use 4 Space characters for each indent
-- This will be overridden by any .editorconfig settings
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = 0
opt.expandtab = true
opt.smarttab = true
opt.autoindent = true

-- Search immediately after each character
opt.incsearch = true

-- Highlight searches by default
opt.hlsearch = true

-- Always show the git sign column
opt.signcolumn = "yes"

-- Allow cursor to be positioned where there is no actual character.
opt.virtualedit = "block"

-- Ignore case when searching unless the pattern contains an uppercase letter
opt.ignorecase = true
opt.smartcase = true

-- File handling
opt.encoding = "utf-8"
opt.history = 1000
opt.undolevels = 10000
opt.ttimeoutlen = 0
opt.autoread = true
opt.autowrite = true
-- Vim will wait a default of 4000 milliseconds after you stop typing
opt.updatetime = 300

-- Disable error bell sounds
opt.errorbells = false

-- Enable mouse in all modes
opt.mouse = "a"

-- Use the system clipboard for easier copy+pasting
opt.clipboard = "unnamedplus"

-- Make horizontal and vertical splitting feel better
opt.splitbelow = true
opt.splitright = true

-- Keep the text on the same screen line when opening a split
opt.splitkeep = "screen"

-- Auto update title with filename
opt.title = true

-- Show a vertical line at the text column dictated by the value 'textwidth'
opt.colorcolumn = "+1"

-- Show whitespace
opt.list = true
opt.listchars = "tab:▸ ,trail:."

-- Hide the command/message box at the bottom when it's not being used
opt.cmdheight = 0

-- Disable netrw in favor of the Snacks explorer.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Performance?
opt.redrawtime = 10000
opt.maxmempattern = 20000

-- File type detection
vim.filetype.add({
  extension = {
    env = "dotenv",
  },
  filename = {
    [".env"] = "dotenv",
    ["env"] = "dotenv",
  },
  pattern = {
    ["%.env%.[%w_.-]+"] = "dotenv",
  },
})
