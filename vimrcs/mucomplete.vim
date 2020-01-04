" MUcomplete

set complete=.,w,b,u,k
set completeopt=menu,popup,menuone,noselect

let g:mucomplete#enable_auto_at_startup = 1

let g:mucomplete#completion_delay = 50
let g:mucomplete#reopen_immediately = 0

let g:mucomplete#chains = {}
let g:mucomplete#chains.default = ['omni', 'c-n', 'path', 'tags', 'dict']

let s:cpp_cond = { t -> t =~# '\%(->\|::\|\.\)$' }
let s:rust_cond = { t -> t =~# '\%(::\|\.\)$' }

let g:mucomplete#can_complete = {}
let g:mucomplete#can_complete.cpp = { 'omni': s:cpp_cond }
let g:mucomplete#can_complete.rust = { 'omni': s:rust_cond }
