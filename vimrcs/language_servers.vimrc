if executable('bash-language-server')
  au User lsp_setup call lsp#register_server({
        \ 'name': 'bash-language-server',
        \ 'cmd': {server_info->[&shell, &shellcmdflag, 'bash-language-server start']},
        \ 'whitelist': ['sh'],
        \ })
endif

if executable('pyls')
    " pip install python-language-server
    au User lsp_setup call lsp#register_server({
        \ 'name': 'pyls',
        \ 'cmd': {server_info->['pyls']},
        \ 'whitelist': ['python'],
        \ })
endif

if config_use_cquery
    function! FindCqueryProjectRoot()
        let cph = expand('%:p:h', 1)
        let wdlist = []

        " Comparing path's string length is good enough since we search upwards only
        func! s:comparelens(s1, s2)
            return len(a:s1) < len(a:s2) ? 1 : -1
        endfunc

        for mkr in ['.git/', 'compile_commands.json', '.ctrlp', '.cquery', '.color_coded', '.ycm_extra_conf.py', '.vimprojects']
            let wd = call('find'.(mkr =~ '/$' ? 'dir' : 'file'), [mkr, cph.';'])
            if wd != '' 
                let wd = wd =~ '^/' ? wd : getcwd() . '/' . wd " prepend full path if not already a full path
                let wdlist += [wd]
            endif
        endfo

        call sort(wdlist, function("s:comparelens"))
        call uniq(wdlist)
        return fnameescape(len(wdlist) == 0 ? cph : fnamemodify(wdlist[0], ":h"))
    endfunction

    if executable($VIMHOME . "/cquery/build/release/bin/cquery")
        au User lsp_setup call lsp#register_server({
                    \ 'name': 'cquery',
                    \ 'cmd': {server_info->[$VIMHOME . "/cquery/build/release/bin/cquery"]},
                    \ 'root_uri': {server_info->lsp#utils#path_to_uri(FindCqueryProjectRoot())},
                    \ 'initialization_options': { 'cacheDirectory': '/tmp/cquery/cache' },
                    \ 'whitelist': ['c', 'cpp', 'objc', 'objcpp', 'cc'],
                    \ })
    endif

    nmap csfg :LspDefinition<CR>
    nmap csfc :LspReferences<CR>
    nmap csfs :LspReferences<CR>
    nmap csfi :LspImplementation<CR>
    nmap csft :LspTypeDefinition<CR>
    nmap csfh :LspHover<CR>
    nmap csfr :LspRename<CR>

    " Debug Logging
    let g:lsp_log_verbose = 1
    let g:lsp_log_file = expand('~/vim-lsp.log')
endif
