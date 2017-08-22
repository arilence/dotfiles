" NOTE: DEFAULT LEADER KEY IS '\'

" -------------------
" ENABLE PLUGINS
" -------------------
" Setup Vundle package manager
call plug#begin('~/.vim/plugged')

" Colorschemes
Plug 'morhetz/gruvbox'
Plug 'fneu/breezy'

" Functional plugins
Plug 'airblade/vim-gitgutter'         " Adds git diff icons to the gutter
Plug 'alvan/vim-closetag'
Plug 'editorconfig/editorconfig-vim'
Plug 'jiangmiao/auto-pairs'
Plug 'shougo/unite.vim'               " Dependency for Vimfiler
Plug 'shougo/vimfiler.vim'

call plug#end()
filetype plugin indent on


" -----------------
" BASIC SETTINGS
" ----------------
" Only apply the colorscheme if it's available
try
colorscheme gruvbox
catch
endtry

set background=dark
set nocompatible                                                " Eliminate backwards-compatability
syntax on
syntax enable
scriptencoding utf-8                                            " Need to set encoding for 'listchars' to work under windows env

set autoread                                                    " Automatically reload files when they're changed on disk
set backspace=2                                                 " Fixes some backspace issues
set clipboard=unnamed                                           " Enables use of system clipboard
set encoding=utf-8
set hidden                                                      " Hides buffers
set history=1000                                                " Remember more commands and search history
set ignorecase                                                  " Ignore case when searching
set incsearch
set lazyredraw
set list                                                        " Show trailing whitespace
set listchars=tab:▸\ ,trail:.
set nolist                                                      " Disables $ at the end of lines on windows
set nowrap
set number                                                      " Enable line numbers
set ruler                                                       " Turn on the ruler
set scrolloff=3
set smartcase                                                   " Case-insensitive search if any caps
set t_Co=256                                                    " 256-bit colours
set tabstop=4 softtabstop=0 expandtab shiftwidth=4 smarttab     " Use 4 Space characters for each indent
set termguicolors
set title
set ttyfast
set undolevels=1000                                             " Remembers many levels of undo
set wildignore+=*.swp,*.bak,*.pyc,*.class
set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.idea/*,*/.DS_Store,*/vendor
set wildmenu
set wildmode=longest,list,full

" Enables the ability to use mouse
set mouse=a

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
