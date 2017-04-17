" NOTE: DEFAULT LEADER KEY IS '\'

" -------------------
" ENABLE PLUGINS
" -------------------
" Setup Vundle package manager
call plug#begin('~/.vim/plugged')

"Colorschemes
Plug 'dracula/vim'
Plug 'fneu/breezy'
Plug 'raphamorim/lucario'

Plug 'tpope/vim-fugitive'             " Shows the git branch in airline and adds some features
Plug 'shougo/unite.vim'               " Dependency for Vimfiler
Plug 'shougo/vimfiler.vim'
Plug 'airblade/vim-gitgutter'         " Adds git diff icons to the gutter
Plug 'Valloric/YouCompleteMe'
Plug 'ternjs/tern_for_vim'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }   " fzf plugin for (fuzzy file finder)
Plug 'scrooloose/nerdcommenter'       " Enables code commenting
"Plug 'jiangmiao/auto-pairs'           " Auto completes quotations, brackets, parenthesis, etc
Plug 'easymotion/vim-easymotion'      " Apparently this helps with moving around in vim more *shrugs*

call plug#end()
filetype plugin indent on


" -----------------
" BASIC SETTINGS
" ----------------
try
colorscheme breezy                                             " Set the colour scheme
catch
endtry
set background=dark
syntax on
syntax enable
scriptencoding utf-8                                            " Need to set encoding for 'listchars' to work under windows env
set encoding=utf-8
set hidden                                                      " Hides buffers
set nocompatible                                                " Eliminate backwards-compatability
set number                                                      " Enable line numbers
set ruler                                                       " Turn on the ruler
set nolist                                                      " Disables $ at the end of lines on windows
set backspace=2                                                 " Fixes some backspace issues
set t_Co=256                                                    " 256-bit colours
set guifont=Inconsolata\ for\ Powerline:h14                     " Set font to work with airline
set mouse=a                                                     " Enables the ability to use mouse
set ignorecase                                                  " Ignore case when searching
set tabstop=4 softtabstop=0 expandtab shiftwidth=4 smarttab     " Use 4 Space characters for each indent
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
set lazyredraw
set ttyfast
set termguicolors


" Key map settings
nnoremap <leader>f :VimFiler<CR>
" Disable the arrow keys to force me to use HJKL
noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>
" Easy window navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
" Make Copypasta work under maxOS and Tmux
map <F1> :set paste<CR>:r !pbpaste<CR>:set nopaste<CR>
vmap <F2> :w !pbcopy<CR><CR>


" -------------------
" PLUGIN CONFIGURATION
" -------------------
" NeoComplete Configuration
let g:acp_enableAtStartup = 0
let g:neocomplete#enable_at_startup = 1
let g:neocomplete#enable_smart_case = 1
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"

" Vimfiler Configuration
let g:vimfiler_as_default_explorer = 1
call vimfiler#custom#profile('default', 'context', {'safe' : 0})    " disables safe mode so I can create files

" FZF Shortcut Configuration
nnoremap <leader>p :FZF<CR>

" Easymotion Configuration
map <Leader> <Plug>(easymotion-prefix)

" Start vim within my dev folder
cd /Users/anthony/Dev

" Disable gui options in gVim
set guioptions-=T  "remove toolbar
set guioptions-=m  "remove menu bar
