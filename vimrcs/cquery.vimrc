function! FindCqueryProjectRoot()
    let cph = expand('%:p:h', 1)
    if cph =~ '^.\+://' | retu cph | en
    for mkr in ['.git/', 'compile_commands.json', '.ctrlp', '.cquery', '.color_coded', '.ycm_extra_conf.py', '.vimprojects']
        let wd = call('find'.(mkr =~ '/$' ? 'dir' : 'file'), [mkr, cph.';'])
        if wd != '' | brea | en
    endfo
    let wd = fnameescape(wd == '' ? cph : substitute(wd, mkr.'$', '.', ''))
    return wd =~ '^/' ? wd : getcwd() . '/' . wd
endfunction

if executable($HOME . "/.vim/cquery/build/release/bin/cquery")
   au User lsp_setup call lsp#register_server({
      \ 'name': 'cquery',
      \ 'cmd': {server_info->[$HOME . "/.vim/cquery/build/release/bin/cquery"]},
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
"let g:lsp_log_verbose = 1
"let g:lsp_log_file = expand('~/vim-lsp.log')
