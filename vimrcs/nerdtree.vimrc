" nerdtree config

nmap <leader>e :NERDTree<CR>

" Open automatically if vim starts up with no files
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
