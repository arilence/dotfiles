-- references
-- - https://tduyng.com/blog/neovim-basic-setup/#optionslua

-- Plugins
vim.pack.add({
  -- LSP
  "https://github.com/neovim/nvim-lspconfig",

  -- Color scheme
  "https://github.com/folke/tokyonight.nvim"
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

