
"nmap cslg :lvimgrep /^\i\+\s\+\(\i\+::\)\?\<<C-R>=expand("<cword>")<CR>\>([^)]*)\?/j <C-R>=expand("%")<CR><CR>:lopen<CR>
"nmap cslc :lvimgrep /\<<C-R>=expand("<cword>")<CR>\>([^)]*)\?/j <C-R>=expand("%")<CR><CR>:lopen<CR>
"nmap csls :lvimgrep /\<<C-R>=expand("<cword>")<CR>\>/j <C-R>=expand("%")<CR><CR>:lopen<CR>
