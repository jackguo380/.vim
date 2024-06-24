vim9script             
var options = {        
    lsp: { enable: true, priority: 20, maxCount: 5 },
    vimscript: { enable: true, priority: 11 },
} 
autocmd VimEnter * g:VimCompleteOptionsSet(options)
