" Asyncrun settings

function! s:run_maven(timer) abort
    AsyncRun mvn -B package
endfunction

function! s:maven_timer() abort
    let l:timer = get(g:, 'maven_asyncrun_timer', -1)
    if l:timer != -1
        call timer_stop(l:timer)
    endif

    if g:enable_asyncrun_write
        let g:maven_asyncrun_timer = timer_start(1000, function('s:run_maven'))
    endif
endfunction

function! s:setup_java() abort
    augroup maven_asyncrun
        autocmd!
        autocmd BufWritePost *.java AsyncStop | call s:maven_timer()
    augroup END

    compiler maven
    setlocal makeprg=mvn\ -B\ $*
endfunction

autocmd FileType java call s:setup_java()

let g:enable_asyncrun_write = 1

function! ToggleAsyncRunOnBuf() abort
    if g:enable_asyncrun_write
        let g:enable_asyncrun_write = 0
    else
        let g:enable_asyncrun_write = 1
    endif
endfunction

nnoremap <leader>aa :call ToggleAsyncRunOnBuf()<CR>
