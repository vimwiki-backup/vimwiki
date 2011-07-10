" vim:tabstop=2:shiftwidth=2:expandtab:foldmethod=marker:textwidth=79
" Vimwiki syntax file
" MediaWiki syntax
" Author: Maxim Kim <habamax@gmail.com>
" Home: http://code.google.com/p/vimwiki/

" text: '''strong'''
let g:vimwiki_rxBold = "'''[^']\\+'''"
let g:vimwiki_char_bold = "'''"

" text: ''emphasis''
let g:vimwiki_rxItalic = "''[^']\\+''"
let g:vimwiki_char_italic = "''"

" text: '''''strong italic'''''
let g:vimwiki_rxBoldItalic = "'''''[^']\\+'''''"
let g:vimwiki_rxItalicBold = g:vimwiki_rxBoldItalic
let g:vimwiki_char_bolditalic = "'''''"
let g:vimwiki_char_italicbold = g:vimwiki_char_bolditalic

" text: `code`
let g:vimwiki_rxCode = '`[^`]\+`'
let g:vimwiki_char_code = '`'

" text: ~~deleted text~~
let g:vimwiki_rxDelText = '\~\~[^~]\+\~\~'
let g:vimwiki_char_deltext = '\~\~'

" text: ^superscript^
let g:vimwiki_rxSuperScript = '\^[^^]\+\^'
let g:vimwiki_char_superscript = '^'

" text: ,,subscript,,
let g:vimwiki_rxSubScript = ',,[^,]\+,,'
let g:vimwiki_char_subscript = ',,'

" Header levels, 1-6
let g:vimwiki_rxH = '='
let g:vimwiki_symH = 1
if g:vimwiki_symH
  "" Symm
  let g:vimwiki_rxH1 = '^\s*'.g:vimwiki_rxH.'\{1}[^'.g:vimwiki_rxH.']\+.*[^'.g:vimwiki_rxH.']\+'.g:vimwiki_rxH.'\{1}\s*$'
  let g:vimwiki_rxH2 = '^\s*'.g:vimwiki_rxH.'\{2}[^'.g:vimwiki_rxH.']\+.*[^'.g:vimwiki_rxH.']\+'.g:vimwiki_rxH.'\{2}\s*$'
  let g:vimwiki_rxH3 = '^\s*'.g:vimwiki_rxH.'\{3}[^'.g:vimwiki_rxH.']\+.*[^'.g:vimwiki_rxH.']\+'.g:vimwiki_rxH.'\{3}\s*$'
  let g:vimwiki_rxH4 = '^\s*'.g:vimwiki_rxH.'\{4}[^'.g:vimwiki_rxH.']\+.*[^'.g:vimwiki_rxH.']\+'.g:vimwiki_rxH.'\{4}\s*$'
  let g:vimwiki_rxH5 = '^\s*'.g:vimwiki_rxH.'\{5}[^'.g:vimwiki_rxH.']\+.*[^'.g:vimwiki_rxH.']\+'.g:vimwiki_rxH.'\{5}\s*$'
  let g:vimwiki_rxH6 = '^\s*'.g:vimwiki_rxH.'\{6}[^'.g:vimwiki_rxH.']\+.*[^'.g:vimwiki_rxH.']\+'.g:vimwiki_rxH.'\{6}\s*$'
  let g:vimwiki_rxHeader = '\%('.g:vimwiki_rxH1.'\)\|'.
        \ '\%('.g:vimwiki_rxH2.'\)\|'.
        \ '\%('.g:vimwiki_rxH3.'\)\|'.
        \ '\%('.g:vimwiki_rxH4.'\)\|'.
        \ '\%('.g:vimwiki_rxH5.'\)\|'.
        \ '\%('.g:vimwiki_rxH6.'\)'
else
  "" Asymm
  let g:vimwiki_rxH1 = '^\s*'.g:vimwiki_rxH.'\{1}[^'.g:vimwiki_rxH.']\+.*'
  let g:vimwiki_rxH2 = '^\s*'.g:vimwiki_rxH.'\{2}[^'.g:vimwiki_rxH.']\+.*'
  let g:vimwiki_rxH3 = '^\s*'.g:vimwiki_rxH.'\{3}[^'.g:vimwiki_rxH.']\+.*'
  let g:vimwiki_rxH4 = '^\s*'.g:vimwiki_rxH.'\{4}[^'.g:vimwiki_rxH.']\+.*'
  let g:vimwiki_rxH5 = '^\s*'.g:vimwiki_rxH.'\{5}[^'.g:vimwiki_rxH.']\+.*'
  let g:vimwiki_rxH6 = '^\s*'.g:vimwiki_rxH.'\{6}[^'.g:vimwiki_rxH.']\+.*'
  let g:vimwiki_rxHeader = '\%('.g:vimwiki_rxH1.'\)\|'.
        \ '\%('.g:vimwiki_rxH2.'\)\|'.            
        \ '\%('.g:vimwiki_rxH3.'\)\|'.            
        \ '\%('.g:vimwiki_rxH4.'\)\|'.            
        \ '\%('.g:vimwiki_rxH5.'\)\|'.            
        \ '\%('.g:vimwiki_rxH6.'\)'               
endif

let g:vimwiki_char_header = '\%(^\s*=\+\)\|\%(=\+\s*$\)'

" <hr>, horizontal rule
let g:vimwiki_rxHR = '^----.*$'

" Tables. Each line starts and ends with '|'; each cell is separated by '|'
let g:vimwiki_rxTableSep = '|'

" Bulleted list items start with whitespace(s), then '*'
" highlight only bullets and digits.
let g:vimwiki_rxListBullet = '^\s*\*\+\s\([^*]*$\)\@='
let g:vimwiki_rxListNumber = '^\s*#\+\s'

let g:vimwiki_rxListDefine = '^\%(;\|:\)\s'

" Preformatted text
let g:vimwiki_rxPreStart = '<pre>'
let g:vimwiki_rxPreEnd = '<\/pre>'

let g:vimwiki_rxComment = '^\s*%%.*$'
