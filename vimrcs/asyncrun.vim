" Asyncrun settings

let g:enable_asyncrun_write = 1

function! ToggleAsyncRunOnBuf() abort
    if g:enable_asyncrun_write
        let g:enable_asyncrun_write = 0
    else
        let g:enable_asyncrun_write = 1
    endif
endfunction

nnoremap <leader>aa :call ToggleAsyncRunOnBuf()<CR>
