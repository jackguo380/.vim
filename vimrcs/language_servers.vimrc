" Language servers and vim-lsp config
nmap csfg :LspDefinition<CR>
nmap csfs :LspReferences<CR>
nmap csfi :LspImplementation<CR>
nmap csft :LspTypeDefinition<CR>
nmap csfh :LspHover<CR>
nmap csfr :LspRename<CR>

" Cquery specific
nmap csfc :LspCqueryCallers<CR>
nmap csfv :LspCqueryVars<CR>
nmap csfd :LspCqueryDerived<CR>
nmap csfb :LspCqueryBase<CR>

nmap <leader>d :LspDocumentDiagnostics<CR>

" Debug Logging
let g:lsp_log_verbose = 1
let g:lsp_log_file = expand('/tmp/vim-lsp.log')

let g:lsp_cxx_hl_log_file = '/tmp/lsp-cxx-hl.log'

" Enable diagnostic signs
"let g:lsp_signs_enabled = 0 Disabled until its a bit less annoying
let g:lsp_diagnostics_echo_cursor = 1
" Only use lsp diagnostics if YCM is disabled
autocmd FileType c,cpp let g:lsp_diagnostics_echo_cursor = ! config_use_ycm

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

let s:cquery_lang_server_executable = [$VIMHOME . "/cquery/build/release/bin/cquery"]
let s:ccls_lang_server_executable = [$VIMHOME . "/ccls/build/release/bin/ccls"]

if executable(s:cquery_lang_server_executable[0])
    " Search upwards for .cquery_root marker
    let s:cquery_root_dir = findfile('.cquery_root', expand('%:p:h', 1) . ';')

    " If we find it use that as the root, otherwise use the vim root
    if s:cquery_root_dir != ''
        let s:cquery_root_dir = fnamemodify(s:cquery_root_dir, ':p:h')
    else
        let s:cquery_root_dir = FindProjectRoot()
    endif

    au User lsp_setup call lsp#register_server({
                \ 'name': 'cquery',
                \ 'cmd': s:cquery_lang_server_executable,
                \ 'root_uri': {server_info->lsp#utils#path_to_uri(s:cquery_root_dir)},
                \ 'whitelist': ['c', 'cpp', 'objc', 'objcpp', 'cc'],
                \ 'initialization_options': {
                \ 'cacheDirectory': s:cquery_root_dir . '/.cquery_cache',
                \ 'diagnostics': { 'frequencyMs' : -1, 'onType' : v:false},
                \ 'completion': {'detailedLabel' : v:true},
                \ 'highlight': {'enabled' : v:true},
                \ }
                \ })

elseif executable(s:ccls_lang_server_executable[0])
    " Search upwards for .ccls_root marker
    let s:ccls_root_dir = findfile('.ccls_root', expand('%:p:h', 1) . ';')

    " If we find it use that as the root, otherwise use the vim root
    if s:ccls_root_dir != ''
        let s:ccls_root_dir = fnamemodify(s:ccls_root_dir, ':p:h')
    else
        let s:ccls_root_dir = FindProjectRoot()
    endif

    au User lsp_setup call lsp#register_server({
                \ 'name': 'ccls',
                \ 'cmd': s:ccls_lang_server_executable,
                \ 'root_uri': {server_info->lsp#utils#path_to_uri(s:ccls_root_dir)},
                \ 'whitelist': ['c', 'cpp', 'objc', 'objcpp', 'cc'],
                \ 'initialization_options': {
                \ 'cache': { 'directory': s:ccls_root_dir . '/.ccls_cache' },
                \ }
                \ })
endif

