let g:ctrlp_cache_dir = '/tmp/.ctrlp'
let g:ctrlp_clear_cache_on_exit = 0

let g:ctrlp_root_markers = ['compile_commands.json', '.ctrlp', '.cquery', '.color_coded', '.ycm_extra_conf.py', '.vimprojects']

let s:ignore_files = ["*.so", "*.d", "*.o", "*.out", "*.old", ".swp", "*.gcda", "*.gcno", "*.dat"]
let s:ignore_files_2 = []

for val in s:ignore_files
    let val = substitute(val, "\*", "", "g")
    let val = substitute(val, "\\.", '\\.', "g")
    let val = val . '$'
    let s:ignore_files_2 += [ val ]
endfor

let g:ctrlp_custom_ignore = {
  \ 'dir':  '\.git$',
  \ 'file': join(s:ignore_files_2, '\|')
  \ }


"function! s:WildignoreFromGitignore(...)
"    let gitignore = (a:0 && !empty(a:1)) ? fnamemodify(a:1, ':p') : fnamemodify(expand('%'), ':p:h') . '/'
"    let gitignore .= '.gitignore'
"    let full_ignore = ''
"
"    if filereadable(gitignore)
"        let ignores = []
"        let separator = '\|'
"        for oline in readfile(gitignore)
"            let line = substitute(oline, '\s|\n|\r', '', "g")
"            if line == ''   | con | endif
"            if line =~ '^!' | con | endif
"            if line =~ '^#' | con | endif
"            let line = substitute(line, '\/', '\\/', "g")
"            let line = substitute(line, '\*\*', '.\\+', "g")
"            let line = substitute(line, '\*', '[^/]\\+', "g")
"            if line =~ '/$' | let line .= '.\\+' | endif
"            let ignores += [ substitute(line, ' ', '\\ ', "g") ]
"        endfor
"        let ignstr = join(ignores, '\|')
"        let g:ctrlp_custom_ignore=ignstr
"        echom ignstr
"    endif
"endfunction
"
"noremap <unique> <script> <Plug>WildignoreFromGitignore <SID>WildignoreFromGitignore
"noremap <SID>WildignoreFromGitignore :call <SID>WildignoreFromGitignore()<CR>
"command -nargs=? WildignoreFromGitignore :call <SID>WildignoreFromGitignore(<q-args>)
