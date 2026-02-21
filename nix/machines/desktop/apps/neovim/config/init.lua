-- references
-- - https://tduyng.com/blog/neovim-basic-setup/#optionslua

-- Plugins
vim.pack.add({
  -- Color scheme
  "https://github.com/folke/tokyonight.nvim",

  -- LSP
  "https://github.com/neovim/nvim-lspconfig",

  -- Better code commenting
  "https://github.com/numToStr/Comment.nvim",

  -- Zellij Pane Navigation
  "https://github.com/mrjones2014/smart-splits.nvim"
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
