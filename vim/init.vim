" NOTE: DEFAULT LEADER KEY IS '\'

" -------------------
" ENABLE PLUGINS
" -------------------
" Setup Vundle package manager
call plug#begin('~/.vim/plugged')

Plug 'Valloric/YouCompleteMe'
Plug 'bling/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'tpope/vim-fugitive'             " Shows the git branch in airline and adds some features
Plug 'scrooloose/nerdtree'
Plug 'Shougo/neocomplete.vim'         " Auto completion plugin that doesn't crash in sudo :)
Plug 'kien/ctrlp.vim'
Plug 'airblade/vim-gitgutter'         " Adds git diff icons to the gutter

" Colourschemes
Plug 'juanedi/predawn.vim'
Plug 'raphamorim/lucario'

call plug#end()
filetype plugin indent on


" -----------------
" BASIC SETTINGS
" ----------------
colorscheme lucario                                             " Set the colour scheme
set background=dark
syntax enable
set hidden                                                      " Hides buffers
set nocompatible                                                " Eliminate backwards-compatability
set number                                                      " Enable line numbers
set ruler                                                       " Turn on the ruler
set backspace=2                                                 " Fixes some backspace issues
set t_Co=256                                                    " 256-bit colours
set guifont=Inconsolata\ for\ Powerline:h14                     " Set font to work with airline
set mouse=a                                                     " Enables the ability to use mouse
set ignorecase                                                  " Ignore case when searching
set tabstop=4 softtabstop=0 expandtab shiftwidth=2 smarttab     " Use 4 Space characters for each indent
set nowrap
set list                                                        " Show trailing whitespace
set listchars=tab:▸\ ,trail:.
set clipboard=unnamed                                           " Enables use of system clipboard
set history=1000                                                " Remember more commands and search history
set undolevels=1000                                             " Remembers many levels of undo
set wildignore+=*.swp,*.bak,*.pyc,*.class
set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.idea/*,*/.DS_Store,*/vendor
set title
set incsearch

" Key map settings
nnoremap <leader>q :NERDTree<CR>
nnoremap <leader>d :NERDTreeToggle<CR>
nnoremap <leader>f :NERDTreeFind<CR>
" Disable the arrow keys to force me to use HJKL
noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>
" Easy window navigation
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l
" Make Copypasta work under maxOS and Tmux
map <F1> :set paste<CR>:r !pbpaste<CR>:set nopaste<CR>
vmap <F2> :w !pbcopy<CR><CR>


" -------------------
" PLUGIN CONFIGURATION
" -------------------
" Vim-airline configuration
set laststatus=2
let g:airline_theme             = 'powerlineish'
let g:airline_powerline_fonts   = 1
if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif
let g:airline_symbols.space = "\ua0"
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#show_buffers = 0

" NERDTree Configuration
let NERDTreeChDirMode=2

" ctrl-p Configuration
let g:ctrlp_custom_ignore = 'node_modules\|DS_Store\|git'
let g:ctrlp_show_hidden = 1
let g:ctrlp_working_path_mode = 'ra'

" NeoComplete Configuration
let g:acp_enableAtStartup = 0
let g:neocomplete#enable_at_startup = 1
let g:neocomplete#enable_smart_case = 1
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"

