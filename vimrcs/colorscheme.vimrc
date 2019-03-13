" Color Scheme
colorscheme eldar

" C++ highlighting
" These are extra color settings not included in eldar
hi! Function guifg=#8AE234 ctermfg=green gui=italic cterm=italic
hi! Variable guifg=#FFFFFF ctermfg=white gui=none cterm=none
hi! Namespace guifg=#FCE94F ctermfg=yellow gui=none cterm=none
hi! EnumConstant guifg=#AD7FA8 ctermfg=Magenta gui=none cterm=none
" Fix for keywords like virtual and other function modifiers
hi! link StorageClass Statement
" Fix vim-cpp-modern highlighting namespaces same as enums
hi! link cppSTLnamespace Namespace

" Disable highlighting of functions in vim-cpp-modern
let g:cpp_no_function_highlight = 1

"Transparent Terminal
hi! Normal ctermbg=none

" More python syntax highlighting
let python_highlight_all=1

" bold the cursor line
"set cursorline
set nocursorline " Need to disable this until https://github.com/vim/vim/issues/2584 is fixed
hi CursorLine term=bold cterm=bold
hi CursorLineNr term=bold cterm=bold ctermbg=black

"" Get the highlight group
"function! <SID>GetHLGroupF()
"  if !exists("*synstack")
"    return
"  endif
"  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
"endfunc
"command! GetHLGroup call <SID>GetHLGroupF()

if has("gui_running")
    if has("gui_win32")
        set guifont=Consolas:h10
    endif
endif
