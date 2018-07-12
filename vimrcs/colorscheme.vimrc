" Color Scheme, need to install this manually:
" https://github.com/agude/vim-eldar
colorscheme eldar

" C++ highlighting
" These are extra color settings not included in eldar
exe 'hi Function guifg=#8AE234 ctermfg=green gui=italic cterm=italic'
"exe 'hi Member guifg=#8AE234 ctermfg=green gui=italic cterm=italic'
exe 'hi Member guifg=#FFFFFF ctermfg=white gui=italic cterm=italic'
exe 'hi Variable guifg=#FFFFFF ctermfg=white gui=none cterm=none'
exe 'hi Namespace guifg=#FCE94F ctermfg=yellow gui=none cterm=none'
exe 'hi EnumConstant guifg=#AD7FA8 ctermfg=Magenta gui=none cterm=none'

"Transparent Terminal
hi Normal ctermbg=none

" More python syntax highlighting
let python_highlight_all=1

" bold the cursor line
set cursorline
hi CursorLine term=bold cterm=bold
