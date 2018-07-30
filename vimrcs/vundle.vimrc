" Vundle package manager: Need to install it manually for this to work
" set the runtime path to include Vundle and initialize

filetype off                  " required

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim' "Plugin Manager

" Smart text/code completion, needs to be compiled
Plugin 'Valloric/YouCompleteMe' 

" eldar color scheme
Plugin 'agude/vim-eldar'

"gdb integration for vim
"Plugin 'vim-scripts/Conque-GDB'

" Status Bar
Plugin 'vim-airline/vim-airline'
" Status Bar Themes
Plugin 'vim-airline/vim-airline-themes'

" x86 Highlighting
"Plugin 'shirk/vim-gas'

" Git Integration
Plugin 'tpope/vim-fugitive'

" Python folding
"Plugin 'tmhedberg/SimpylFold'

" Python indentation
Plugin 'vim-scripts/indentpython.vim'

" Alternate cscope plugin, not that good though
"Plugin 'brookhong/cscope.vim'

" SystemVerilog Syntax and Coloring
Plugin 'nachumk/systemverilog.vim'

" Better C++ highlighting
Plugin 'jeaye/color_coded'

" YCM config generator
Plugin 'rdnetto/YCM-Generator'

" Verilog compilation
Plugin 'vhda/verilog_systemverilog.vim'

" Fancy file search plugin
Plugin 'kien/ctrlp.vim'

" Better cmake syntax
Plugin 'pboettch/vim-cmake-syntax'

" Auto Update Tags
"Plugin 'ludovicchabant/vim-gutentags'

" Auto Update Gtags
"Plugin 'skywind3000/gutentags_plus'

call vundle#end()
" -- End of Vundle configuration --

