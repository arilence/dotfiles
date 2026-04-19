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

  -- Collection of QoL Plugins
  "git@github.com:folke/snacks.nvim",
})

-----
-- Color scheme
require("tokyonight").setup({
  style = "moon",
  light_style = "day",
  transparent = false,
})
vim.cmd.colorscheme("tokyonight")

-----
-- LSP Configs
vim.lsp.enable('lua_ls')
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" }
      }
    }
  }
})

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

-- Typescript
vim.lsp.enable('ts_ls')

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
  -- TODO: rust implementation fails to install on nixos
  fuzzy = { implementation = "lua" },
  signature = { enabled = true },
})

-----
-- Better code commenting
require('Comment').setup()

-----
-- Collection of QoL Plugins
require('snacks').setup({
  explorer = {
    enabled = true,
    auto_close = true,
    replace_netrw = false,
    trash = true -- Use the system trash when deleting files
  },
  picker = {
    enabled = true,
    sources = {
      explorer = {
        layout = {
          cycle = false,
          layout = {
            position = "right"
          }
        }
      }
    }
  },
})

-----
-- Syntax Highlighting
require("nvim-treesitter.configs").setup({
  highlight = { enable = true },
})
