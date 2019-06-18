" Language Server Configuration

" Key Mappings
" vim-lsp
"nmap csfg :LspDefinition<CR>
"nmap csfs :LspReferences<CR>
"nmap csfi :LspImplementation<CR>
"nmap csft :LspTypeDefinition<CR>
"nmap csfh :LspHover<CR>
"nmap <leader>d :LspDocumentDiagnostics<CR>

" cquery/ccls specific
"nmap csfc :LspCqueryCallers<CR>
"nmap csfv :LspCqueryVars<CR>
"nmap csfd :LspCqueryDerived<CR>
"nmap csfb :LspCqueryBase<CR>

" LanguageClient
nmap csfg :call LanguageClient#textDocument_definition()<CR>
nmap csfs :call LanguageClient#textDocument_references()<CR>
nmap csfi :call LanguageClient#textDocument_implementation()<CR>
nmap csft :call LanguageClient#textDocument_typeDefinition()<CR>
nmap csfh :call LanguageClient#textDocument_hover()<CR>

" ccls specific
nmap csfc :call LanguageClient#findLocations({'method':'$ccls/call'})<CR>
nmap csfv :call LanguageClient#findLocations({'method':'$ccls/vars'})<CR>
nmap csfd :call LanguageClient#findLocations({'method':'$ccls/inheritance', 'derived': v:true})<CR>
nmap csfb :call LanguageClient#findLocations({'method':'$ccls/inheritance'})<CR>

"nmap <leader>d :LspDocumentDiagnostics<CR>

let g:LanguageClient_diagnosticsList = 'Location'
let g:LanguageClient_selectionUI = 'quickfix'

let g:LanguageClient_serverCommands = {}
let g:LanguageClient_rootMarkers = {}

" Debug Logging
let g:lsp_log_verbose = 1
let g:lsp_log_file = '/tmp/vim-lsp.log'

let g:lsp_cxx_hl_log_file = '/tmp/lsp-cxx-hl.log'

let g:LanguageClient_loggingFile = '/tmp/languageclient.log'
" For large files this is a more appropriate timeout
let g:LanguageClient_waitOutputTimeout = 30

" Enable diagnostic signs
"let g:lsp_signs_enabled = 0 Disabled until its a bit less annoying
let g:lsp_diagnostics_echo_cursor = 1
" Only use lsp diagnostics if YCM is disabled
autocmd FileType c,cpp let g:lsp_diagnostics_echo_cursor = ! config_use_ycm
autocmd FileType c,cpp let g:LanguageClient_diagnosticsEnable = 0

let g:lsp_signs_error = {'text': '✘'}
let g:lsp_signs_warning = {'text': '‼'}
let g:lsp_signs_hint = {'text': '❓'}

if executable('pyls')
    " pip install python-language-server
    au User lsp_setup call lsp#register_server({
        \ 'name': 'pyls',
        \ 'cmd': {server_info->['pyls']},
        \ 'whitelist': ['python'],
        \ })

    let g:LanguageClient_serverCommands['python'] = ['pyls']
endif

" Rust language server
if executable('rls')
    let s:rust_root_dir = FindProjectRoot()
    au User lsp_setup call lsp#register_server({
        \ 'name': 'rls',
        \ 'cmd': {server_info->['rls']},
        \ 'root_uri': {server_info->lsp#utils#path_to_uri(s:rust_root_dir)},
        \ 'whitelist': ['rust'],
        \ })

    let g:LanguageClient_serverCommands['rust'] = ['rls']
    let g:LanguageClient_rootMarkers['rust'] = ['.rls-root', 'Cargo.toml']
endif

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

    let s:cquery_settings = {
                \ 'cacheDirectory': s:cquery_root_dir . '/.cquery_cache',
                \ 'diagnostics': { 'frequencyMs' : -1, 'onType' : v:false},
                \ 'completion': {'detailedLabel' : v:true},
                \ 'highlight': {'enabled' : v:true},
                \ }

    au User lsp_setup call lsp#register_server({
                \ 'name': 'cquery',
                \ 'cmd': s:cquery_lang_server_executable,
                \ 'root_uri': {server_info->lsp#utils#path_to_uri(s:cquery_root_dir)},
                \ 'whitelist': ['c', 'cpp', 'objc', 'objcpp', 'cc'],
                \ 'initialization_options': s:cquery_settings
                \ })

    let s:cquery_exec = s:cquery_lang_server_executable + [ '-init=' . json_encode(s:cquery_settings)]
    let g:LanguageClient_serverCommands['c'] = s:cquery_exec
    let g:LanguageClient_serverCommands['cpp'] = s:cquery_exec
    let g:LanguageClient_rootMarkers['c'] = ['compile_commands.json', '.cquery_root']
    let g:LanguageClient_rootMarkers['cpp'] = ['compile_commands.json', '.cquery_root']

elseif executable(s:ccls_lang_server_executable[0])
    " Search upwards for .ccls_root marker
    let s:ccls_root_dir = findfile('.ccls_root', expand('%:p:h', 1) . ';')

    " If we find it use that as the root, otherwise use the vim root
    if s:ccls_root_dir != ''
        let s:ccls_root_dir = fnamemodify(s:ccls_root_dir, ':p:h')
    else
        let s:ccls_root_dir = FindProjectRoot()
    endif

    let s:ccls_settings = {
                \ 'cache': { 'directory': s:ccls_root_dir . '/.ccls_cache' },
                \ 'highlight': { 'lsRanges' : v:true },
                \ }

    au User lsp_setup call lsp#register_server({
                \ 'name': 'ccls',
                \ 'cmd': s:ccls_lang_server_executable,
                \ 'root_uri': {server_info->lsp#utils#path_to_uri(s:ccls_root_dir)},
                \ 'whitelist': ['c', 'cpp', 'objc', 'objcpp', 'cc'],
                \ 'initialization_options': s:ccls_settings
                \ })

    let s:ccls_exec = s:ccls_lang_server_executable + ['-init=' . json_encode(s:ccls_settings)]
    let g:LanguageClient_serverCommands['c'] = s:ccls_exec
    let g:LanguageClient_serverCommands['cpp'] = s:ccls_exec
    let g:LanguageClient_rootMarkers['c'] = ['compile_commands.json', '.ccls_root']
    let g:LanguageClient_rootMarkers['cpp'] = ['compile_commands.json', '.ccls_root']
endif

