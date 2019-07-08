"Airline setup
set laststatus=2
set noshowmode

let g:airline_powerline_fonts = 1

if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif
let g:airline_symbols.space="\ua0"

" airline symbols
let g:airline_left_sep=''
let g:airline_left_alt_sep=''
let g:airline_right_sep=''
let g:airline_right_alt_sep=''
let g:airline_symbols.branch=''
let g:airline_symbols.readonly=''
let g:airline_symbols.linenr='Ln'
let g:airline_symbols.maxlinenr = ''
let g:airline_symbols.spell = 'S'
let g:airline_symbols.paste='P'
let g:airline_symbols.notexists = 'Ɇ'
