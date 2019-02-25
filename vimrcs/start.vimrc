" Startup configuration

function! FindProjectRoot()
    let cph = expand('%:p:h', 1)
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
    endfo

    " Find the longest path length
    call sort(wdlist, function("s:comparelens"))

    " If nothing was found then fallback to cwd
    return fnameescape(len(wdlist) == 0 ? getcwd() : wdlist[0])
endfunction

au VimEnter * exe 'cd ' . FindProjectRoot()

" Configuration
if filereadable($VIMHOME . "/.config.txt")
    let my_config = readfile($VIMHOME . "/.config.txt")[0]
else
    echoerr "No Vimrc Configuration Found!"
    let my_config = "nocompile"
endif

if my_config ==# "ycm"
    let config_use_ycm = 1
    let config_use_color_coded = 1
    let config_use_asyncomplete = 0
    let config_use_cquery = 1
elseif my_config ==# "asyncomplete"
    let config_use_ycm = 0
    let config_use_color_coded = 1
    let config_use_asyncomplete = 1
    let config_use_cquery = 1
else
    if my_config !=# "nocompile"
        echoerr "Bad Vimrc Configuration: " . my_config
        let my_config = "nocompile"
    endif

    let config_use_ycm = 0
    let config_use_color_coded = 0
    let config_use_asyncomplete = 0
    let config_use_cquery = 0
endif
