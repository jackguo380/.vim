set nocompatible
set encoding=utf-8

if has('win32') || has ('win64')
    let $VIMHOME = $VIM."/vimfiles"
else
    let $VIMHOME = $HOME."/.vim"
endif

source $VIMHOME/vimrcs/start.vimrc
source $VIMHOME/vimrcs/plugins.vimrc

filetype plugin indent on
syntax on
let mapleader = ","

source $VIMHOME/vimrcs/airline.vimrc
source $VIMHOME/vimrcs/cscope-extra.vimrc
source $VIMHOME/vimrcs/ycm.vimrc
source $VIMHOME/vimrcs/gtags.vimrc
source $VIMHOME/vimrcs/regexhelpers.vimrc
source $VIMHOME/vimrcs/ctrlp.vimrc
source $VIMHOME/vimrcs/language_servers.vimrc
source $VIMHOME/vimrcs/asyncomplete.vimrc
source $VIMHOME/vimrcs/misc_helpers.vimrc

" TODO: remove commented out settings after testing sensible.vim
"set autoindent
" Backspace fix
"set backspace=indent,eol,start
" Search case sensitivity
set smartcase
" Highlight search items
set hlsearch
" Better completion in command mode
"set wildmenu
set wildmode=longest:full
" Line numbers
set nu
" Use 4 spaces rather than tabs
" These settings only take effect if sleuth fails to detect
set ts=4
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

" Allow .vimrc files in other folders as a local configuration
set exrc secure
