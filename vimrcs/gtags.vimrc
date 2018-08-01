let GtagsCscope_Auto_Load = 1
let GtagsCscope_Auto_Map = 1
let GtagsCscope_Quiet = 1
let Gtags_No_Auto_Jump = 1
let Gtags_Auto_Update = 1
set cscopetag

nmap csgs :Gtags -s <C-R>=expand("<cword>")<CR><CR>	
nmap csgg :Gtags -d <C-R>=expand("<cword>")<CR><CR>	
nmap csgc :Gtags -r <C-R>=expand("<cword>")<CR><CR>	

function! s:FilterQuickFixList(bang, pattern)
  let cmp = a:bang ? '!~#' : '=~#'
  call setqflist(filter(getqflist(), "bufname(v:val['bufnr']) " . cmp . " a:pattern"))
endfunction
command! -bang -nargs=1 -complete=file QFilter call s:FilterQuickFixList(<bang>0, <q-args>)

function! s:GtagsCurBuf(search, pattern)
    let file = expand("%")

    execute "Gtags " . a:search . " " . a:pattern
    execute "QFilter " . l:file

    if len(getqflist()) == 1 && a:search == "-d"
        execute ":cc"
        execute ":cclose"
    endif
endfunction
command! -nargs=+ GtagsCurrentBuffer call s:GtagsCurBuf(<f-args>)

nmap csls :GtagsCurrentBuffer -s <C-R>=expand("<cword>")<CR><CR>
nmap cslg :GtagsCurrentBuffer -d <C-R>=expand("<cword>")<CR><CR>
nmap cslc :GtagsCurrentBuffer -r <C-R>=expand("<cword>")<CR><CR>

nmap csll :QFilter <C-R>=expand("#")<CR><CR>
