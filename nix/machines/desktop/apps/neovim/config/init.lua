-- references
-- - https://tduyng.com/blog/neovim-basic-setup/#optionslua

-- Plugins
vim.pack.add({
  -- LSP
  "https://github.com/neovim/nvim-lspconfig",

  -- Color scheme
  "https://github.com/folke/tokyonight.nvim",

  -- Zellij Pane Navigation
  "https://github.com/mrjones2014/smart-splits.nvim"
})

require("tokyonight").setup({
  style = "day",
  transparent = false,
})
vim.cmd.colorscheme("tokyonight")

-- LSP
vim.lsp.enable('expert')
vim.lsp.config('expert', {
  settings = {
    workspaceSymbols = {
      minQueryLength = 0
    }
  }
})

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
