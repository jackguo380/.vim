" nerdtree config
let NERDTreeShowHidden=1
let NERDTreeQuitOnOpen=1

let NERDTreeIgnore=['\~$', '\.d$', '\.o$', '\.out$', '\.gcda$', '\.gcno$']

nmap <leader>no :NERDTreeToggle<CR>
nmap <leader>nf :NERDTreeFocus<CR>
nmap <leader>ng :NERDTree %<CR>
nmap <leader>nb :NERDTreeFind %<CR>
nmap <leader>nc :NERDTreeCWD<CR>
