-- references
-- - https://tduyng.com/blog/neovim-basic-setup/#optionslua

-- Plugins
vim.pack.add({
  -- Color scheme
  "git@github.com:folke/tokyonight.nvim",

  -- LSP
  "git@github.com:neovim/nvim-lspconfig",

  -- Code Completion
  "git@github.com:saghen/blink.cmp",

  -- Better code commenting
  "git@github.com:numToStr/Comment.nvim",

  -- Zellij Pane Navigation
  "git@github.com:mrjones2014/smart-splits.nvim",

  -- Collection of QoL Plugins
  "git@github.com:folke/snacks.nvim",
})

-----
-- Color scheme
require("tokyonight").setup({
  style = "day",
  transparent = false,
})
vim.cmd.colorscheme("tokyonight")

-----
-- LSP Configs
-- Elixir
vim.lsp.enable('expert')
vim.lsp.config('expert', {
  settings = {
    workspaceSymbols = {
      minQueryLength = 0
    }
  }
})
-- Nix
vim.lsp.enable('nixd')
-- Rust
vim.lsp.enable('rust_analyzer')
-- Godot Engine
vim.lsp.enable('gdscript')

-----
-- Code Completion
require('blink.cmp').setup({
  keymap = {
    ['<C-k>'] = { 'select_prev', 'fallback_to_mappings' },
    ['<C-j>'] = { 'select_next', 'fallback_to_mappings' },
    ['<Tab>'] = { 'select_and_accept', 'fallback' },
  },
  completion = {
    documentation = { auto_show = true },
  },
  signature = { enabled = true },
})

-----
-- Better code commenting
require('Comment').setup()

-----
-- Zellij Pane Navigation
require('smart-splits').setup({
  -- Desired behavior when your cursor is at an edge and you
  -- are moving towards that same edge:
  at_edge = 'stop',
  -- when moving cursor between splits left or right,
  -- place the cursor on the same row of the *screen*
  -- regardless of line numbers.
  move_cursor_same_row = false,
  -- In Zellij, set this to true if you would like to move to the next *tab*
  -- when the current pane is at the edge of the zellij tab/window
  zellij_move_focus_or_tab = false,
})

-----
-- Collection of QoL Plugins
require('snacks').setup({
  picker = { enabled = true }
})
