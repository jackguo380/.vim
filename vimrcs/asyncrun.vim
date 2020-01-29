" Asyncrun settings

function! s:run_maven(timer) abort
    AsyncRun mvn -B package
endfunction

function! s:maven_timer() abort
    let l:timer = get(g:, 'maven_asyncrun_timer', -1)
    if l:timer != -1
        call timer_stop(l:timer)
    endif

    let g:maven_asyncrun_timer = timer_start(1000, function('s:run_maven'))
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
