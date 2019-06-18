call plug#begin($VIMHOME . '/bundle')

Plug 'junegunn/vim-plug'

" Auto spacing
Plug 'tpope/vim-sleuth'

" Various useful configurations
Plug 'tpope/vim-sensible'

if config_use_ycm
    " Smart text/code completion, needs to be compiled
    Plug 'Valloric/YouCompleteMe' 

    " YCM config generator
    "Plug 'rdnetto/YCM-Generator'
endif

if config_use_color_coded
    " Better C++ highlighting, also needs to be compiled
    "Plug 'jeaye/color_coded'
endif

" Async helpers, used for asyncomplete, vim-lsp, ..
" Does nothing on its own
"Plug 'prabirshrestha/async.vim'

" Language server support
"Plug 'prabirshrestha/vim-lsp'

Plug 'autozimu/LanguageClient-neovim', { 'branch': 'next', 'do': 'bash install.sh' }

"if has('nvim')
"    Plug 'Shougo/deoplete.nvim', {'do': ':UpdateRemotePlugins'}
"else
"    Plug 'Shougo/deoplete.nvim'
"    Plug 'roxma/nvim-yarp'
"    Plug 'roxma/vim-hug-neovim-rpc'
"endif

if config_use_asyncomplete
    " Vimscript only completion system
    Plug 'prabirshrestha/asyncomplete.vim'

    " Add language servers to asyncomplete
    Plug 'prabirshrestha/asyncomplete-lsp.vim'

    " File completions
    Plug 'prabirshrestha/asyncomplete-file.vim'

    " Words in Buffer
    Plug 'prabirshrestha/asyncomplete-buffer.vim'

    " Vimscript
    Plug 'Shougo/neco-vim'
    Plug 'prabirshrestha/asyncomplete-necovim.vim'
endif

if config_use_cquery
    " Language server extension for CQuery
    " Plug 'pdavydov108/vim-lsp-cquery'
    Plug 'jackguo380/vim-lsp-cquery', { 'branch': 'ccls' }
endif

" Language server highlighting
Plug 'jackguo380/vim-lsp-cxx-highlight'

" Rust colors, indent, etc.
Plug 'rust-lang/rust.vim'

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

" Mercurial Integration
Plug 'jlfwong/vim-mercenary'

" Python folding
"Plug 'tmhedberg/SimpylFold'

" Python indentation
Plug 'vim-scripts/indentpython.vim'

" SystemVerilog Syntax and Coloring
Plug 'nachumk/systemverilog.vim'

" Verilog compilation
Plug 'vhda/verilog_systemverilog.vim'

" Fancy file search plugin
"Plug 'kien/ctrlp.vim'

" fzf command line fuzzy finder
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }

" fzf integration with vim
Plug 'junegunn/fzf.vim'

" C++ Keywords
Plug 'bfrg/vim-cpp-modern'

" Markdown Preview
Plug 'iamcco/markdown-preview.vim'

" CSV files
Plug 'chrisbra/csv.vim'

" MIB files
Plug 'sedan07/vim-mib'

" HTML tag matching
Plug 'Valloric/MatchTagAlways'

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

" Enable termdebug
packadd termdebug

au FileType rust let b:termdebugger = 'rust-gdb'
au FileType c,cpp let b:termdebugger = 'gdb'

