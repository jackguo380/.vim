" Some extra non-github plugins
function! s:curl_plugin(name, url)
    let curl_opts = "--create-dirs -fLo"
    let full_name = g:my_vim_directory . '/'
		\ . substitute(
		\ substitute(a:name, "['\"]$", "", ""),
		\ "^[\"']", "", "")

    if ! filereadable(full_name)
	exe "!echo CurlPlug: Downloading: " . a:name
	exe "!curl" curl_opts full_name a:url 
	exe "!echo CurlPlug: Done Downloading: " . a:name
    endif
endfunction
command -nargs=+ CurlPlug silent call s:curl_plugin(<f-args>)

CurlPlug "autoload/plug.vim" 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

call plug#begin(g:my_vim_directory . '/bundle')

Plug 'junegunn/vim-plug'

" Auto spacing
Plug 'tpope/vim-sleuth'

" Various useful configurations
Plug 'tpope/vim-sensible'

" Smart text/code completion, needs to be compiled
Plug 'Valloric/YouCompleteMe' 

" Language server support
Plug 'autozimu/LanguageClient-neovim', {
	    \ 'branch': 'next',
	    \ 'do': 'bash install.sh'
	    \ }

" Language server highlighting
"Plug '~/Documents/Github/vim-lsp-cxx-highlight', {
Plug 'jackguo380/vim-lsp-cxx-highlight', {
	    \ 'for': ['c', 'cpp']
	    \ }

" C++ Keywords
Plug 'bfrg/vim-cpp-modern', {
	    \ 'for': ['c', 'cpp']
	    \ }

" Rust colors, indent, etc.
Plug 'rust-lang/rust.vim', {
	    \ 'for': ['rust']
	    \ }

" eldar color scheme
Plug 'agude/vim-eldar'

" file explorer
Plug 'scrooloose/nerdtree'

" Status Bar
Plug 'vim-airline/vim-airline'

" Git Integration
Plug 'tpope/vim-fugitive'

" Mercurial Integration
Plug 'jlfwong/vim-mercenary'

" Python indentation
Plug 'vim-scripts/indentpython.vim'

" SystemVerilog Syntax and Coloring
Plug 'nachumk/systemverilog.vim'

" Verilog compilation
Plug 'vhda/verilog_systemverilog.vim', {
	    \ 'for': ['systemverilog']
	    \ }

" fzf integration with vim
Plug '~/.fzf'
Plug 'junegunn/fzf.vim'

" Markdown Preview
Plug 'iamcco/markdown-preview.vim', {
	    \ 'for': ['markdown']
	    \ }

" CSV files
Plug 'chrisbra/csv.vim', {
	    \ 'for': ['csv']
	    \ }

" Dockerfile
Plug 'ekalinin/Dockerfile.vim', {
	    \ 'for': ['Dockerfile']
	    \ }

" HTML tag matching
Plug 'Valloric/MatchTagAlways', {
	    \ 'for': ['html', 'xml']
	    \ }

" LaTeX
Plug 'lervag/vimtex', {
	    \ 'for': ['tex']
	    \ }

" arm asm syntax
Plug 'ARM9/arm-syntax-vim'

" Edit gpg encrypted files
Plug 'jamessan/vim-gnupg'

call plug#end()

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

