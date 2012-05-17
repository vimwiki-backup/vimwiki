" vim:tabstop=2:shiftwidth=2:expandtab:foldmethod=marker:textwidth=79
" Vimwiki autoload plugin file
" Desc: Link functions for default syntax
" Author: Maxim Kim <habamax@gmail.com>
" Home: http://code.google.com/p/vimwiki/



" WIKI link following functions {{{

function! vimwiki#base_media#find_next_link() "{{{
  call vimwiki#base_default#find_next_link()
endfunction " }}}

function! vimwiki#base_media#find_prev_link() "{{{
  call vimwiki#base_default#find_prev_link()
endfunction " }}}

function! vimwiki#base_media#follow_link(split, ...) "{{{
  if a:0
    call vimwiki#base_default#follow_link(a:split, a:1)
  else
    call vimwiki#base_default#follow_link(a:split)
  endif
endfunction " }}}

function! vimwiki#base_media#normalize_link(is_visual_mode) "{{{
  call vimwiki#base_default#normalize_link(a:is_visual_mode)
endfunction "}}}

" }}}

