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

" Surround text objects
Plug 'tpope/vim-surround'

" Completion
Plug 'lifepillar/vim-mucomplete'

" Language server support
"Plug '~/Documents/Github/LanguageClient-neovim'
Plug 'autozimu/LanguageClient-neovim', {
	    \ 'branch': 'next',
	    \ 'do': 'bash install.sh'
	    \ }

" Language server highlighting
"Plug '~/Documents/Github/vim-lsp-cxx-highlight', {
Plug 'jackguo380/vim-lsp-cxx-highlight', {
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

" Python indentation
Plug 'vim-scripts/indentpython.vim'

" CMake Syntax and Indent
Plug 'Kitware/CMake', { 'rtp': 'Auxiliary/vim' }

" fzf integration with vim
Plug '~/.fzf'
Plug 'junegunn/fzf.vim'

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

" Edit gpg encrypted files
Plug 'jamessan/vim-gnupg'

" Run commands automatically
Plug 'skywind3000/asyncrun.vim'

" CMake complete
Plug 'richq/vim-cmake-completion'

" Autorun shellcheck
Plug 'itspriddle/vim-shellcheck'

call plug#end()

" Enable termdebug
packadd termdebug

au FileType rust let g:termdebugger = 'rust-gdb'
au FileType c,cpp let g:termdebugger = './gdb'

