" Some random useful things

function! s:FilterQuickFixList(bang, pattern)
    let cmp = a:bang ? '!~#' : '=~#'
    if empty(a:pattern)
        if empty(expand("%"))
            let pat = expand("<cfile>")
        else
            let pat = expand("%")
        endif
    else
        let pat = a:pattern
    endif

    let filtered = filter(getqflist(), "bufname(v:val['bufnr']) " . cmp . " pat")

    if empty(filtered)
        echohl WarningMsg | echomsg "No results" | echohl None
    else
        call setqflist(filtered)
    endif
endfunction
command! -bang -nargs=? -complete=file QFilter call s:FilterQuickFixList(<bang>0, <q-args>)

function! s:SearchQuickFixList(bang, pattern)
    if empty(a:pattern)
        if !empty(getreg("/"))
            let pat = getreg("/")
        else
            echohl WarningMsg | echomsg "No Pattern!" | echohl None
            return
        endif
    else
        let pat = a:pattern
        call setreg("/", pat)
    endif

    " Simple 'smartcase' detection
    let cmp = pat ==# tolower(pat) ? (a:bang ? '!~?' : '=~?') : (a:bang ? '!~#' : '=~#')

    let filtered = filter(getqflist(), "v:val['text'] " . cmp . " pat")

    if empty(filtered)
        echohl WarningMsg | echomsg "No results for pattern: " . pat | echohl None
    else
        call setqflist(filtered)
    endif
endfunction
command! -bang -nargs=? -complete=file QSearch call s:SearchQuickFixList(<bang>0, <q-args>)
