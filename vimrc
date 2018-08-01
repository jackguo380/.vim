set nocompatible
set encoding=utf-8

if filereadable($HOME . "/.vim/.config.txt")
    let my_config = readfile($HOME . "/.vim/.config.txt")[0]
else
    let my_config = "all"
endif

source ~/.vim/vimrcs/vundle.vimrc

filetype plugin indent on

source ~/.vim/vimrcs/airline.vimrc
source ~/.vim/vimrcs/conque.vimrc
source ~/.vim/vimrcs/cscope-extra.vimrc
source ~/.vim/vimrcs/matchit.vimrc
source ~/.vim/vimrcs/vundle.vimrc
source ~/.vim/vimrcs/ycm.vimrc
source ~/.vim/vimrcs/gtags.vimrc

syntax on
set autoindent
set ts=4
set backspace=indent,eol,start "Backspace fix
set ignorecase
set smartcase
set hlsearch
set modelines=0
set wildmenu
set wildmode=longest:full
set nu "line numbers
" Use 4 spaces rather than tabs
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set smarttab

let c_space_errors=1

"use jj to escape insert mode
inoremap jj <Esc>

" Code folding with space bar
nnoremap <space> za

"Buffer KeyBind \l
nnoremap <leader>l :ls<CR>:b<space>

"File Browser Config
let g:netrw_banner = 0 "remove banner
"let g:netrw_browse_split = 2
let g:netrw_liststyle = 3 " Use the nice tree style listing

source ~/.vim/vimrcs/colorscheme.vimrc
