-- Change leader key to CTRL+S
vim.g.mapleader = "<C-s>"

-- Disable netrw in favor of nvim-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Disables moving the cursor with the arrow keys while in normal mode.
-- I originally did this to learn vim locomation and now just keep it around out of habit.
vim.api.nvim_set_keymap("n", "<Up>", "", { noremap = true })
vim.api.nvim_set_keymap("n", "<Down>", "", { noremap = true })
vim.api.nvim_set_keymap("n", "<Left>", "", { noremap = true })
vim.api.nvim_set_keymap("n", "<Right>", "", { noremap = true })

-- Prepend mise shims to PATH
vim.env.PATH = vim.env.HOME .. "/.local/share/mise/shims:" .. vim.env.PATH

-- Bootstraps package manager, lazy.nvim, automatically
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins through package manager
-- Use `:Lazy install` or `:Lazy update` to trigger plugin installs
require("lazy").setup {
  -- Colour Schemes
  {
    "cocopon/iceberg.vim",
    version = false,
    lazy = false,
    priority = 1000, -- make sure to load this before all the other start plugins
  },

  -- Miscellaneous
  "christoomey/vim-tmux-navigator",
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
    end,
  },

  -- Language Parsing
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = "BufRead",
    config = function()
      require("nvim-treesitter.install").prefer_git = false
      require("nvim-treesitter.install").compilers = { "zig", "gcc" }
      require("nvim-treesitter.configs").setup {
        ensure_installed = {
          "elixir",
          "heex",
          "eex",
          "vim",
          "typescript",
          "tsx",
          "graphql",
          "css",
          "c",
          "lua",
          "vimdoc",
          "query",
          "rust",
          "yaml",
        },
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
          enable_autocmd = false, -- required by nvim-ts-context-commentstring
        },
      }
    end,
    dependencies = {
      -- Comment.nvim doesn't support tsx/jsx, this adds support for the two
      "JoosepAlviste/nvim-ts-context-commentstring",
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
  },
  { "andymass/vim-matchup" },

  -- Smart commenting
  {
    "numToStr/Comment.nvim",
    keys = {
      -- `:h comment.plugmaps` for a list of commands
      { "<C-_>", "<Plug>(comment_toggle_linewise_current)<CR>", mode = { "n" } },
      { "<C-_>", "<Plug>(comment_toggle_linewise_visual)<CR>", mode = { "v" } },
    },
    opts = {
      mappings = {
        basic = false,
        extra = false,
      },
    },
    lazy = false,
    config = function()
      require("Comment").setup {
        -- pre_hook is required by nvim-ts-context-commentstring
        pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
      }
    end,
  },
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  -- Auto-completion and snippets
  {
    "hrsh7th/nvim-cmp",
    lazy = true,
    event = "InsertEnter",
    config = function()
      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match "%s" == nil
      end

      local feedkey = function(key, mode)
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
      end

      local cmp = require "cmp"
      cmp.setup {
        snippet = {
          expand = function(args)
            vim.fn["vsnip#anonymous"](args.body)
          end,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert {
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          -- Safetly select entries with Carriage Return <CR>
          -- If nothing is selected in suggestions add a newline as usual
          -- If something has explicitly been selected, autocomplete it
          ["<CR>"] = cmp.mapping.confirm { select = false },
          -- Use Tab to cycle forward through list of suggestions
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif vim.fn["vsnip#available"](1) == 1 then
              feedkey("<Plug>(vsnip-expand-or-jump)", "")
            elseif has_words_before() then
              cmp.complete()
            else
              fallback() -- The fallback function sends a already mapped key. In this case, it's probably `<Tab>`.
            end
          end, { "i", "s" }),
          -- Use Shift+Tab to cycle backwards through list of suggestions
          ["<S-Tab>"] = cmp.mapping(function()
            if cmp.visible() then
              cmp.select_prev_item()
            elseif vim.fn["vsnip#jumpable"](-1) == 1 then
              feedkey("<Plug>(vsnip-jump-prev)", "")
            end
          end, { "i", "s" }),
        },
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "vsnip" },
          { name = "git" },
        }, {
          { name = "buffer" },
        }),
      }

      -- Set configuration for specific filetype.
      cmp.setup.filetype("gitcommit", {
        sources = cmp.config.sources({
          { name = "git" }, -- requires cmp-git
        }, {
          { name = "buffer" },
        }),
      })

      -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" },
        },
      })

      -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" },
        }, {
          { name = "cmdline" },
        }),
      })
    end,
  },
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/cmp-buffer",
  "hrsh7th/cmp-path",
  "hrsh7th/cmp-cmdline",
  "hrsh7th/cmp-vsnip",
  "hrsh7th/vim-vsnip",
  { "petertriho/cmp-git", dependencies = { "nvim-lua/plenary.nvim" } },

  -- Language Server Specific
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup {
        ensure_installed = { "yamlls", "rust_analyzer" },
        automatic_installation = true,
      }
      require("lspconfig").rust_analyzer.setup {}
    end,
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "neovim/nvim-lspconfig",
    },
  },
  {
    "elixir-tools/elixir-tools.nvim",
    version = "*",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local elixir = require "elixir"
      local elixirls = require "elixir.elixirls"

      elixir.setup {
        nextls = { enable = false },
        credo = { enable = true },
        elixirls = {
          enable = true,
          tag = "v0.20.0", -- Had to specify version to work with `mise`
          settings = elixirls.settings {
            dialyzerEnabled = true,
            fetchDeps = false,
            enableTestLenses = true,
            suggestSpecs = true,
          },
        },
      }
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },

  -- Runs code formatter tools on save
  {
    "stevearc/conform.nvim",
    opts = {},
    config = function()
      local slow_format_filetypes = {}
      require("conform").setup {
        formatters_by_ft = {
          elixir = { "mix" },
          lua = { "stylua" },
          rust = { "rustfmt" },
        },
        format_on_save = function(bufnr)
          if slow_format_filetypes[vim.bo[bufnr].filetype] then
            return
          end
          local function on_format(err)
            if err and err:match "timeout$" then
              slow_format_filetypes[vim.bo[bufnr].filetype] = true
            end
          end

          return { timeout_ms = 2500, lsp_fallback = true }, on_format
        end,
        format_after_save = function(bufnr)
          if not slow_format_filetypes[vim.bo[bufnr].filetype] then
            return
          end
          return { lsp_fallback = true }
        end,
      }
    end,
  },

  -- File searching
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      local telescope = require "telescope"
      local actions = require "telescope.actions"
      telescope.setup {
        defaults = {
          mappings = {
            i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<esc>"] = actions.close,
            },
            n = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
            },
          },
        },
        pickers = {
          find_files = {
            hidden = true,
          },
        },
      }

      -- Unmap Ctrl+F
      vim.keymap.set("n", "<C-f>", "<nop>")

      local builtin = require "telescope.builtin"
      vim.keymap.set("n", "<C-p>", builtin.find_files, {})
      vim.keymap.set("n", "<C-f>", builtin.live_grep, {})
      -- vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
      -- vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
    end,
  },
  {
    "nvim-tree/nvim-web-devicons",
    config = function()
      require("nvim-web-devicons").setup()
    end,
  },
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    version = "*",
    keys = {
      { "<C-S-f>", ":NvimTreeToggle<CR>", mode = { "n" } },
    },
    config = function()
      require("nvim-tree").setup {
        view = {
          width = 35,
        },
      }
    end,
  },
  {
    "someone-stole-my-name/yaml-companion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require("telescope").load_extension "yaml_schema"
      local cfg = require("yaml-companion").setup {
        -- detect k8s schemas based on file content
        builtin_matchers = {
          kubernetes = { enabled = true },
        },
        lspconfig = {
          settings = {
            yaml = {
              validate = true,
              format = { enable = false },
            },
          },
        },
      }
      require("lspconfig")["yamlls"].setup(cfg)
    end,
  },

  -- Database client
  {
    -- Official project is: kndndrj/nvim-dbee but currently errors on install
    "fbuchlak/nvim-dbee",
    branch = "fix/docs-remove-duplicate-tags",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    build = function()
      -- Install tries to automatically detect the install method.
      -- if it fails, try calling it with one of these parameters:
      --    "curl", "wget", "bitsadmin", "go"
      require("dbee").install()
    end,
    config = function()
      require("dbee").setup {
        sources = {
          require("dbee.sources").MemorySource:new {
            {
              name = "local_development",
              type = "postgres",
              url = "postgres://postgres:postgres@localhost:5432?sslmode=disable",
            },
            -- ...
          },
        },
      }

      -- Add `:Dbee` command to toggle opening the UI
      vim.api.nvim_create_user_command("Dbee", 'lua require("dbee").toggle()', {})
    end,
  },

}

-- Hacky way to get colours working across vim and tmux
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

vim.opt.encoding = "utf-8"
vim.opt.history = 1000
vim.opt.undolevels = 1000

-- Set colorscheme
vim.g.colors_name = "iceberg"
vim.opt.background = "light"

-- Use the system clipboard for easier copy+pasting
vim.opt.clipboard = "unnamedplus"

-- Show line numbers
vim.opt.number = true

-- Enable mouse in all modes
vim.opt.mouse = "a"

-- Only show the status bar when more than 1 tab exists
-- vim.opt.laststatus = 1

-- Make horizontal and vertical splitting feel better
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Auto update title with filename
vim.opt.title = true

-- Reload files if changed on disk
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, { command = "checktime" })

-- Search immediately after each character
vim.opt.incsearch = true

-- Highlight searches by default
vim.opt.hlsearch = true

-- Ignore case when searching unless the pattern contains an uppercase letter
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Default vim backspace is weird. It won't let you delete certain things while
-- in insert mode. This makes backspace work like typical editors.
-- This is the same as `set backspace=2`
vim.opt.backspace = {
  "indent",
  "eol",
  "start",
}

-- Show a vertical line at the text column dictated by the value 'textwidth'
vim.opt.colorcolumn = "+1"

-- Start scrolling when we're getting close to margins
vim.opt.scrolloff = 10
vim.opt.sidescrolloff = 15
vim.opt.sidescroll = 1

-- Disable wordwrap
vim.opt.wrap = false
vim.wo.wrap = false

-- Show whitespace
vim.opt.list = true
vim.opt.listchars = "tab:▸ ,trail:."

-- Use 4 Space characters for each indent
-- This will be overridden by any .editorconfig settings
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 0
vim.opt.expandtab = true
vim.opt.smarttab = true

-- Vim will wait a default of 4000 milliseconds after you stop typing
vim.opt.updatetime = 500

-- Hide the command/message box at the bottom when it's not being used
vim.opt.cmdheight = 0

-- Enable cursorline
vim.opt.cursorline = true

-- Show relative line numbers
vim.wo.relativenumber = true

-- EditorConfig is enabled by default, but just in case
vim.g.editorconfig = true

-- Support resizing in tmux
vim.cmd [[
if exists('$TMUX') && !has('nvim')
  set ttymouse=xterm2
endif
]]

-- Clear current search with //
vim.keymap.set("n", "//", ":nohlsearch <CR>")

-- Stay in visual mode when indenting
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- Prevents (P)aste from overwriting value in buffer. This is handy when pasting a
-- value to multiple locations.
vim.keymap.set("v", "p", '"_dP')
