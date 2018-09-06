" nerdtree config

nmap <leader>no :NERDTreeToggle<CR>
nmap <leader>nf :NERDTreeFocus<CR>

" Open automatically if vim starts up with no files
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
