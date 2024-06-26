vim9script

var options = {
    buffer: { enable: true, priority: 10, otherBuffersCount: 12, completionMatcher: "fuzzy" },
    lsp: { enable: true, priority: 20, maxCount: 5 },
    vimscript: { enable: true, priority: 11 },
}
autocmd VimEnter * g:VimCompleteOptionsSet(options)
