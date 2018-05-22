" NOTE: DEFAULT LEADER KEY IS '\'

" -------------------
" ENABLE PLUGINS
" -------------------
" Setup Vundle package manager
call plug#begin('~/.vim/plugged')

" Colorschemes
Plug 'morhetz/gruvbox'
Plug 'cocopon/iceberg.vim'
Plug 'rakr/vim-one'
Plug 'thenewvu/vim-colors-sketching'
Plug 'lifepillar/vim-solarized8'
Plug 'vivkin/flatland.vim'

" Functional plugins
Plug 'airblade/vim-gitgutter'               " Adds git diff icons to the gutter
Plug 'alvan/vim-closetag'
Plug 'editorconfig/editorconfig-vim'        " Adds consistent coding styles on a per project basis
Plug 'jiangmiao/auto-pairs'
Plug 'shougo/unite.vim'                     " Dependency for Vimfiler
Plug 'shougo/vimfiler.vim'
Plug 'christoomey/vim-tmux-navigator'       " Smart pane switching with vim and tmux
Plug 'tmux-plugins/vim-tmux-focus-events'   " Makes focus events work in tmux so vim can auto refresh file
Plug 'cloudhead/neovim-fuzzy'               " Companion plugin for Fzy - fuzzy file searching

call plug#end()
filetype plugin indent on


" -----------------
" BASIC SETTINGS
" ----------------
" Credit joshdick
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

" Only apply the colorscheme if it's available
try
colorscheme flatland 
set background=dark
catch
endtry

set nocompatible
syntax on
syntax enable
scriptencoding utf-8                           " Need to set encoding for 'listchars' to work under windows env

set autoread                                   " Automatically reload files when they're changed on disk
set backspace=2                                " Fixes some backspace issues
set clipboard=unnamed                          " Enables use of system clipboard
set encoding=utf-8
set hidden                                     " Hides buffers
set history=1000                               " Remember more commands and search history
set ignorecase                                 " Ignore case when searching
set incsearch                                  " Search immediately after each character press
set list                                       " Show trailing whitespace
set listchars=tab:▸\ ,trail:.
set nolist                                     " Disables $ at the end of lines on windows
set nowrap
set number                                     " Enable line numbers
set ruler                                      " Turn on the ruler
set rulerformat=%l,%c%V%=%P                    " Simplifies ruler format [Line number, Column number]
set scrolloff=3
set smartcase                                  " Case-insensitive search if any caps
set t_Co=256                                   " 256-bit colours
set title                                      " Auto update title with file name
set ttyfast                                    " Smoother changes.. apparently?
set undolevels=1000                            " Remembers many levels of undo
set wildignore+=*.swp,*.bak,*.pyc,*.class
set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.idea/*,*/.DS_Store,*/vendor
set wildmenu
set wildmode=longest,list,full

" Use 4 Space characters for each indent
" This will be overridden by any .editorconfig settings
set tabstop=4 
set shiftwidth=4
set softtabstop=0
set expandtab
set smarttab

" Enables the ability to use mouse
set mouse=a

" Make new split panes appear more naturally
set splitbelow
set splitright

" Support resizing in tmux
if exists('$TMUX') && !has('nvim')
    set ttymouse=xterm2
endif

" Keyboard shortcuts
nnoremap <leader>f :VimFiler<CR>
noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l


" -------------------
" PLUGIN CONFIGURATION
" -------------------
" Vimfiler Configuration
let g:vimfiler_as_default_explorer = 1
call vimfiler#custom#profile('default', 'context', {'safe' : 0})    " disables safe mode so I can create files

" Disable gui options in gVim
set guioptions-=T  "remove toolbar
set guioptions-=m  "remove menu bar

" Configure vim-closetag
let g:closetag_filenames = '*.html,*.xhtml,*.phtml,*.js'

" Configure neovim-fuzzy
nnoremap <C-p> :FuzzyOpen<CR>
