" FZF

" Use existing buffer 
command! -nargs=1 FzfOpenFile execute 'buffer' . bufnr(<f-args>, 1)

let s:fzf_user_command = 'ag . -i --nocolor --nogroup --hidden -g ""'
let s:fzf_user_command .= ' --ignore .git'
let s:fzf_user_command .= ' --ignore .hg'
let s:fzf_user_command .= ' --ignore .cquery_cache'
let s:fzf_user_command .= ' --ignore .ccls_cache'
let s:fzf_user_command .= ' --ignore .clangd'
let s:fzf_user_command .= ' --ignore .jdtls_data'
let s:fzf_user_command .= ' --ignore .metadata'
let s:fzf_user_command .= ' --ignore "*.pyc"'
let s:fzf_user_command .= ' --ignore "*.o"'
let s:fzf_user_command .= ' --ignore "*.d"'
let s:fzf_user_command .= ' --ignore "*.gcda"'
let s:fzf_user_command .= ' --ignore "*.gcno"'
let s:fzf_user_command .= ' --ignore "*.out"'

let g:fzf_custom_opts = {
            \ 'sink': 'FzfOpenFile',
            \ 'source': s:fzf_user_command,
            \ }

function! s:fzf_custom_run(...)
    if a:0 >= 1
        call fzf#run(fzf#wrap('MyFzf',
                    \ extend(g:fzf_custom_opts, {'dir': a:1}), 0))
    else
        call fzf#run(fzf#wrap('MyFzf', g:fzf_custom_opts, 0))
    endif
endfunction

augroup guoj_fzf_replace_cmd
    autocmd!
    autocmd VimEnter * command! -complete=file -nargs=* FZF call s:fzf_custom_run(<f-args>)
augroup END

nnoremap <C-p> :FZF<CR>
nnoremap <leader>fb :Buffers<CR>

nnoremap <leader>ff :FZF <c-r>=expand('%:p:h')<CR><CR>

nnoremap <leader>fp :FZF <c-r>=FindProjectRoot(expand('%:p'))<CR><CR>
