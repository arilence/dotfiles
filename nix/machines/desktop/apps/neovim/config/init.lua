-- references
-- - https://tduyng.com/blog/neovim-basic-setup/#optionslua

-- Plugins
vim.pack.add({
  -- Color scheme
  "git@github.com:folke/tokyonight.nvim",

  -- LSP
  "git@github.com:neovim/nvim-lspconfig",

  -- Code Completion
  "git@github.com:saghen/blink.lib",
  "git@github.com:saghen/blink.cmp",

  -- Better code commenting
  "git@github.com:numToStr/Comment.nvim",

  -- Collection of QoL Plugins
  "git@github.com:folke/snacks.nvim",

  -- Encrypt/Decrypt files using SOPS
  {
    src = "git@github.com:arilence/sops.nvim",
    version = "fork",
  },
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

-- Go Lang
vim.lsp.enable('gopls')

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
-- nvim-treesitter is deprecated, which means this won't work: require('nvim-treesitter.configs').setup()
-- This is apparently a workaround that seems to work on nvim 0.12
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function(event)
    local filetype = vim.bo[event.buf].filetype
    local language = vim.treesitter.language.get_lang(filetype)

    if language and vim.treesitter.language.add(language) then
      vim.treesitter.start(event.buf, language)
    end
  end,
})
