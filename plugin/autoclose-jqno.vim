" ***
" Logic
" ***

let s:closers = { '(': ')', '[': ']', '{': '}', '''': '''', '"': '"', '`': '`' }
let s:autoclosejqno_config = {
    \   'parens': ['(', '[', '{'],
    \   'quotes': ['''', '"', '`'],
    \ }


function! AutocloseOpen(open, close) abort
    return <SID>ExpandParenFully(v:true) ? a:open . a:close . "\<Left>" : a:open
endfunction

function! AutocloseClose(close) abort
    return <SID>NextChar() ==? a:close ? "\<Right>" : a:close
endfunction

function! AutocloseToggle(char) abort
    return <SID>NextChar() == a:char ? "\<Right>" : <SID>ExpandParenFully(v:false) ? a:char . a:char . "\<Left>" : a:char
endfunction

function! AutocloseSmartReturn() abort
    let l:prev = <SID>PrevChar()
    if pumvisible()
        return "\<C-Y>"
    elseif l:prev !=? '' && index(<SID>Parens(), l:prev) >= 0
        return "\<CR>\<Esc>O"
    else
        return "\<CR>"
    endif
endfunction

function! AutocloseSmartBackspace() abort
    let l:prev = <SID>PrevChar()
    let l:next = <SID>NextChar()
    for c in <SID>Combined()
        if l:prev ==? c && l:next ==? s:closers[c]
            return "\<BS>\<Del>"
        endif
    endfor
    return "\<BS>"
endfunction

function! AutocloseSmartJump() abort
    let l:i = 0
    let l:result = ''
    while index(<SID>Combined(), <SID>NextChar(l:i)) >= 0
        let l:result .= "\<Right>"
        let l:i += 1
    endwhile
    return l:result
endfunction

function! s:ExpandParenFully(expandIfAfterWord) abort
    let l:nextchar = <SID>NextChar()
    let l:nextok = l:nextchar ==? '' || index(<SID>Combined(), l:nextchar) >= 0
    let l:prevchar = <SID>PrevChar()
    let l:prevok = a:expandIfAfterWord || l:prevchar !~# '\w'
    return l:nextok && l:prevok
endfunction

function! s:NextChar(i = 0) abort
    return strpart(getline('.'), col('.')-1+a:i, 1)
endfunction

function! s:PrevChar() abort
    return strpart(getline('.'), col('.')-2, 1)
endfunction

function! s:Parens() abort
    return s:autoclosejqno_config['parens']
endfunction

function! s:Quotes() abort
    return s:autoclosejqno_config['quotes']
endfunction

function! s:Combined() abort
    return <SID>Parens() + <SID>Quotes()
endfunction


" ***
" Mappings
" ***

augroup AutoClose
    autocmd!

    inoremap <expr><silent> ( AutocloseOpen('(', ')')
    inoremap <expr><silent> ) AutocloseClose(')')
    inoremap <expr><silent> [ AutocloseOpen('[', ']')
    inoremap <expr><silent> ] AutocloseClose(']')
    inoremap <expr><silent> { AutocloseOpen('{', '}')
    inoremap <expr><silent> } AutocloseClose('}')
    inoremap <expr><silent> " AutocloseToggle('"')
    inoremap <expr><silent> ' AutocloseToggle("'")
    inoremap <expr><silent> ` AutocloseToggle('`')
    inoremap <expr><silent> <BS> AutocloseSmartBackspace()
    inoremap <expr><silent> <CR> AutocloseSmartReturn()
    inoremap <expr><silent> <C-L> AutocloseSmartJump()
augroup END
