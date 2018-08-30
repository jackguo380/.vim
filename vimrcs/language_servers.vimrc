" Language servers and vim-lsp config
nmap csfg :LspDefinition<CR>
nmap csfc :LspReferences<CR>
nmap csfs :LspReferences<CR>
nmap csfi :LspImplementation<CR>
nmap csft :LspTypeDefinition<CR>
nmap csfh :LspHover<CR>
nmap csfr :LspRename<CR>

nmap <leader>d :LspDocumentDiagnostics<CR>

" Debug Logging
let g:lsp_log_verbose = 1
let g:lsp_log_file = expand('/tmp/vim-lsp.log')

" Enable diagnostic signs
"let g:lsp_signs_enabled = 0 Disabled until its a bit less annoying
let g:lsp_diagnostics_echo_cursor = 1

let g:lsp_signs_error = {'text': '✘'}
let g:lsp_signs_warning = {'text': '‼'}
let g:lsp_signs_hint = {'text': '❓'}

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
    let s:cquery_lang_server_executable = $VIMHOME . "/cquery/build/release/bin/cquery"
    let s:cquery_root_dir = FindProjectRoot()
    if executable(s:cquery_lang_server_executable)
        au User lsp_setup call lsp#register_server({
                    \ 'name': 'cquery',
                    \ 'cmd': {server_info->[s:cquery_lang_server_executable]},
                    \ 'root_uri': {server_info->lsp#utils#path_to_uri(s:cquery_root_dir)},
                    \ 'initialization_options': { 'cacheDirectory': s:cquery_root_dir . '/.cquery_cache' },
                    \ 'whitelist': ['c', 'cpp', 'objc', 'objcpp', 'cc'],
                    \ })
    endif

endif
