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
" Only use lsp diagnostics if YCM is disabled
au FileType c,cpp let g:lsp_diagnostics_echo_cursor = ! config_use_ycm

" Ycm doesn't seem to put out rust diagnostics, use lsp
au FileType rust let b:lsp_signs_enabled = 1

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

" Rust language server
"if executable('rls')
    "let s:rust_root_dir = FindProjectRoot()
    "au User lsp_setup call lsp#register_server({
    "    \ 'name': 'rls',
    "    \ 'cmd': {server_info->['rls']},
    "    \ 'root_uri': {server_info->lsp#utils#path_to_uri(s:rust_root_dir)},
    "    \ 'whitelist': ['rust'],
    "    \ })
"endif

if config_use_cquery
    let s:cquery_lang_server_executable = $VIMHOME . "/cquery/build/release/bin/cquery"
    let s:cquery_root_dir = FindProjectRoot()
    if executable(s:cquery_lang_server_executable)
        au User lsp_setup call lsp#register_server({
                    \ 'name': 'cquery',
                    \ 'cmd': {server_info->[s:cquery_lang_server_executable]},
                    \ 'root_uri': {server_info->lsp#utils#path_to_uri(s:cquery_root_dir)},
                    \ 'whitelist': ['c', 'cpp', 'objc', 'objcpp', 'cc'],
                    \ 'initialization_options':
                    \ { 'cacheDirectory': s:cquery_root_dir . '/.cquery_cache',
                    \ 'enableIndexOnDidChange' : v:true,
                    \ 'diagnostics': { 'frequencyMs' : -1, 'onType' : v:false},
                    \ 'completion': {'detailedLabel' : v:true} }
                    \ })
    endif
endif
