" Some random useful things

" Filter the Quickfix list by the file of the entry
" if no explicit file is given it takes the current focused buffer's name
" or if its a nameless buffer (like quickfix) it takes the file under the cursor
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
    let title = "QFilter " . pat

    if empty(filtered)
        " Try case insensitive if case sensitive returned no results
        let cmp = a:bang ? '!~?' : '=~?'
        let filtered = filter(getqflist(), "bufname(v:val['bufnr']) " . cmp . " pat")
        let title = "QFilter " . pat . " (Case Insensitive)"

        if empty(filtered)
            echohl WarningMsg | echomsg "No results" | echohl None
            return
        endif
    endif

    call setqflist(filtered)
    copen
    let w:quickfix_title = title
endfunction
command! -bang -nargs=? -complete=file QFilter call s:FilterQuickFixList(<bang>0, <q-args>)

" Filter the quickfix list by matching the entry text with a search pattern
" if no pattern is given it uses the last search pattern
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
        return
    endif

    call setqflist(filtered)
    copen
    let w:quickfix_title = "QSearch " . pat
endfunction
command! -bang -nargs=? -complete=file QSearch call s:SearchQuickFixList(<bang>0, <q-args>)
