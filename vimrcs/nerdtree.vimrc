" nerdtree config
let NERDTreeShowHidden=1
let NERDTreeQuitOnOpen=1

let NERDTreeIgnore=['\~$', '\.d$', '\.o$', '\.out$', '\.gcda$', '\.gcno$']

nmap <leader>no :NERDTreeToggle<CR>
nmap <leader>nf :NERDTreeFocus<CR>
nmap <leader>nb :NERDTree <C-R>=expand("%")<CR><CR>
nmap <leader>nc :NERDTreeCWD<CR>

" Open automatically if vim starts up with no files
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
