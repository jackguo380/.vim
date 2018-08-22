filetype off

call plug#begin('~/.vim/bundle')
"set rtp+=~/.vim/bundle/Vundle.vim
"call vundle#begin()

" let Vundle manage Vundle, required
" Plug 'VundleVim/Vundle.vim' "Plugin Manager

if config_use_ycm
    "" Smart text/code completion, needs to be compiled
    "Plug 'Valloric/YouCompleteMe' 

    "" YCM config generator
    "Plug 'rdnetto/YCM-Generator'
endif

if config_use_color_coded
    " Better C++ highlighting, also needs to be compiled
    Plug 'jeaye/color_coded'
endif

" Vimscript only completion system
Plug 'prabirshrestha/asyncomplete.vim'

" Async helpers, used for asyncomplete, vim-lsp, ..
" Does nothing on its own
Plug 'prabirshrestha/async.vim'

" Language server support
Plug 'prabirshrestha/vim-lsp'

"if config_use_asyncomplete
   " Add language servers to asyncomplete
   Plug 'prabirshrestha/asyncomplete-lsp.vim'

   " File completions
   Plug 'prabirshrestha/asyncomplete-file.vim'

   Plug 'prabirshrestha/asyncomplete-buffer.vim'
"endif

if config_use_cquery
    " Language server extension for CQuery
    Plug 'pdavydov108/vim-lsp-cquery'
endif

" eldar color scheme
Plug 'agude/vim-eldar'

" file explorer
Plug 'scrooloose/nerdtree'

" Status Bar
Plug 'vim-airline/vim-airline'

" Status Bar Themes
Plug 'vim-airline/vim-airline-themes'

" x86 Highlighting
"Plug 'shirk/vim-gas'

" Git Integration
Plug 'tpope/vim-fugitive'

" Python folding
"Plug 'tmhedberg/SimpylFold'

" Python indentation
Plug 'vim-scripts/indentpython.vim'

" SystemVerilog Syntax and Coloring
Plug 'nachumk/systemverilog.vim'

" Verilog compilation
Plug 'vhda/verilog_systemverilog.vim'

" Fancy file search plugin
Plug 'kien/ctrlp.vim'

" Better C++ highlighting
Plug 'bfrg/vim-cpp-modern'

" Markdown Preview
Plug 'iamcco/markdown-preview.vim'

call plug#end()
"call vundle#end()

