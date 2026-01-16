local opt = vim.opt

-- Hacky way to get colours working across vim and tmux
-- I wrote this probably a decade ago, so who knows if it's still needed :)
vim.cmd [[
" Enable 256 colors
set t_Co=256
" Disable background color erase in tmux
if &term =~ '256color' | set t_ut= | endif

" Use 24-bit (true-color) mode in Vim/Neovim when outside tmux.
" (see < http://sunaku.github.io/tmux-24bit-color.html#usage > for more information.)
if (has("nvim"))
  " For Neovim 0.1.3 and 0.1.4 < https://github.com/neovim/neovim/pull/2198 >
  let $NVIM_TUI_ENABLE_TRUE_COLOR=1
endif
" For Neovim > 0.1.5 and Vim > patch 7.4.1799 < https://github.com/vim/vim/commit/61be73bb0f965a895bfb064ea3e55476ac175162 >
" Based on Vim patch 7.4.1770 (`guicolors` option) < https://github.com/vim/vim/commit/8a633e3427b47286869aa4b96f2bfc1fe65b25cd >
" < https://github.com/neovim/neovim/wiki/Following-HEAD#20160511 >
if (has("termguicolors"))
    set termguicolors
endif
]]

-- Set colorscheme
--vim.g.colors_name = "iceberg"
-- vim-lumen handles automatically changing background colour based on system theme
-- opt.background = "light"

-- Show line numbers
opt.number = true

-- Show relative line numbers
opt.relativenumber = true

-- Enable cursorline
opt.cursorline = true

-- Disable wordwrap
opt.wrap = false

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
opt.smartindent = true
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

-- Enables smooth scrolling? not sure how/if this works
opt.smoothscroll = true

-- Make horizontal and vertical splitting feel better
opt.splitbelow = true
opt.splitright = true

-- Keep the text on the same screen line when opening a split
opt.splitkeep = "screen"

-- Auto update title with filename
opt.title = true

-- Default vim backspace is weird. It won't let you delete certain things while
-- in insert mode. This makes backspace work like typical editors.
-- This is the same as `set backspace=2`
opt.backspace = {
  "indent",
  "eol",
  "start",
}

-- Show a vertical line at the text column dictated by the value 'textwidth'
opt.colorcolumn = "+1"

-- Show whitespace
opt.list = true
opt.listchars = "tab:▸ ,trail:."

-- Hide the command/message box at the bottom when it's not being used
opt.cmdheight = 0

-- EditorConfig is enabled by default, but just in case
vim.g.editorconfig = true

-- Support resizing in tmux
vim.cmd [[
if exists('$TMUX') && !has('nvim')
  set ttymouse=xterm2
endif
]]

-- Disable netrw in favor of nvim-tree
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

-- Prepend mise shims to PATH
-- TODO: Check for mise first
--vim.env.PATH = vim.env.HOME .. "/.local/share/mise/shims:" .. vim.env.PATH
