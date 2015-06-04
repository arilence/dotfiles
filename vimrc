" ------------------------------------------
" Guide from
" http://blog.tjll.net/yet-another-vim-setup/
" -------------------------------------------

" Basic settings
set hidden                                                      " Hides buffers
set nocompatible				               	" Eliminate backwards-compatability
set number					               	" Enable line numbers
set ruler					               	" Turn on the ruler
syntax on					               	" Syntax highlighting
set backspace=2				                       	" Fixes some backspace issues
set t_Co=256                                                    " 256-bit colours
set background=dark
colorscheme solarized                                          	" Set the colour scheme to codeschool
set guifont=Inconsolata\ for\ Powerline:h14                    	" Set font to work with airline
set mouse=a                                                    	" Enables the ability to use mouse
set ignorecase                                                 	" ignore case when searching
set tabstop=8 softtabstop=0 expandtab shiftwidth=4 smarttab     " use 4 Space characters for each indent
set nowrap
set list                                                        " show trailing whitespace
set listchars=tab:▸\ ,trail:.
set clipboard=unnamed

" Key map settings
nnoremap <leader>q :NERDTree<cr>
nnoremap <leader>d :NERDTreeToggle<CR>
nnoremap <leader>f :NERDTreeFind<CR>
" Disable the arrow keys to force me to use HJKL
"noremap <Up> <NOP>
"noremap <Down> <NOP>
"noremap <Left> <NOP>
"noremap <Right> <NOP>

" -------------------
" ENABLE SOME PLUGINS
" -------------------
" Setup Vundle package manager
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'bling/vim-airline'
Plugin 'kien/ctrlp.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'mattn/emmet-vim'
Plugin 'altercation/vim-colors-solarized'
Plugin 'wakatime/vim-wakatime'

call vundle#end()
filetype plugin indent on

" Vim-airline configuration
set laststatus=2
let g:airline_theme             = 'powerlineish'
let g:airline_enable_branch     = 1
let g:airline_powerline_fonts   = 1
if !exists('g:airline_symbols')
	let g:airline_symbols = {}
endif
let g:airline_symbols.space = "\ua0"
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#show_buffers = 0

" CTRL -P configuration
set runtimepath ^=~/.vim/bundle/ctrlp.vim
let g:ctrlp_working_path_mode = 'ra'
set wildignore+=*/tmp/*,*.so,*.swp,*.zip     " MacOSX/Linux
set wildignore+=*\\tmp\\*,*.swp,*.zip,*.exe  " Windows

" NERDTree Configuration:
set autochdir
let NERDTreeChDirMode=2

" Emmet Configuration
let g:user_emmet_leader_key='<leader>w'

