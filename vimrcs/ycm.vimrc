"YouCompleteMe
let g:ycm_extra_conf_globlist = ['~/devel/*', '~/Documents/*', '/media/sf_shared_data/*']
let g:ycm_global_ycm_extra_conf = '~/.vim/.ycm_extra_conf.py'
let g:ycm_enable_diagnostic_signs = 1
let g:ycm_autoclose_preview_window_after_insertion = 1
let g:ycm_autoclose_preview_window_after_completion = 1
let g:ycm_disable_for_files_larger_than_kb = 0
let g:airline_exclude_preview = 0 "Fix Airline Bug with preview window
if executable('rustc')
    let g:ycm_rust_src_path = substitute(system('rustc --print sysroot'), '\n\+$', '', '') . '/lib/rustlib/src/rust/src'
endif
"let g:ycm_python_binary_path = 'python3'
set completeopt-=preview

nmap cyg :YcmCompleter GoToDefinition<CR>
nmap cys :YcmCompleter GoToDeclaration<CR>
nmap cyf :YcmCompleter GoToInclude<CR>
nmap cyt :YcmCompleter GetType<CR>

