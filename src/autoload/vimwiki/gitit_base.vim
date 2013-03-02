" vim:tabstop=2:shiftwidth=2:expandtab:foldmethod=marker:textwidth=79
" Vimwiki autoload plugin file
" Desc: Link functions for gitit syntax
" Author: Macropodus <the.macropodus@gmail.com>
" Home: http://code.google.com/p/vimwiki/


" MISC helper functions {{{

" s:normalize_path
" s:path_html
" vimwiki#base#apply_wiki_options
" vimwiki#base#read_wiki_options
" vimwiki#base#validate_wiki_options
" vimwiki#base#setup_buffer_state
" vimwiki#base#cache_buffer_state
" vimwiki#base#recall_buffer_state
" vimwiki#base#print_wiki_state
" vimwiki#base#mkdir
" vimwiki#base#file_pattern
" vimwiki#base#branched_pattern
" vimwiki#base#subdir
" vimwiki#base#current_subdir
" vimwiki#base#invsubdir
" vimwiki#base#resolve_scheme
" vimwiki#base#system_open_link
" vimwiki#base#open_link
" vimwiki#base#generate_links
" vimwiki#base#goto
" vimwiki#base#backlinks
" vimwiki#base#get_links
" vimwiki#base#edit_file
" vimwiki#base#search_word
" vimwiki#base#matchstr_at_cursor
" vimwiki#base#replacestr_at_cursor
" s:print_wiki_list
" s:update_wiki_link
" s:update_wiki_links_dir
" s:tail_name
" s:update_wiki_links
" s:get_wiki_buffers
" s:open_wiki_buffer
" vimwiki#base#nested_syntax
" }}}

" WIKI link following functions {{{
" vimwiki#base#find_next_link
" vimwiki#base#find_prev_link

" vimwiki#base#follow_link
function! vimwiki#gitit_base#follow_link(split, ...) "{{{ Parse link at cursor and pass
  " to VimwikiLinkHandler, or failing that, the default open_link handler
  " echom "gitit_base#follow_link"

  if 0
    " Syntax-specific links
    " XXX: @Stuart: do we still need it?
    " XXX: @Maxim: most likely!  I am still working on a seemless way to
    " integrate regexp's without complicating syntax/vimwiki.vim
  else
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
    let lnk = matchstr(vimwiki#base#matchstr_at_cursor(g:vimwiki_rxWikiLink1),
          \ g:vimwiki_rxWikiLink1MatchUrl)
    if lnk == ""
      let lnk = matchstr(vimwiki#base#matchstr_at_cursor(g:vimwiki_rxWikiLink2),
          \ g:vimwiki_rxWikiLink2MatchUrl)
    endif

    if lnk != ""
      if !VimwikiLinkHandler(lnk)
        call vimwiki#base#open_link(cmd, lnk)
      endif
      return
    endif

    if a:0 > 0
      execute "normal! ".a:1
    else
      call vimwiki#base#normalize_link(0)
    endif
  endif

endfunction " }}}

" vimwiki#base#go_back_link
" vimwiki#base#goto_index
" vimwiki#base#delete_link
" vimwiki#base#rename_link
" vimwiki#base#ui_select

" TEXT OBJECTS functions {{{
" vimwiki#base#TO_header
" vimwiki#base#TO_table_cell
" vimwiki#base#TO_table_col
" }}}

" HEADER functions {{{
" vimwiki#base#AddHeaderLevel
" vimwiki#base#RemoveHeaderLevel
"}}}

" LINK functions {{{
" vimwiki#base#apply_template

" s:clean_url
" vimwiki#base#normalize_link_helper
" vimwiki#base#normalize_imagelink_helper

" s:normalize_link_syntax_n
" s:normalize_link_syntax_v
" vimwiki#base#normalize_link
" }}}

" -------------------------------------------------------------------------
" Load syntax-specific Wiki functionality
" -------------------------------------------------------------------------

