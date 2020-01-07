" MUcomplete

set complete=.,w,b,u,k
set completeopt=menu,popup,menuone,noselect

let g:mucomplete#enable_auto_at_startup = 1

let g:mucomplete#completion_delay = 50
let g:mucomplete#reopen_immediately = 0

let g:mucomplete#chains = {}
let g:mucomplete#chains.default = ['omni', 'c-n', 'path', 'tags', 'dict']


let g:mucomplete#can_complete = {}

" For C Trigger on . and ->
let s:c_cond = { t -> t =~# '\%(->\|\.\)$' }
let g:mucomplete#can_complete.c = { 'omni': s:c_cond }

" For C++ Trigger on . and -> and ::
let s:cpp_cond = { t -> t =~# '\%(->\|::\|\.\)$' }
let g:mucomplete#can_complete.cpp = { 'omni': s:cpp_cond }

" For Rust Trigger on :: and .
let s:rust_cond = { t -> t =~# '\%(::\|\.\)$' }
let g:mucomplete#can_complete.rust = { 'omni': s:rust_cond }

" For Java Trigger on .
let s:java_cond = { t -> t =~# '\%(\.\)$' }
let g:mucomplete#can_complete.java = { 'omni': s:java_cond }
