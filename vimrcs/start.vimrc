" Startup configuration

function! FindProjectRoot(...)
    if a:0 >= 1
        let cph = a:1
    else
        let cph = expand('%:p:h', 1)
    endif
    let wdlist = []

    " Comparing path's string length is good enough since we search upwards only
    func! s:comparelens(s1, s2)
        return len(a:s1) < len(a:s2) ? 1 : -1
    endfunc

    for mkr in ['.git/', '.hg/', 'compile_commands.json', '.ctrlp', '.cquery', '.color_coded', '.ycm_extra_conf.py', '.vimprojects']
        let isdir = mkr =~ '/$'
        let wd = call('find'.(isdir ? 'dir' : 'file'), [mkr, cph.';'])

        if wd != ''
            " The trailing / in directories needs a extra :h to remove
            let wdlist += [ fnamemodify(wd, isdir ? ':p:h:h' : ':p:h')]
        endif
    endfor

    " Find the longest path length
    call sort(wdlist, function("s:comparelens"))

    " If nothing was found then fallback to cwd
    return fnameescape(len(wdlist) == 0 ? getcwd() : wdlist[0])
endfunction

let g:my_project_root = FindProjectRoot()

augroup startprojectroot
    autocmd!
    autocmd VimEnter * exe 'cd ' . g:my_project_root
augroup END
