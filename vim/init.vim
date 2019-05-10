" NOTE: DEFAULT LEADER KEY IS '\'

" -------------------
" ENABLE PLUGINS
" -------------------
" Setup Vundle package manager
call plug#begin('~/.vim/plugged')

" Colorschemes
Plug 'rakr/vim-one'
Plug 'vivkin/flatland.vim'
Plug 'rainglow/vim'
Plug 'arcticicestudio/nord-vim'

" Functional plugins
Plug 'mhinz/vim-signify'
Plug 'editorconfig/editorconfig-vim'
Plug 'christoomey/vim-tmux-navigator'       " Smart pane switching with vim and tmux
Plug 'tmux-plugins/vim-tmux-focus-events'   " Makes focus events work in tmux so vim can auto refresh file
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'terryma/vim-multiple-cursors'

if has('nvim')
  Plug 'Shougo/defx.nvim', { 'do': ':UpdateRemotePlugins' }
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
else
  Plug 'Shougo/defx.nvim'
  Plug 'Shougo/deoplete.nvim'
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'
endif

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
colorscheme nord
set background=dark
catch
endtry

set nocompatible
syntax on
syntax enable
scriptencoding utf-8                           " Need to set encoding for 'listchars' to work under windows env

let $LANG='en'                                 " Avoid random characters in other languges on windows
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

" Disable gui options in gVim
set guioptions-=T  "remove toolbar
set guioptions-=m  "remove menu bar

" Deoplete config
let g:deoplete#enable_at_startup = 1
inoremap <expr><C-j> pumvisible()? "\<C-n>" : "\<C-j>"
inoremap <expr><C-k> pumvisible()? "\<C-p>" : "\<C-k>"
inoremap <silent><expr> <TAB>
  \ pumvisible() ? "\<C-n>" :
  \ <SID>check_back_space() ? "\<TAB>" :
  \ deoplete#mappings#manual_complete()
function! s:check_back_space() abort "{{{
let col = col('.') - 1
return !col || getline('.')[col - 1]  =~ '\s'
endfunction"}}}

" Fixes bug when using multiple cursors and deoplete auto complete
function g:Multiple_cursors_before()
  call deoplete#custom#buffer_option('auto_complete', v:false)
endfunction
function g:Multiple_cursors_after()
  call deoplete#custom#buffer_option('auto_complete', v:true)
endfunction


" -------------------
" CUSTOM KEYMAPPING
" -------------------
" Disable use of arrow keys while in normal mode
" I did this to force myself to learn better
" vim locomotion.
noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Plugin Keymaps
nnoremap <leader>f :Defx<CR>
nnoremap <C-p> :Files<CR>

" Default Key Mappings for Defx
autocmd FileType defx call s:defx_my_settings()
function! s:defx_my_settings() abort
  " Define mappings
  nnoremap <silent><buffer><expr> <Enter>
  \ defx#do_action('open')
  nnoremap <silent><buffer><expr> c
  \ defx#do_action('copy')
  nnoremap <silent><buffer><expr> m
  \ defx#do_action('move')
  nnoremap <silent><buffer><expr> p
  \ defx#do_action('paste')
  nnoremap <silent><buffer><expr> h
  \ defx#do_action('cd', ['..'])
  nnoremap <silent><buffer><expr> <BS>
  \ defx#do_action('cd', ['..'])
  nnoremap <silent><buffer><expr> l
  \ defx#do_action('open')
  nnoremap <silent><buffer><expr> E
  \ defx#do_action('open', 'vsplit')
  nnoremap <silent><buffer><expr> P
  \ defx#do_action('open', 'pedit')
  nnoremap <silent><buffer><expr> K
  \ defx#do_action('new_directory')
  nnoremap <silent><buffer><expr> N
  \ defx#do_action('new_file')
  nnoremap <silent><buffer><expr> M
  \ defx#do_action('new_multiple_files')
  nnoremap <silent><buffer><expr> d
  \ defx#do_action('remove')
  nnoremap <silent><buffer><expr> r
  \ defx#do_action('rename')
  nnoremap <silent><buffer><expr> !
  \ defx#do_action('execute_command')
  nnoremap <silent><buffer><expr> yy
  \ defx#do_action('yank_path')
  nnoremap <silent><buffer><expr> .
  \ defx#do_action('toggle_ignored_files')
  nnoremap <silent><buffer><expr> ;
  \ defx#do_action('repeat')
  nnoremap <silent><buffer><expr> q
  \ defx#do_action('quit')
  nnoremap <silent><buffer><expr> j
  \ line('.') == line('$') ? 'gg' : 'j'
  nnoremap <silent><buffer><expr> k
  \ line('.') == 1 ? 'G' : 'k'
endfunction
