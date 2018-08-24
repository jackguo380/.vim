" Asyncomplete configuration

if config_use_asyncomplete
    inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
    inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
    inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<cr>"
    imap <c-f> <Plug>(asyncomplete_force_refresh)
    autocmd! CompleteDone * if pumvisible() == 0 | pclose | endif
    let g:asyncomplete_auto_popup = 1
    let g:asyncomplete_smart_completion = 1
    set completeopt-=preview

    " Filename completion
    au User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#file#get_source_options({
                \ 'name': 'file',
                \ 'whitelist': ['*'],
                \ 'priority': 10,
                \ 'completor': function('asyncomplete#sources#file#completor')
                \ }))

    " Complete with words from buffer
    au User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#buffer#get_source_options({
                \ 'name': 'buffer',
                \ 'whitelist': ['*'],
                \ 'priority' : 0,
                \ 'blacklist': ['go', 'c', 'cpp', 'python', 'sh', 'vim'],
                \ 'completor': function('asyncomplete#sources#buffer#completor'),
                \ }))

    " Completion for vim
    au User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#necovim#get_source_options({
                \ 'name': 'necovim',
                \ 'whitelist': ['vim'],
                \ 'priority' : 20,
                \ 'completor': function('asyncomplete#sources#necovim#completor'),
                \ }))


    let g:lsp_async_completion = 1
    let g:asyncomplete_log_file = expand("/tmp/asyncomplete.log")
endif
