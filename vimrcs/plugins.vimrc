call plug#begin('~/.vim/bundle')

Plug 'junegunn/vim-plug'

" Various useful configurations
Plug 'tpope/vim-sensible'

if config_use_ycm
    " Smart text/code completion, needs to be compiled
    Plug 'Valloric/YouCompleteMe' 

    " YCM config generator
    Plug 'rdnetto/YCM-Generator'
endif

if config_use_color_coded
    " Better C++ highlighting, also needs to be compiled
    Plug 'jeaye/color_coded'
endif

" Async helpers, used for asyncomplete, vim-lsp, ..
" Does nothing on its own
Plug 'prabirshrestha/async.vim'

" Language server support
Plug 'prabirshrestha/vim-lsp'

if config_use_asyncomplete
    " Vimscript only completion system
    Plug 'prabirshrestha/asyncomplete.vim'

    " Add language servers to asyncomplete
    Plug 'prabirshrestha/asyncomplete-lsp.vim'

    " File completions
    Plug 'prabirshrestha/asyncomplete-file.vim'

    " Words in Buffer
    Plug 'prabirshrestha/asyncomplete-buffer.vim'
endif

if config_use_cquery
    " Language server extension for CQuery
    Plug 'pdavydov108/vim-lsp-cquery'
endif

" eldar color scheme
Plug 'agude/vim-eldar'

" file explorer
Plug 'scrooloose/nerdtree'

" automatic tab width
Plug 'tpope/vim-sleuth'

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

" Some extra non-github plugins
function! s:curl_plugin(name, url)
    let curl_opts = "--create-dirs -fLo"
    let full_name = $VIMHOME . '/' . substitute(substitute(a:name, "['\"]$", "", ""), "^[\"']", "", "")

    if ! filereadable(full_name)
	exe "!echo CurlPlug: Downloading: " . a:name
	exe "!curl" curl_opts full_name a:url 
	exe "!echo CurlPlug: Done Downloading: " . a:name
    endif
endfunction
command -nargs=+ CurlPlug silent call s:curl_plugin(<f-args>)

" Set wildignore from gitignore
"CurlPlug 'plugin/gitignore.vim' 'https://www.vim.org/scripts/download_script.php?src_id=25252'

" CMake syntax
CurlPlug "syntax/cmake.vim" 'https://raw.githubusercontent.com/Kitware/CMake/master/Auxiliary/vim/syntax/cmake.vim'

" CMake indent
CurlPlug 'indent/cmake.vim' 'https://raw.githubusercontent.com/Kitware/CMake/master/Auxiliary/vim/indent/cmake.vim'

