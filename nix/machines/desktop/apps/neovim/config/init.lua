-- references
-- - https://tduyng.com/blog/neovim-basic-setup/#optionslua

-- Plugins
vim.pack.add({
  -- Color scheme
  "https://github.com/folke/tokyonight.nvim"
})

require("tokyonight").setup({
  style = "day",
  transparent = false,
})
vim.cmd.colorscheme("tokyonight")
