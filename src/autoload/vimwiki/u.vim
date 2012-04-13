" vim:tabstop=2:shiftwidth=2:expandtab:foldmethod=marker:textwidth=79
" Vimwiki autoload plugin file
" Utility functions
" Author: Maxim Kim <habamax@gmail.com>
" Home: http://code.google.com/p/vimwiki/

function! vimwiki#u#trim(string, ...) "{{{
  let chars = ''
  if a:0 > 0
    let chars = a:1
  endif
  let res = substitute(a:string, '^[[:space:]'.chars.']\+', '', '')
  let res = substitute(res, '[[:space:]'.chars.']\+$', '', '')
  return res
endfunction "}}}


" Builtin cursor doesn't work right with unicode characters.
function! vimwiki#u#cursor(lnum, cnum) "{{{
  exe a:lnum
  exe 'normal! 0'.a:cnum.'|'
endfunction "}}}

