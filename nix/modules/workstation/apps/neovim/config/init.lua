-- Set options (including the leader key) before loading plugins.
require("config.options")

-- Plugins
vim.pack.add({
  -- Color scheme
  "git@github.com:folke/tokyonight.nvim",

  -- LSP
  "git@github.com:neovim/nvim-lspconfig",

  -- Code Completion
  "git@github.com:saghen/blink.lib",
  "git@github.com:saghen/blink.cmp",

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
-- Code Completion
require('blink.cmp').setup({
  keymap = {
    ['<C-k>'] = { 'select_prev', 'fallback_to_mappings' },
    ['<C-j>'] = { 'select_next', 'fallback_to_mappings' },
    ['<Tab>'] = { 'select_and_accept', 'fallback' },
  },
  cmdline = {
    keymap = {
      -- completions inside of `:` commands require their own keybinds separate from what we set
      -- above.
      ['<C-j>'] = { 'show_and_insert_or_accept_single', 'select_next' },
      ['<C-k>'] = {
        function(cmp) return cmp.show_and_insert_or_accept_single({ initial_selected_item_idx = -1 }) end,
        'select_prev',
      },
    },
  },
  completion = {
    documentation = { auto_show = true },
  },
  -- TODO: rust implementation fails to install on nixos
  fuzzy = { implementation = "lua" },
  signature = { enabled = true },
})

-----
-- Snacks.nvim: explorer navigation and quality-of-life features

-- Connect Snacks Explorer's Ctrl-H/J/K/L actions to smart-splits.nvim.
-- The explorer list floats inside a sidebar split, so smart-splits needs to
-- navigate from that containing split to find neighboring Neovim or Kitty panes.
local function explorer_move(direction)
  return function(picker)
    local current = vim.api.nvim_get_current_win()
    local sidebar = picker.layout.root.win
    -- Bypass Snacks' focus autocmds while selecting the containing split.
    vim.cmd("noautocmd call win_gotoid(" .. sidebar .. ")")
    require("smart-splits")["move_cursor_" .. direction]()
    -- If navigation stayed in this split (including a Kitty handoff), restore
    -- the explorer list so it remains focused when we return to Neovim.
    if vim.api.nvim_get_current_win() == sidebar and vim.api.nvim_win_is_valid(current) then
      vim.api.nvim_set_current_win(current)
    end
  end
end

require('snacks').setup({
  scroll = {
    enabled = true,
  },
  explorer = {
    enabled = true,
    auto_close = true,
    replace_netrw = false,
    trash = true -- Use the system trash when deleting files
  },
  picker = {
    enabled = true,
    sources = {
      files = {
        -- Some config files start with a dot which counts as a hidden file.
        -- However, I want to see files like `.sops.yaml` or `.mise.toml`
        -- .git is excluded by default.
        hidden = true,
        ignored = false
      },
      explorer = {
        hidden = true,
        ignored = true,
        actions = {
          split_left = explorer_move("left"),
          split_down = explorer_move("down"),
          split_up = explorer_move("up"),
          split_right = explorer_move("right"),
        },
        layout = {
          cycle = false,
          layout = {
            position = "right"
          }
        },
        win = {
          list = {
            keys = {
              -- Reserve Ctrl-H/J/K/L for smart-splits navigation.
              -- Use j/k or Ctrl-N/Ctrl-P to move through the explorer list.
              ["<C-h>"] = "split_left",
              ["<C-j>"] = "split_down",
              ["<C-k>"] = "split_up",
              ["<C-l>"] = "split_right",
            },
          },
        }
      }
    },
    actions = {
      clear_input = function(picker)
        picker.input:set("", "")
      end,
    },
    win = {
      input = {
        keys = {
          ["<C-u>"] = {
            "clear_input",
            mode = { "i", "n" },
            desc = "Clear search",
          },
        },
      },
    }
  },
})

require("config.lspconfig")
require("config.keymaps")
require("config.autocmds")
