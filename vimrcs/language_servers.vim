vim9script
# Language Server Configuration

# LSP shortcuts
nmap csfg :LspGotoDefinition<CR>
nmap csfs :LspShowReferences<CR>
nmap csfi :LspGotoImpl<CR>
nmap csft :LspGotoDeclaration<CR>
nmap csfh :LspHover<CR>
nmap csfc :LspIncomingCalls<CR>
nmap csfe :LspDiagShow<CR>

# TODO? Find a replacement for these
# nmap csfd :call LanguageClient#findLocations({'method':'$ccls/inheritance', 'derived': v:true})<CR>
# nmap csfb :call LanguageClient#findLocations({'method':'$ccls/inheritance'})<CR>

# LSP Settings
var lspOpts = {
    autoComplete: v:false,
    omniComplete: v:false,
    useQuickfixForLocations: v:true,
    autoHighlightDiags: v:true,
    completionMatcher: 'fuzzy',
    semanticHighlight: v:true,
    showInlayHints: v:true,
    showDiagWithVirtualText: v:true,
    showDiagOnStatusLine: v:true
}
autocmd User LspSetup call LspOptionsSet(lspOpts)

def AddWorkspaceDirs(ws_dirs: list<string>)
    for ws_root in ws_dirs
        echomsg printf("Adding Workspace: %s", ws_root)
        execute("LspWorkspaceAddFolder " .. ws_root)
    endfor
enddef

# Detect custom workspace list
var lsp_ws_dirs: list<string>
var lsp_list_file = findfile('.vim_lsp_ws_dir_list', expand('%:p:h', 1) .. ';')
if filereadable(lsp_list_file)
    lsp_ws_dirs = readfile(lsp_list_file)
    autocmd User LspAttached call AddWorkspaceDirs(lsp_ws_dirs)
endif

# Custom LSP args
var lsp_args: list<string> = []
var lsp_args_file = findfile('.vim_lsp_args', expand('%:p:h', 1) .. ';')
if filereadable(lsp_args_file)
    lsp_args = readfile(lsp_args_file)
endif

var lsp_servers: list<dict<any>> = []
if executable('pylsp')
    lsp_servers += [{
        name: 'pylsp',
        filetype: ['python'],
        path: 'pylsp',
        args: []
    }]
endif

if executable('cwls')
    lsp_servers += [{
        name: 'cwls',
        filetype: ['python', 'c', 'cpp', 'java', 'sh', 'java'],
        path: 'cwls',
        args: []
    }]
endif

if executable('clangd')
    lsp_servers += [{
        name: 'clang',
        filetype: ['c', 'cpp'],
        path: 'clangd',
        rootSearch: ['compile_commands.json'],
        args: []
    }]
endif

if isdirectory(g:my_vim_directory .. '/jdt') && !empty(lsp_ws_dirs)
    var workspace_uris: list<string> = []

    for ws_dir in lsp_ws_dirs
        workspace_uris->add('file://' .. ws_dir)
    endfor

    lsp_servers += [{
        name: 'eclipse.jdt.ls',
        filetype: ['java'],
        path: g:my_vim_directory .. '/jdt/bin/jdtls',
        args: ['-data', g:my_project_root .. '/.jdtls'] + lsp_args,
        initializationOptions: {
            workspaceFolders: workspace_uris
        }
    }]
endif

if !empty(lsp_servers)
    autocmd User LspSetup call LspAddServer(lsp_servers)
endif
