set nocompatible
set encoding=utf-8

if has('win32') || has ('win64')
    let $VIMHOME = $VIM."/vimfiles"
else
    let $VIMHOME = $HOME."/.vim"
endif

if filereadable($VIMHOME . "/.config.txt")
    let my_config = readfile($VIMHOME . "/.config.txt")[0]

    if ! ( my_config ==# "ycm" || my_config ==# "nocompile" || my_config ==# "asyncomplete" )
        echoerr "Bad Vimrc Configuration: " . my_config
        let my_config = "nocompile"
    endif
else
    echoerr "No Vimrc Configuration Found!"
    let my_config = "nocompile"
endif

if my_config ==# "ycm"
    let config_use_ycm = 1
    let config_use_color_coded = 1
    let config_use_asyncomplete = 0
    let config_use_cquery = 1
elseif my_config ==# "nocompile"
    let config_use_ycm = 0
    let config_use_color_coded = 0
    let config_use_asyncomplete = 0
    let config_use_cquery = 0
elseif my_config ==# "asyncomplete"
    let config_use_ycm = 0
    let config_use_color_coded = 1
    let config_use_asyncomplete = 1
    let config_use_cquery = 1
endif

source ~/.vim/vimrcs/plugins.vimrc

filetype plugin indent on
syntax on

source ~/.vim/vimrcs/airline.vimrc
source ~/.vim/vimrcs/cscope-extra.vimrc
source ~/.vim/vimrcs/ycm.vimrc
source ~/.vim/vimrcs/gtags.vimrc
source ~/.vim/vimrcs/regexhelpers.vimrc
source ~/.vim/vimrcs/ctrlp.vimrc
source ~/.vim/vimrcs/language_servers.vimrc
source ~/.vim/vimrcs/asyncomplete.vimrc
source ~/.vim/vimrcs/misc_helpers.vimrc

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

let mapleader = ","

"Buffer KeyBind \l
nnoremap <leader>l :ls<CR>:b<space>

"File Browser Config
let g:netrw_banner = 0 "remove banner
"let g:netrw_browse_split = 2
let g:netrw_liststyle = 3 " Use the nice tree style listing

source ~/.vim/vimrcs/colorscheme.vimrc

" Allow .vimrc files in other folders as a local configuration
set exrc secure
