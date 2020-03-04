" Asyncrun settings

" ==== Shellcheck ====

function! s:setup_shellcheck() abort
    if exists(':ShellCheck') == 2
        augroup shellcheck_run
            autocmd!
            autocmd BufWritePost * ShellCheck!
        augroup END
    else
        echo 'Shellcheck Plugin is not installed!'
    endif
endfunction

autocmd FileType sh call s:setup_shellcheck()

let g:enable_asyncrun_write = 1

function! ToggleAsyncRunOnBuf() abort
    if g:enable_asyncrun_write
        let g:enable_asyncrun_write = 0
    else
        let g:enable_asyncrun_write = 1
    endif
endfunction

nnoremap <leader>aa :call ToggleAsyncRunOnBuf()<CR>
