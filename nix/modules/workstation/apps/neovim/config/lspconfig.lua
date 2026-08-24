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
vim.lsp.config('expert', {
  settings = {
    workspaceSymbols = {
      minQueryLength = 0
    }
  }
})

vim.lsp.enable('bashls')
vim.lsp.enable('gdscript') -- Godot Engine
vim.lsp.enable('gopls')
vim.lsp.enable('nixd')
vim.lsp.enable('rust_analyzer')
vim.lsp.enable('ts_ls') -- Typescript
vim.lsp.enable('yamlls')
