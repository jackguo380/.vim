" Color Scheme, need to install this manually:
colorscheme eldar

" C++ highlighting
" These are extra color settings not included in eldar
exe 'hi Function guifg=#8AE234 ctermfg=green gui=italic cterm=italic'
"exe 'hi Member guifg=#8AE234 ctermfg=green gui=italic cterm=italic'
exe 'hi Member guifg=#FFFFFF ctermfg=white gui=italic cterm=italic'
"exe 'hi MemberRefExpr guifg=#8AE234 ctermfg=green gui=italic cterm=italic'
exe 'hi Variable guifg=#FFFFFF ctermfg=white gui=none cterm=none'
exe 'hi Namespace guifg=#FCE94F ctermfg=yellow gui=none cterm=none'
exe 'hi EnumConstant guifg=#AD7FA8 ctermfg=Magenta gui=none cterm=none'
" Fix for keywords like virtual and other function modifiers
exe 'highlight! link StorageClass Statement'
" Fix vim-cpp-modern highlighting namespaces same as enums
exe 'highlight! link cppSTLnamespace Namespace'

"Transparent Terminal
hi Normal ctermbg=none

" More python syntax highlighting
let python_highlight_all=1

" bold the cursor line
"set cursorline
set nocursorline " Need to disable this until https://github.com/vim/vim/issues/2584 is fixed
hi CursorLine term=bold cterm=bold
hi CursorLineNr term=bold cterm=bold ctermbg=black

" Get the highlight group
function! <SID>GetHLGroupF()
  if !exists("*synstack")
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc
command! GetHLGroup call <SID>GetHLGroupF()
