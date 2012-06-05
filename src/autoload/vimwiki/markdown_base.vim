" vim:tabstop=2:shiftwidth=2:expandtab:foldmethod=marker:textwidth=79
" Vimwiki autoload plugin file
" Desc: Link functions for markdown syntax
" Author: Maxim Kim <habamax@gmail.com>
" Home: http://code.google.com/p/vimwiki/


" Helper functions " {{{
function! s:normalize_link_syntax_n() " {{{
  let lnum = line('.')

  " try WikiLink
  let lnk = vimwiki#base#matchstr_at_cursor(g:vimwiki_rxWikiLink)
  if !empty(lnk)
    let sub = vimwiki#base#normalize_link_helper(lnk,
          \ g:vimwiki_rxWikiLinkMatchUrl, g:vimwiki_rxWikiLinkMatchDescr,
          \ g:vimwiki_WikiLinkTemplate2)
    call vimwiki#base#replacestr_at_cursor(g:vimwiki_rxWikiLink, sub)
    if g:vimwiki_debug > 1
      echomsg "WikiLink: ".lnk." Sub: ".sub
    endif
    return
  endif
  
  " try WikiIncl
  let lnk = vimwiki#base#matchstr_at_cursor(g:vimwiki_rxWikiIncl)
  if !empty(lnk)
    " NO-OP !!
    if g:vimwiki_debug > 1
      echomsg "WikiIncl: ".lnk." Sub: ".lnk
    endif
    return
  endif

  " try Weblink
  let lnk = vimwiki#base#matchstr_at_cursor(g:vimwiki_rxWeblink)
  if !empty(lnk)
    let sub = vimwiki#base#normalize_link_helper(lnk,
          \ g:vimwiki_rxWeblinkMatchUrl, g:vimwiki_rxWeblinkMatchDescr,
          \ g:vimwiki_web_template)
    call vimwiki#base#replacestr_at_cursor(g:vimwiki_rxWeblink, sub)
    if g:vimwiki_debug > 1
      echomsg "WebLink: ".lnk." Sub: ".sub
    endif
    return
  endif
  
  " try Image link
  let lnk = vimwiki#base#matchstr_at_cursor(g:vimwiki_rxImagelink)
  if !empty(lnk)
    let sub = vimwiki#base#normalize_imagelink_helper(lnk,
          \ g:vimwiki_rxImagelinkMatchUrl, g:vimwiki_rxImagelinkMatchDescr,
          \ g:vimwiki_rxImagelinkMatchStyle, g:vimwiki_image_template)
    call vimwiki#base#replacestr_at_cursor(g:vimwiki_rxImagelink, sub)
    if g:vimwiki_debug > 1
      echomsg "ImageLink: ".lnk." Sub: ".sub
    endif
    return
  endif
  
  " try Word (any characters except separators)
  " rxWord is less permissive than rxWikiLinkUrl which is used in
  " normalize_link_syntax_v
  let lnk = vimwiki#base#matchstr_at_cursor(g:vimwiki_rxWord)
  if !empty(lnk)
    let sub = vimwiki#base#normalize_link_helper(lnk,
          \ g:vimwiki_rxWord, '',
          \ g:vimwiki_WikiLinkTemplate1)
    call vimwiki#base#replacestr_at_cursor('\V'.lnk, sub)
    if g:vimwiki_debug > 1
      echomsg "Word: ".lnk." Sub: ".sub
    endif
    return
  endif

endfunction " }}}

function! s:normalize_link_syntax_v() " {{{
  let lnum = line('.')
  let sel_save = &selection
  let &selection = "old"
  let rv = @"
  let rt = getregtype('"')
  let done = 0

  try
    norm! gvy
    let visual_selection = @"
    let visual_selection = '[['.visual_selection.']]'

    call setreg('"', visual_selection, 'v')

    " paste result
    norm! `>pgvd

  finally
    call setreg('"', rv, rt)
    let &selection = sel_save
  endtry

endfunction " }}}

" Helper functions " }}}

" WIKI link following functions {{{
function! vimwiki#base_markdown#find_next_link() "{{{
  call vimwiki#base#search_word(g:vimwiki_rxWikiLink.'\|'.
        \ g:vimwiki_rxWikiIncl.'\|'.g:vimwiki_rxWeblink.'\|'.
        \ g:vimwiki_rxImagelink, '')
endfunction
" }}}

function! vimwiki#base_markdown#find_prev_link() "{{{
  call vimwiki#base#search_word(g:vimwiki_rxWikiLink.'\|'.
        \ g:vimwiki_rxWikiIncl.'\|'.g:vimwiki_rxWeblink.'\|'.
        \ g:vimwiki_rxImagelink, 'b')
endfunction
" }}}

function! vimwiki#base_markdown#follow_link(split, ...) "{{{
  if a:split == "split"
    let cmd = ":split "
  elseif a:split == "vsplit"
    let cmd = ":vsplit "
  elseif a:split == "tabnew"
    let cmd = ":tabnew "
  else
    let cmd = ":e "
  endif

  " try WikiLink
  let lnk = matchstr(vimwiki#base#matchstr_at_cursor(g:vimwiki_rxWikiLink),
        \ g:vimwiki_rxWikiLinkMatchUrl)
  if lnk != ""
    call vimwiki#base#open_link(cmd, lnk)
    return
  endif
  " try WikiIncl
  let lnk = matchstr(vimwiki#base#matchstr_at_cursor(g:vimwiki_rxWikiIncl),
        \ g:vimwiki_rxWikiInclMatchUrl)
  if lnk != ""
    call vimwiki#base#open_link(cmd, lnk)
    return
  endif
  " try Weblink
  let lnk = matchstr(vimwiki#base#matchstr_at_cursor(g:vimwiki_rxWeblink),
        \ g:vimwiki_rxWeblinkMatchUrl)
  if lnk != ""
    call VimwikiWeblinkHandler(lnk)
    return
  endif
  " try Imagelink
  let lnk = matchstr(vimwiki#base#matchstr_at_cursor(g:vimwiki_rxImagelink),
        \ g:vimwiki_rxImagelinkMatchUrl)
  if lnk != ""
    call VimwikiWeblinkHandler(lnk)
    return
  endif

  if a:0 > 0
    execute "normal! ".a:1
  else		
    " execute "normal! \n"
    call vimwiki#base_markdown#normalize_link(0)
  endif

endfunction " }}}

function! vimwiki#base_markdown#normalize_link(is_visual_mode) "{{{
  if !a:is_visual_mode
    call s:normalize_link_syntax_n()
  elseif visualmode() ==# 'v' && line("'<") == line("'>")
    " action undefined for 'line-wise' or 'multi-line' visual mode selections
    call s:normalize_link_syntax_v()
  endif
endfunction "}}}

" }}}
