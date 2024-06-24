vim9script
# Language Server Configuration

# LSP shortcuts
nmap csfg :LspGotoDefinition<CR>
nmap csfs :LspShowReferences<CR>
nmap csfi :LspGotoImpl<CR>
nmap csft :LspGotoDeclaration<CR>
nmap csfh :LspHover<CR>
nmap csfc :LspIncomingCalls<CR>

# TODO? Find a replacement for these
# nmap csfd :call LanguageClient#findLocations({'method':'$ccls/inheritance', 'derived': v:true})<CR>
# nmap csfb :call LanguageClient#findLocations({'method':'$ccls/inheritance'})<CR>

# LSP Settings
var lspOpts = {
    autoComplete: v:false,
    omniComplete: v:false,
    autoHighlightDiags: v:true,
    completionMatcher: 'fuzzy',
    semanticHighlight: v:true,
    showInlayHints: v:true,
    showDiagWithVirtualText: v:true,
    showDiagOnStatusLine: v:true
}
autocmd User LspSetup call LspOptionsSet(lspOpts)

# Debug Logging
g:lsp_cxx_hl_log_file = '/tmp/lsp-cxx-hl.log'
#let g:lsp_cxx_hl_verbose_log = 1

g:lsp_cxx_hl_use_text_props = 1

#let g:lsp_cxx_hl_use_mode_delay = 1
#let g:lsp_cxx_hl_edit_delay_ms = 1000

if executable('pylsp')
    #let g:LanguageClient_serverCommands['python'] = {
    #            \ 'name': 'python3',
    #            \ 'command': ['pylsp'],
    #            \ 'initializationOptions': {}
    #        \ }
endif

var clangdServer = [{}]
if executable('clangd')
    clangdServer = [{
        name: 'clang',
        filetype: ['c', 'cpp'],
        path: 'clangd',
        rootSearch: ['.clangd', 'compile_commands.json'],
        args: []
    }]
    autocmd User LspSetup call LspAddServer(clangdServer)
endif

#if isdirectory(g:my_vim_directory . '/jdt-language-server')
#    var bemol_dir = findfile('.bemol', expand('%:p:h', 1) . ';')
#    var ws_root_folders = ''
#    if bemol_dir != ''
#        ws_root_folders = fnamemodify(bemol_dir ':p:h') . '/ws_root_folders'
#    endif
#endif
