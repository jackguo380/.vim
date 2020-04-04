set nocompatible
set encoding=utf-8

if has('win32') || has ('win64')
    let g:my_vim_directory = $HOME."/vimfiles"
else
    let g:my_vim_directory = $HOME."/.vim"
endif

runtime vimrcs/start.vim
runtime vimrcs/plugins.vim

filetype plugin indent on
syntax on
let mapleader = ","

runtime vimrcs/mucomplete.vim
runtime vimrcs/airline.vim
runtime vimrcs/fzf.vim
runtime vimrcs/language_servers.vim
runtime vimrcs/misc_helpers.vim
runtime vimrcs/nerdtree.vim
runtime vimrcs/asyncrun.vim
runtime vimrcs/markdownpreview.vim

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
set ts=4
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set smarttab

" Enable histogram diff
if has('nvim-0.3.2') || has("patch-8.1.0360")
    set diffopt=filler,internal,algorithm:histogram,indent-heuristic
endif

let c_space_errors=1

"use jj to escape insert mode
inoremap jj <Esc>

" Code folding with space bar
nnoremap <space> za

"Buffer KeyBind \l
nnoremap <leader>l :ls<CR>:b<space>

" History registers
nnoremap <leader>rh :reg 0 1 2 3 4 5 6 7 8 9<CR>

" Paste in visual mode without yanking with P
xnoremap <expr> P '"_d"'.v:register.'P'

runtime vimrcs/colorscheme.vim

