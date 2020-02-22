" Language Server Configuration

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
let g:LanguageClient_semanticHighlightMaps = {}

" Debug Logging
let g:lsp_cxx_hl_log_file = '/tmp/lsp-cxx-hl.log'

let g:lsp_cxx_hl_use_text_props = 1

let g:LanguageClient_loggingFile = '/tmp/languageclient.log'
"let g:LanguageClient_loggingLevel = 'DEBUG'
"let g:LanguageClient_loggingLevel = 'INFO'

" For large files this is a more appropriate timeout
let g:LanguageClient_waitOutputTimeout = 30

let g:LanguageClient_diagnosticsEnable = 1

if executable('pyls')
    let g:LanguageClient_serverCommands['python'] = ['pyls']
endif

" Rust language server
let s:rust_command = []

if executable('ra_lsp_server')
    let s:rust_command = ['ra_lsp_server']
endif

if len(s:rust_command) > 0 && executable('rustup')
    " Use a special marker file to indicate the use of nightly rls
    let s:allow_nightly = filereadable(g:my_project_root . '/.rls_use_nightly')

    if s:allow_nightly
        silent call system('rustup run nightly rls --version')

        if v:shell_error == 0
            let s:rust_command = ['rustup', 'run', 'nightly', 'rls']
        endif
    endif

    " Always try stable incase nightly was not installed
    if len(s:rust_command) == 0
        silent call system('rustup run stable rls --version')

        if v:shell_error == 0
            let s:rust_command = ['rustup', 'run', 'stable', 'rls']
        endif
    endif
endif

if len(s:rust_command) > 0
    let g:LanguageClient_serverCommands['rust'] = s:rust_command
    let g:LanguageClient_rootMarkers['rust'] = ['.rls-root']
endif

let s:cquery_lang_server_executable = [g:my_vim_directory 
            \ . "/cquery/build/release/bin/cquery"]
let s:ccls_lang_server_executable = [g:my_vim_directory
            \ . "/ccls/build/release/bin/ccls"]

if executable(s:cquery_lang_server_executable[0])
    " Search upwards for .cquery_root marker
    let s:cquery_root_dir = findfile('.cquery_root', expand('%:p:h', 1) . ';')

    " If we find it use that as the root, otherwise use the vim root
    if s:cquery_root_dir != ''
        let s:cquery_root_dir = fnamemodify(s:cquery_root_dir, ':p:h')
    else
        let s:cquery_root_dir = g:my_project_root
    endif

    let s:cquery_settings = {
                \ 'cacheDirectory': s:cquery_root_dir . '/.cquery_cache',
                \ 'diagnostics': { 'frequencyMs' : -1, 'onType' : v:false},
                \ 'completion': {'detailedLabel' : v:true},
                \ 'highlight': {'enabled' : v:true},
                \ }

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
        let s:ccls_root_dir = g:my_project_root
    endif

    let s:ccls_settings = {
                \ 'cache': { 'directory': s:ccls_root_dir . '/.ccls_cache' },
                \ 'highlight': { 'lsRanges' : v:true },
                \ }

    let s:ccls_exec = s:ccls_lang_server_executable + ['-init=' . json_encode(s:ccls_settings)]
    let g:LanguageClient_serverCommands['c'] = s:ccls_exec
    let g:LanguageClient_serverCommands['cpp'] = s:ccls_exec
    let g:LanguageClient_rootMarkers['c'] = ['compile_commands.json', '.ccls_root']
    let g:LanguageClient_rootMarkers['cpp'] = ['compile_commands.json', '.ccls_root']
endif

if executable('clangd')
    "let g:LanguageClient_serverStderr = '/tmp/clangd.stderr'
    let g:LanguageClient_serverCommands['opencl'] = ['clangd']
    let g:LanguageClient_rootMarkers['opencl'] = ['compile_commands.json', 'compile_flags.txt', '.clangd_root']
    let g:LanguageClient_serverCommands['glsl'] = ['clangd']
    let g:LanguageClient_rootMarkers['glsl'] = ['compile_commands.json', 'compile_flags.txt', '.clangd_root']

    "let g:LanguageClient_serverCommands['cpp'] = ['clangd', '--log=verbose']
    "let g:LanguageClient_semanticHighlightMaps['cpp'] = [
    "            \ {'Function': ['entity.name.function.cpp']},
    "            \ {'Function': ['entity.name.function.method.cpp']},
    "            \ {'CppNamespace': ['entity.name.namespace.cpp']},
    "            \ {'EnumConstant': ['variable.other.enummember.cpp']},
    "            \ {'CppMemberVariable': ['variable.other.field.cpp']},
    "            \ {'Type': ['entity.name.type.class.cpp']},
    "            \ {'Type': ['entity.name.type.enum.cpp']},
    "            \ {'Type': ['entity.name.type.template.cpp']},
    "            \ ]
endif

if isdirectory(g:my_vim_directory . '/eclipse.jdt.ls/org.eclipse.jdt.ls.product/target')
    let s:jdtls_exec = [g:my_vim_directory . '/jdtls', '-data', g:my_project_root . '/..']

    let g:LanguageClient_serverCommands['java'] = s:jdtls_exec

    let g:LanguageClient_semanticHighlightMaps['java'] = {
                \ '^storage.modifier.static.java:entity.name.function.java': 'JavaStaticMemberFunction',
                \ '^meta.definition.variable.java:meta.class.body.java:meta.class.java': 'JavaMemberVariable',
                \ '^storage.modifier.static.java:storage.modifier.final.java:variable.other.definition.java:meta.definition.variable.java': 'EnumConstant',
                \ '^entity.name.function.java': 'Function',
                \ 'entity.name.function.java': 'Function',
                \ 'entity.name.type.class.java': 'Type',
                \ 'entity.name.type.enum.java': 'Type',
                \ }


    let g:LanguageClient_rootMarkers['java'] = ['.eclipse.jdt.ls.root']
endif

if executable('javascript-typescript-stdio')
    let g:LanguageClient_serverCommands['javascript'] = ['javascript-typescript-stdio']
    let g:LanguageClient_serverCommands['typescript'] =  ['javascript-typescript-stdio']

    let g:LanguageClient_rootMarkers['javascript'] = ['jsconfig.json']
    let g:LanguageClient_rootMarkers['typescript'] = ['tsconfig.json']
endif
