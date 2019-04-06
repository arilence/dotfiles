" ----------------------------
" Enable plugins
" ----------------------------

call plug#begin('~/.local/share/nvim/plugged')

" Functional plugins
Plug 'shougo/unite.vim'
Plug 'shougo/vimfiler.vim'
Plug 'christoomey/vim-tmux-navigator'
Plug 'tmux-plugins/vim-tmux-focus-events'

call plug#end()
filetype plugin indent on

" ----------------------------
"  Breaking bad habits
" ----------------------------

" Unmap arrow keys
noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>

" Unmap h and l to force word-wise motion
noremap h <NOP>
noremap l <NOP>
