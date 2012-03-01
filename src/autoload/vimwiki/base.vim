" vim:tabstop=2:shiftwidth=2:expandtab:foldmethod=marker:textwidth=79
" Vimwiki autoload plugin file
" Author: Maxim Kim <habamax@gmail.com>
" Home: http://code.google.com/p/vimwiki/

if exists("g:loaded_vimwiki_auto") || &cp
  finish
endif
let g:loaded_vimwiki_auto = 1

if has("win32")
  let s:os_sep = '\'
else
  let s:os_sep = '/'
endif

let s:badsymbols = '['.g:vimwiki_badsyms.g:vimwiki_stripsym.'<>|?*:"]'

" MISC helper functions {{{

function! vimwiki#base#chomp_slash(str) "{{{
  return substitute(a:str, '[/\\]\+$', '', '')
endfunction "}}}

function! vimwiki#base#path_norm(path) "{{{
  return substitute(a:path, '\', '/', 'g')
endfunction "}}}

function! vimwiki#base#mkdir(path) "{{{
  let path = expand(a:path)
  if !isdirectory(path) && exists("*mkdir")
    let path = vimwiki#base#chomp_slash(path)
    if s:is_windows() && !empty(g:vimwiki_w32_dir_enc)
      let path = iconv(path, &enc, g:vimwiki_w32_dir_enc)
    endif
    call mkdir(path, "p")
  endif
endfunction
" }}}

function! vimwiki#base#safe_link(link) "{{{
  " handling Windows absolute paths
  if a:link =~ '^[[:alpha:]]:[/\\].*'
    let link_start = a:link[0 : 2]
    let link = a:link[3 : ]
  else
    let link_start = ''
    let link = a:link
  endif
  let link = substitute(link, s:badsymbols, g:vimwiki_stripsym, 'g')
  return link_start.link
endfunction
"}}}

function! vimwiki#base#unsafe_link(string) "{{{
  if len(g:vimwiki_stripsym) > 0
    return substitute(a:string, g:vimwiki_stripsym, s:badsymbols, 'g')
  else
    return a:string
  endif
endfunction
"}}}

function! vimwiki#base#subdir(path, filename)"{{{
  let path = expand(a:path)
  " ensure that we are not fooled by a symbolic link
  let filename = resolve(expand(a:filename))
  let idx = 0
  while path[idx] ==? filename[idx]
    let idx = idx + 1
  endwhile

  let p = split(strpart(filename, idx), '[/\\]')
  let res = join(p[:-2], s:os_sep)
  if len(res) > 0
    let res = res.s:os_sep
  endif
  return res
endfunction"}}}

function! vimwiki#base#current_subdir()"{{{
  return vimwiki#base#subdir(VimwikiGet('path'), expand('%:p'))
endfunction"}}}

function! vimwiki#base#resolve_scheme(lnk, wiki_output_ext) " {{{
  " schemeless
  let lnk = a:lnk
  let is_schemeless = lnk !~ g:vimwiki_rxSchemeUrl
  let lnk = (is_schemeless  ? 'wiki:'.lnk : lnk)
  " parse
  let scheme = matchstr(lnk, g:vimwiki_rxSchemeUrlMatchScheme)
  let lnk = matchstr(lnk, g:vimwiki_rxSchemeUrlMatchUrl)
  " scheme behaviors
  let numbered_scheme = 0
  let wiki_path = 0
  let diary_rel_path = 0
  let wiki_subdirectory = 0
  let make_link_safe = 0
  let wiki_extension = 0
  let wiki_directory = 0
  if scheme =~ 'wiki*'
    let numbered_scheme = 1
    let wiki_path = 1
    let wiki_subdirectory = 1
    let make_link_safe = 1
    let wiki_extension = 1
    let wiki_directory = 1
  elseif scheme =~ 'diary*'
    let numbered_scheme = 1
    let wiki_path = 1
    let diary_rel_path = 1
    let wiki_extension = 1
  elseif scheme =~ 'local*'
    let numbered_scheme = 1
    let wiki_path = 1
    let wiki_subdirectory = 1
  endif
  " numbered scheme
  if numbered_scheme && scheme =~ '\D\+\d\+'
    let idx = eval(matchstr(scheme, '\D\+\zs\d\+\ze'))
    if idx < 0 || idx >= len(g:vimwiki_list)
      echom 'Vimwiki Error: Numbered scheme refers to a non-existent wiki!'
      return ['','','','','','']
    endif
  else
    let idx = g:vimwiki_current_idx
  endif
  " path
  let path = (wiki_path ? VimwikiGet('path', idx) : '')
  " relative path for diary
  let path = path. (diary_rel_path ? VimwikiGet('diary_rel_path', idx) : '')
  " subdir
  if wiki_subdirectory && idx == g:vimwiki_current_idx
    let subdir = vimwiki#base#current_subdir()
  else
    let subdir = ''
  endif
  " special chars
  let lnk = (make_link_safe ? vimwiki#base#safe_link(lnk) : lnk)
  " extension
  if wiki_extension
    let ext = VimwikiGet('ext', idx)
    if a:wiki_output_ext != ''
      let ext = a:wiki_output_ext
    endif
    " default link for directories
    if wiki_directory && vimwiki#base#is_link_to_dir(lnk)
      let ext = (g:vimwiki_dir_link != '' ? g:vimwiki_dir_link. ext : '')
    endif
  else
    let ext = ''
  endif
  let scheme = (is_schemeless ? '' : scheme)

  " construct url from parts
  if scheme == ''
    let url = subdir.lnk.ext
  elseif scheme=~'wiki\d*' || scheme=~'diary\d*' || scheme=~'local\d*'
    " prepend 'file:' for wiki: and local: schemes
    let url = 'file://'.path.subdir.lnk.ext
  else
    let url = scheme.':'.path.subdir.lnk.ext
  endif

  " result
  return [scheme, path, subdir, lnk, ext, url]
endfunction "}}}

function! vimwiki#base#open_link(cmd, link, ...) "{{{
  " nonzero wnum = a:1 selects an alternate wiki to open link: let idx = a:1 - 1
  " let idx = a:wnum - 1
  " resolve url
  let [scheme, path, subdir, lnk, ext, url] = 
        \ vimwiki#base#resolve_scheme(a:link, VimwikiGet('ext'))
  if lnk == ''
    echom 'Vimwiki Error: Unable to resolve link!'
    return
  endif
  let update_prev_link = (
        \ scheme == '' || 
        \ scheme =~ 'wiki*' || 
        \ scheme =~ 'diary*' ? 1 : 0)
  let use_weblink_handler = (
        \ scheme == '' || 
        \ scheme =~ 'wiki*' || 
        \ scheme =~ 'diary*' || 
        \ scheme =~ 'local*' || 
        \ scheme =~ 'file' ? 0 : 1)
  " update previous link for wiki pages
  if update_prev_link
    if a:0
      let vimwiki_prev_link = [a:1, []]
    elseif &ft == 'vimwiki'
      let vimwiki_prev_link = [expand('%:p'), getpos('.')]
    endif
  endif
  " open/edit
  if g:vimwiki_debug
    echom 'open_link: scheme='.scheme.', path='.path.', subdir='.subdir.', lnk='.lnk.', ext='.ext
  endif
  if use_weblink_handler
    call VimwikiWeblinkHandler(escape(url, '#'))
  else
    " rm duplicate /-chars
    call vimwiki#base#edit_file(a:cmd, 
          \ substitute(path.subdir.lnk.ext, '^/\+', '/', 'g'))
  endif
  " save previous link
  if update_prev_link && exists('vimwiki_prev_link')
    let b:vimwiki_prev_link = vimwiki_prev_link
  endif
endfunction
" }}}

function! vimwiki#base#select(wnum)"{{{
  if a:wnum < 1 || a:wnum > len(g:vimwiki_list)
    return
  endif
  if &ft == 'vimwiki'
    let b:vimwiki_idx = g:vimwiki_current_idx
  endif
  let g:vimwiki_current_idx = a:wnum - 1
endfunction
" }}}

function! vimwiki#base#generate_links()"{{{
  let links = s:get_links('*'.VimwikiGet('ext'))

  " We don't want link to itself.
  let cur_link = expand('%:t:r')
  call filter(links, 'v:val != cur_link')

  if len(links)
    call append(line('$'), '= Generated Links =')
  endif

  call sort(links)

  for link in links
    if s:is_wiki_word(link)
      call append(line('$'), '- '.link)
    else
      call append(line('$'), '- [['.link.']]')
    endif
  endfor
endfunction " }}}

function! vimwiki#base#goto(key) "{{{
    call vimwiki#base#edit_file(':e',
          \ VimwikiGet('path').
          \ a:key.
          \ VimwikiGet('ext'))
endfunction "}}}

function! vimwiki#base#backlinks() "{{{
    execute 'lvimgrep "\%(^\|[[:blank:][:punct:]]\)'.
          \ expand("%:t:r").
          \ '\([[:blank:][:punct:]]\|$\)" '. 
          \ escape(VimwikiGet('path').'**/*'.VimwikiGet('ext'), ' ')
endfunction "}}}

function! s:is_windows() "{{{
  return has("win32") || has("win64") || has("win95") || has("win16")
endfunction "}}}

function! s:is_path_absolute(path) "{{{
  return a:path =~ '^/.*' || a:path =~ '^[[:alpha:]]:[/\\].*'
endfunction "}}}

function! s:get_links(pat) "{{{
  " search all wiki files in 'path' and its subdirs.
  let subdir = vimwiki#base#current_subdir()

  " if current wiki is temporary -- was added by an arbitrary wiki file then do
  " not search wiki files in subdirectories. Or it would hang the system if
  " wiki file was created in $HOME or C:/ dirs.
  if VimwikiGet('temp') 
    let search_dirs = ''
  else
    let search_dirs = '**/'
  endif
  let globlinks = glob(VimwikiGet('path').subdir.search_dirs.a:pat)

  " remove extensions (and backup extensions too: .wiki~)
  let globlinks = substitute(globlinks, '\'.VimwikiGet('ext').'\~\?', "", "g")
  let links = split(globlinks, '\n')

  " remove paths
  let rem_path = escape(expand(VimwikiGet('path')).subdir, '\')
  call map(links, 'substitute(v:val, rem_path, "", "g")')

  " Remove trailing slashes.
  call map(links, 'substitute(v:val, "[/\\\\]*$", "", "g")')

  return links
endfunction "}}}

" Builtin cursor doesn't work right with unicode characters.
function! s:cursor(lnum, cnum) "{{{
    exe a:lnum
    exe 'normal! 0'.a:cnum.'|'
endfunction "}}}

function! s:filename(link) "{{{
  let result = vimwiki#base#safe_link(a:link)
  if a:link =~ '|'
    let result = vimwiki#base#safe_link(split(a:link, '|')[0])
  elseif a:link =~ ']['
    let result = vimwiki#base#safe_link(split(a:link, '][')[0])
  endif
  return result
endfunction
" }}}

function! s:is_wiki_word(str) "{{{
  if a:str =~ g:vimwiki_rxWikiWord && a:str !~ '[[:space:]\\/]'
    return 1
  endif
  return 0
endfunction
" }}}

function! vimwiki#base#edit_file(command, filename) "{{{
  let fname = escape(a:filename, '% ')
  call vimwiki#base#mkdir(fnamemodify(a:filename, ":p:h"))
  execute a:command.' '.fname
endfunction
" }}}

function! s:search_word(wikiRx, cmd) "{{{
  let match_line = search(a:wikiRx, 's'.a:cmd)
  if match_line == 0
    echomsg 'vimwiki: Wiki link not found.'
  endif
endfunction
" }}}

function! s:get_word_at_cursor(wikiRX) "{{{
  let col = col('.') - 1
  let line = getline('.')
  let ebeg = -1
  let cont = match(line, a:wikiRX, 0)
  while (ebeg >= 0 || (0 <= cont) && (cont <= col))
    let contn = matchend(line, a:wikiRX, cont)
    if (cont <= col) && (col < contn)
      let ebeg = match(line, a:wikiRX, cont)
      let elen = contn - ebeg
      break
    else
      let cont = match(line, a:wikiRX, contn)
    endif
  endwh
  if ebeg >= 0
    return strpart(line, ebeg, elen)
  else
    return ""
  endif
endf "}}}

function! s:strip_word(word) "{{{
  let result = a:word
  if strpart(a:word, 0, 2) == "[["
    " get rid of [[ and ]]
    let w = strpart(a:word, 2, strlen(a:word)-4)

    if w =~ '|'
      " we want "link" from [[link|link desc]]
      let w = split(w, "|")[0]
    elseif w =~ ']['
      " we want "link" from [[link][link desc]]
      let w = split(w, "][")[0]
    endif

    let result = vimwiki#base#safe_link(w)
  endif
  return result
endfunction
" }}}

function! vimwiki#base#is_non_wiki_link(lnk) "{{{
  let exts = '.\+\.\%('.
          \ join(split(g:vimwiki_file_exts, '\s*,\s*'), '\|').
          \ '\)$'
  if a:lnk =~ exts
    return 1
  endif
  return 0
endfunction "}}}

function! vimwiki#base#is_link_to_dir(link) "{{{
  " Check if link is to a directory.
  " It should be ended with \ or /.
  if a:link =~ '.\+[/\\]$'
    return 1
  endif
  return 0
endfunction " }}}

function! s:print_wiki_list() "{{{
  let idx = 0
  while idx < len(g:vimwiki_list)
    if idx == g:vimwiki_current_idx
      let sep = ' * '
      echohl PmenuSel
    else
      let sep = '   '
      echohl None
    endif
    echo (idx + 1).sep.VimwikiGet('path', idx)
    let idx += 1
  endwhile
  echohl None
endfunction
" }}}

function! s:update_wiki_link(fname, old, new) " {{{
  echo "Updating links in ".a:fname
  let has_updates = 0
  let dest = []
  for line in readfile(a:fname)
    if !has_updates && match(line, a:old) != -1
      let has_updates = 1
    endif
    call add(dest, substitute(line, a:old, escape(a:new, "&"), "g"))
  endfor
  " add exception handling...
  if has_updates
    call rename(a:fname, a:fname.'#vimwiki_upd#')
    call writefile(dest, a:fname)
    call delete(a:fname.'#vimwiki_upd#')
  endif
endfunction
" }}}

function! s:update_wiki_links_dir(dir, old_fname, new_fname) " {{{
  let old_fname = substitute(a:old_fname, '[/\\]', '[/\\\\]', 'g')
  let new_fname = a:new_fname
  let old_fname_r = old_fname
  let new_fname_r = new_fname

  " try WikiLink
  " try WikiIncl
  " try Weblink
  " try Imagelink
  if !s:is_wiki_word(new_fname) && s:is_wiki_word(old_fname)
    let new_fname_r = '[['.new_fname.']]'
  endif

  if !s:is_wiki_word(old_fname)
    let old_fname_r = '\[\[\zs'.vimwiki#base#unsafe_link(old_fname).
          \ '\ze\%(|.*\)\?\%(\]\[.*\)\?\]\]'
  else
    let old_fname_r = '!\@<!\<'.old_fname.'\>'
  endif

  let files = split(glob(VimwikiGet('path').a:dir.'*'.VimwikiGet('ext')), '\n')
  for fname in files
    call s:update_wiki_link(fname, old_fname_r, new_fname_r)
  endfor
endfunction
" }}}

function! s:tail_name(fname) "{{{
  let result = substitute(a:fname, ":", "__colon__", "g")
  let result = fnamemodify(result, ":t:r")
  let result = substitute(result, "__colon__", ":", "g")
  return result
endfunction "}}}

function! s:update_wiki_links(old_fname, new_fname) " {{{
  let old_fname = s:tail_name(a:old_fname)
  let new_fname = s:tail_name(a:new_fname)

  let subdirs = split(a:old_fname, '[/\\]')[: -2]

  " TODO: Use Dictionary here...
  let dirs_keys = ['']
  let dirs_vals = ['']
  if len(subdirs) > 0
    let dirs_keys = ['']
    let dirs_vals = [join(subdirs, '/').'/']
    let idx = 0
    while idx < len(subdirs) - 1
      call add(dirs_keys, join(subdirs[: idx], '/').'/')
      call add(dirs_vals, join(subdirs[idx+1 :], '/').'/')
      let idx = idx + 1
    endwhile
    call add(dirs_keys,join(subdirs, '/').'/')
    call add(dirs_vals, '')
  endif

  let idx = 0
  while idx < len(dirs_keys)
    let dir = dirs_keys[idx]
    let new_dir = dirs_vals[idx]
    call s:update_wiki_links_dir(dir, 
          \ new_dir.old_fname, new_dir.new_fname)
    let idx = idx + 1
  endwhile
endfunction " }}}

function! s:get_wiki_buffers() "{{{
  let blist = []
  let bcount = 1
  while bcount<=bufnr("$")
    if bufexists(bcount)
      let bname = fnamemodify(bufname(bcount), ":p")
      if bname =~ VimwikiGet('ext')."$"
        let bitem = [bname, getbufvar(bname, "vimwiki_prev_link")]
        call add(blist, bitem)
      endif
    endif
    let bcount = bcount + 1
  endwhile
  return blist
endfunction " }}}

function! s:open_wiki_buffer(item) "{{{
  call vimwiki#base#edit_file(':e', a:item[0])
  if !empty(a:item[1])
    call setbufvar(a:item[0], "vimwiki_prev_link", a:item[1])
  endif
endfunction " }}}

" }}}

" SYNTAX highlight {{{
function! s:add_target_syntax_ON(target) " {{{
  if g:vimwiki_debug > 1
    echom '[vimwiki_debug] syntax target > '.a:target
  endif
  let prefix0 = 'syntax match VimwikiLink `'
  let suffix0 = '` display contains=@NoSpell,VimwikiLinkRest,VimwikiLinkChar'
  let prefix1 = 'syntax match VimwikiLinkT `'
  let suffix1 = '` display contained'
  execute prefix0. a:target. suffix0
  execute prefix1. a:target. suffix1
endfunction "}}}

function! s:add_target_syntax_OFF(target) " {{{
  if g:vimwiki_debug > 1
    echom '[vimwiki_debug] syntax target > '.a:target
  endif
  let prefix0 = 'syntax match VimwikiNoExistsLink `'
  let suffix0 = '` display contains=@NoSpell,VimwikiNoExistsLinkRest,VimwikiNoExistsLinkChar'
  let prefix1 = 'syntax match VimwikiNoExistsLinkT `'
  let suffix1 = '` display contained'
  execute prefix0. a:target. suffix0
  execute prefix1. a:target. suffix1
endfunction "}}}


function! vimwiki#base#highlight_links() "{{{
  try
    syntax clear VimwikiNoExistsLink
    syntax clear VimwikiNoExistsLinkT
    syntax clear VimwikiLink
    syntax clear VimwikiLinkT
  catch
  endtry

  " use max highlighting - could be quite slow if there are too many wikifiles
  if VimwikiGet('maxhi')
    " WikiLink
    call s:add_target_syntax_OFF(g:vimwiki_rxWikiLink)
    " WikiIncl
    call s:add_target_syntax_OFF(g:vimwiki_rxWikiIncl)

    " Subsequently, links verified on vimwiki's path are highlighted as existing
    call s:highlight_existent_links()
  else
    " Wikilink
    call s:add_target_syntax_ON(g:vimwiki_rxWikiLink)
  endif

  " Weblink
  call s:add_target_syntax_ON(g:vimwiki_rxWeblink)

  " Image
  call s:add_target_syntax_ON(g:vimwiki_rxImagelink)

  " WikiLink
  " All remaining schemes except wiki: and wiki<idx>: where idx is index of
  " current wiki are highlighted automatically
  let other_wiki_schemes = filter(split(g:vimwiki_wiki_schemes, '\s*,\s*'), 
            \ 'v:val !~ "\\%(wiki\\>\\|wiki'.g:vimwiki_current_idx.'\\>\\)"')
  let rxScheme = '\%('.
        \ join(other_wiki_schemes, '\|'). '\|'.
        \ join(split(g:vimwiki_diary_schemes, '\s*,\s*'), '\|'). '\|'.
        \ join(split(g:vimwiki_local_schemes, '\s*,\s*'), '\|'). '\|'.
        \ join(split(g:vimwiki_web_schemes1, '\s*,\s*'), '\|').
        \ '\):'
  " a) match [[nonwiki-scheme-URL]]
  let target = vimwiki#base#apply_template(g:vimwiki_WikiLinkTemplate1,
        \ rxScheme.g:vimwiki_rxWikiLinkUrl, g:vimwiki_rxWikiLinkDescr, '')
  call s:add_target_syntax_ON(target)
  " b) match [[nonwiki-scheme-URL][DESCRIPTION]]
  let target = vimwiki#base#apply_template(g:vimwiki_WikiLinkTemplate2,
        \ rxScheme.g:vimwiki_rxWikiLinkUrl, g:vimwiki_rxWikiLinkDescr, '')
  call s:add_target_syntax_ON(target)

  " a) match {{nonwiki-scheme-URL}}
  let target = vimwiki#base#apply_template(g:vimwiki_WikiInclTemplate1,
        \ rxScheme.g:vimwiki_rxWikiInclUrl, g:vimwiki_rxWikiInclArgs, '')
  call s:add_target_syntax_ON(target)
  " b) match {{nonwiki-scheme-URL}[{...}]}
  let target = vimwiki#base#apply_template(g:vimwiki_WikiInclTemplate2,
        \ rxScheme.g:vimwiki_rxWikiInclUrl, g:vimwiki_rxWikiInclArgs, '')
  call s:add_target_syntax_ON(target)

endfunction "}}}

function! s:highlight_existent_links() "{{{
  " Links with subdirs should be highlighted for linux and windows separators
  " Change \ or / to [/\\]
  let os_p = '[/\\]'
  let os_p2 = escape(os_p, '\')

  " Wikilink
  " Conditional highlighting that depends on the existence of a wiki file or
  " directory is only available for 'wiki#:' links
  let links = s:get_links('*'.VimwikiGet('ext'))
  call map(links, 'substitute(v:val, os_p, os_p2, "g")')
  let rxScheme = '\%(\%(wiki\|wiki'.g:vimwiki_current_idx.'\):\)\?'
  for link in links
    let safe_link = vimwiki#base#unsafe_link(link)
    let safe_link = escape(safe_link , '~&$.*')

    " a) match WikiWord
    if g:vimwiki_camel_case &&
          \ link =~ g:vimwiki_rxWikiWord && !vimwiki#base#is_non_wiki_link(link)
      call s:add_target_syntax_ON('!\@<!\<'. link. '\>')
    endif
    " b) match [[URL]]
    let target = vimwiki#base#apply_template(g:vimwiki_WikiLinkTemplate1,
          \ rxScheme.safe_link, g:vimwiki_rxWikiLinkDescr, '')
    call s:add_target_syntax_ON(target)
    " c) match [[URL][DESCRIPTION]]
    let target = vimwiki#base#apply_template(g:vimwiki_WikiLinkTemplate2,
          \ rxScheme.safe_link, g:vimwiki_rxWikiLinkDescr, '')
    call s:add_target_syntax_ON(target)

    " a) match {{URL}}
    let target = vimwiki#base#apply_template(g:vimwiki_WikiInclTemplate1,
          \ rxScheme.safe_link, g:vimwiki_rxWikiInclArgs, '')
    call s:add_target_syntax_ON(target)
    " b) match {{URL}[{...}]}
    let target = vimwiki#base#apply_template(g:vimwiki_WikiInclTemplate2,
          \ rxScheme.safe_link, g:vimwiki_rxWikiInclArgs, '')
    call s:add_target_syntax_ON(target)

  endfor

  " Wikilink Dirs
  " Conditional highlighting that depends on the existence of a wiki file or
  " directory is only available for 'wiki#:' links
  let dirs = s:get_links('*/')
  call map(dirs, 'substitute(v:val, os_p, os_p2, "g")')
  for dir in dirs
    let safe_link = vimwiki#base#unsafe_link(dir)
    let safe_link = escape(safe_link , '~&$.*')
    let safe_link = safe_link.'[/\\]'

    " 1a) match [[DIRURL]]
    let target = vimwiki#base#apply_template(g:vimwiki_WikiLinkTemplate1,
          \ rxScheme.safe_link, g:vimwiki_rxWikiLinkDescr, '')
    call s:add_target_syntax_ON(target)
    " 2a) match [[DIRURL][DESCRIPTION]]
    let target = vimwiki#base#apply_template(g:vimwiki_WikiLinkTemplate2,
          \ rxScheme.safe_link, g:vimwiki_rxWikiLinkDescr, '')
    call s:add_target_syntax_ON(target)
  endfor

  " Deprecated
  " " Issue 103: Always highlight links to non-wiki files as existed.
  " let rxFileExt = '\%('.join(split(tolower(g:vimwiki_file_exts).','.
  "       \ toupper(g:vimwiki_file_exts), '\s*,\s*'), '\|').'\)'
  " let non_wiki_link = g:vimwiki_rxWikiLinkUrl. '\.'. rxFileExt
endfunction "}}}


function! vimwiki#base#hl_exists(hl) "{{{
  if !hlexists(a:hl)
    return 0
  endif
  redir => hlstatus
  exe "silent hi" a:hl
  redir END
  return (hlstatus !~ "cleared")
endfunction
"}}}

function! vimwiki#base#nested_syntax(filetype, start, end, textSnipHl) abort "{{{
" From http://vim.wikia.com/wiki/VimTip857
  let ft=toupper(a:filetype)
  let group='textGroup'.ft
  if exists('b:current_syntax')
    let s:current_syntax=b:current_syntax
    " Remove current syntax definition, as some syntax files (e.g. cpp.vim)
    " do nothing if b:current_syntax is defined.
    unlet b:current_syntax
  endif

  " Some syntax files set up iskeyword which might scratch vimwiki a bit.
  " Let us save and restore it later.
  " let b:skip_set_iskeyword = 1
  let is_keyword = &iskeyword

  execute 'syntax include @'.group.' syntax/'.a:filetype.'.vim'
  try
    execute 'syntax include @'.group.' after/syntax/'.a:filetype.'.vim'
  catch
  endtry

  let &iskeyword = is_keyword

  if exists('s:current_syntax')
    let b:current_syntax=s:current_syntax
  else
    unlet b:current_syntax
  endif
  execute 'syntax region textSnip'.ft.
        \ ' matchgroup='.a:textSnipHl.
        \ ' start="'.a:start.'" end="'.a:end.'"'.
        \ ' contains=@'.group.' keepend'

  " A workaround to Issue 115: Nested Perl syntax highlighting differs from
  " regular one.
  " Perl syntax file has perlFunctionName which is usually has no effect due to
  " 'contained' flag. Now we have 'syntax include' that makes all the groups
  " included as 'contained' into specific group. 
  " Here perlFunctionName (with quite an angry regexp "\h\w*[^:]") clashes with
  " the rest syntax rules as now it has effect being really 'contained'.
  " Clear it!
  if ft =~ 'perl'
    syntax clear perlFunctionName 
  endif
endfunction "}}}

"}}}

" WIKI functions {{{
function! vimwiki#base#find_next_link() "{{{
  call s:search_word(g:vimwiki_rxWikiLink.'\|'.g:vimwiki_rxWikiIncl.'\|'.g:vimwiki_rxWeblink.'\|'.g:vimwiki_rxImagelink, '')
endfunction
" }}}

function! vimwiki#base#find_prev_link() "{{{
  call s:search_word(g:vimwiki_rxWikiLink.'\|'.g:vimwiki_rxWikiIncl.'\|'.g:vimwiki_rxWeblink.'\|'.g:vimwiki_rxImagelink, 'b')
endfunction
" }}}

function! vimwiki#base#find_interwiki(prefix) "{{{
  if a:prefix == ""
    return -1
  endif
  let idx = 0
  while idx < len(g:vimwiki_list)
    if a:prefix == VimwikiGet('interwiki_prefix', idx)
      return idx
    endif
    let idx += 1
  endwhile
  return -1
endfunction "}}}

function! vimwiki#base#follow_link(split, ...) "{{{
  if a:split == "split"
    let cmd = ":split "
  elseif a:split == "vsplit"
    let cmd = ":vsplit "
  elseif a:split == "tabnew"
    let cmd = ":tabnew "
  else
    let cmd = ":e "
  endif

  " nonzero wnum selects an alternate wiki to open link
  " let wnum = a:wnum
  let wnum = 0
  " try WikiLink
  let lnk = matchstr(s:get_word_at_cursor(g:vimwiki_rxWikiLink),
        \ g:vimwiki_rxWikiLinkMatchUrl)
  if lnk != ""
    call vimwiki#base#open_link(cmd, lnk)
    return
  endif
  " try WikiIncl
  let lnk = matchstr(s:get_word_at_cursor(g:vimwiki_rxWikiIncl),
        \ g:vimwiki_rxWikiInclMatchUrl)
  if lnk != ""
    call vimwiki#base#open_link(cmd, lnk)
    return
  endif
  " try Weblink
  let lnk = matchstr(s:get_word_at_cursor(g:vimwiki_rxWeblink),
        \ g:vimwiki_rxWeblinkMatchUrl)
  if lnk != ""
    call VimwikiWeblinkHandler(escape(lnk, '#'))
    return
  endif
  " try Imagelink
  let lnk = matchstr(s:get_word_at_cursor(g:vimwiki_rxImagelink),
        \ g:vimwiki_rxImagelinkMatchUrl)
  if lnk != ""
    call VimwikiWeblinkHandler(escape(lnk, '#'))
    return
  endif

  if a:0 > 0
    execute "normal! ".a:1
  else		
    execute "normal! \n"
  endif

endfunction " }}}

function! vimwiki#base#go_back_link() "{{{
  if exists("b:vimwiki_prev_link")
    " go back to saved WikiWord
    let prev_word = b:vimwiki_prev_link
    execute ":e ".substitute(prev_word[0], '\s', '\\\0', 'g')
    call setpos('.', prev_word[1])
  endif
endfunction " }}}

function! vimwiki#base#goto_index(index) "{{{
  call vimwiki#base#select(a:index)
  call vimwiki#base#edit_file('e',
        \ VimwikiGet('path').VimwikiGet('index').VimwikiGet('ext'))
endfunction "}}}

function! vimwiki#base#delete_link() "{{{
  "" file system funcs
  "" Delete WikiWord you are in from filesystem
  let val = input('Delete ['.expand('%').'] (y/n)? ', "")
  if val != 'y'
    return
  endif
  let fname = expand('%:p')
  try
    call delete(fname)
  catch /.*/
    echomsg 'vimwiki: Cannot delete "'.expand('%:t:r').'"!'
    return
  endtry

  call vimwiki#base#go_back_link()
  execute "bdelete! ".escape(fname, " ")

  " reread buffer => deleted WikiWord should appear as non-existent
  if expand('%:p') != ""
    execute "e"
  endif
endfunction "}}}

function! vimwiki#base#rename_link() "{{{
  "" Rename WikiWord, update all links to renamed WikiWord
  let subdir = vimwiki#base#current_subdir()
  let old_fname = subdir.expand('%:t')

  " there is no file (new one maybe)
  if glob(expand('%:p')) == ''
    echomsg 'vimwiki: Cannot rename "'.expand('%:p').
          \'". It does not exist! (New file? Save it before renaming.)'
    return
  endif

  let val = input('Rename "'.expand('%:t:r').'" (y/n)? ', "")
  if val!='y'
    return
  endif

  let new_link = input('Enter new name: ', "")

  if new_link =~ '[/\\]'
    " It is actually doable but I do not have free time to do it.
    echomsg 'vimwiki: Cannot rename to a filename with path!'
    return
  endif

  " check new_fname - it should be 'good', not empty
  if substitute(new_link, '\s', '', 'g') == ''
    echomsg 'vimwiki: Cannot rename to an empty filename!'
    return
  endif
  if vimwiki#base#is_non_wiki_link(new_link)
    echomsg 'vimwiki: Cannot rename to a filename with extension (ie .txt .html)!'
    return
  endif

  let new_link = subdir.new_link
  let new_link = s:strip_word(new_link)
  let new_fname = VimwikiGet('path').s:filename(new_link).VimwikiGet('ext')

  " do not rename if word with such name exists
  let fname = glob(new_fname)
  if fname != ''
    echomsg 'vimwiki: Cannot rename to "'.new_fname.
          \ '". File with that name exist!'
    return
  endif
  " rename WikiWord file
  try
    echomsg "Renaming ".VimwikiGet('path').old_fname." to ".new_fname
    let res = rename(expand('%:p'), expand(new_fname))
    if res != 0
      throw "Cannot rename!"
    end
  catch /.*/
    echomsg 'vimwiki: Cannot rename "'.expand('%:t:r').'" to "'.new_fname.'"'
    return
  endtry

  let &buftype="nofile"

  let cur_buffer = [expand('%:p'),
        \getbufvar(expand('%:p'), "vimwiki_prev_link")]

  let blist = s:get_wiki_buffers()

  " save wiki buffers
  for bitem in blist
    execute ':b '.escape(bitem[0], ' ')
    execute ':update'
  endfor

  execute ':b '.escape(cur_buffer[0], ' ')

  " remove wiki buffers
  for bitem in blist
    execute 'bwipeout '.escape(bitem[0], ' ')
  endfor

  let setting_more = &more
  setlocal nomore

  " update links
  call s:update_wiki_links(old_fname, new_link)

  " restore wiki buffers
  for bitem in blist
    if bitem[0] != cur_buffer[0]
      call s:open_wiki_buffer(bitem)
    endif
  endfor

  call s:open_wiki_buffer([new_fname,
        \ cur_buffer[1]])
  " execute 'bwipeout '.escape(cur_buffer[0], ' ')

  echomsg old_fname." is renamed to ".new_fname

  let &more = setting_more
endfunction " }}}

function! vimwiki#base#ui_select()"{{{
  call s:print_wiki_list()
  let idx = input("Select Wiki (specify number): ")
  if idx == ""
    return
  endif
  call vimwiki#base#goto_index(idx)
endfunction
"}}}

" }}}

" TEXT OBJECTS functions {{{

function! vimwiki#base#TO_header(inner, visual) "{{{
  if !search('^\(=\+\).\+\1\s*$', 'bcW')
    return
  endif
  
  let sel_start = line("'<")
  let sel_end = line("'>")
  let block_start = line(".")
  let advance = 0

  let level = vimwiki#base#count_first_sym(getline('.'))

  let is_header_selected = sel_start == block_start 
        \ && sel_start != sel_end

  if a:visual && is_header_selected
    if level > 1
      let level -= 1
      call search('^\(=\{'.level.'\}\).\+\1\s*$', 'bcW')
    else
      let advance = 1
    endif
  endif

  normal! V

  if a:visual && is_header_selected
    call cursor(sel_end + advance, 0)
  endif

  if search('^\(=\{1,'.level.'}\).\+\1\s*$', 'W')
    call cursor(line('.') - 1, 0)
  else
    call cursor(line('$'), 0)
  endif

  if a:inner && getline(line('.')) =~ '^\s*$'
    let lnum = prevnonblank(line('.') - 1)
    call cursor(lnum, 0)
  endif
endfunction
"}}}

function! vimwiki#base#TO_table_cell(inner, visual) "{{{
  if col('.') == col('$')-1
    return
  endif

  if a:visual
    normal! `>
    let sel_end = getpos('.')
    normal! `<
    let sel_start = getpos('.')

    let firsttime = sel_start == sel_end

    if firsttime
      if !search('|\|\(-+-\)', 'cb', line('.'))
        return
      endif
      if getline('.')[virtcol('.')] == '+'
        normal! l
      endif
      if a:inner
        normal! 2l
      endif
      let sel_start = getpos('.')
    endif

    normal! `>
    call search('|\|\(-+-\)', '', line('.'))
    if getline('.')[virtcol('.')] == '+'
      normal! l
    endif
    if a:inner
      if firsttime || abs(sel_end[2] - getpos('.')[2]) != 2
        normal! 2h
      endif
    endif
    let sel_end = getpos('.')

    call setpos('.', sel_start)
    exe "normal! \<C-v>"
    call setpos('.', sel_end)

    " XXX: WORKAROUND.
    " if blockwise selection is ended at | character then pressing j to extend
    " selection furhter fails. But if we shake the cursor left and right then
    " it works.
    normal! hl
  else
    if !search('|\|\(-+-\)', 'cb', line('.'))
      return
    endif
    if a:inner
      normal! 2l
    endif
    normal! v
    call search('|\|\(-+-\)', '', line('.'))
    if !a:inner && getline('.')[virtcol('.')-1] == '|'
      normal! h
    elseif a:inner
      normal! 2h
    endif
  endif
endfunction "}}}

function! vimwiki#base#TO_table_col(inner, visual) "{{{
  let t_rows = vimwiki#tbl#get_rows(line('.'))
  if empty(t_rows)
    return
  endif

  " TODO: refactor it!
  if a:visual
    normal! `>
    let sel_end = getpos('.')
    normal! `<
    let sel_start = getpos('.')

    let firsttime = sel_start == sel_end

    if firsttime
      " place cursor to the top row of the table
      call s:cursor(t_rows[0][0], virtcol('.'))
      " do not accept the match at cursor position if cursor is next to column
      " separator of the table separator (^ is a cursor):
      " |-----^-+-------|
      " | bla   | bla   |
      " |-------+-------|
      " or it will select wrong column.
      if strpart(getline('.'), virtcol('.')-1) =~ '^-+'
        let s_flag = 'b'
      else
        let s_flag = 'cb'
      endif
      " search the column separator backwards
      if !search('|\|\(-+-\)', s_flag, line('.'))
        return
      endif
      " -+- column separator is matched --> move cursor to the + sign
      if getline('.')[virtcol('.')] == '+'
        normal! l
      endif
      " inner selection --> reduce selection
      if a:inner
        normal! 2l
      endif
      let sel_start = getpos('.')
    endif

    normal! `>
    if !firsttime && getline('.')[virtcol('.')] == '|'
      normal! l
    elseif a:inner && getline('.')[virtcol('.')+1] =~ '[|+]'
      normal! 2l
    endif
    " search for the next column separator
    call search('|\|\(-+-\)', '', line('.'))
    " Outer selection selects a column without border on the right. So we move
    " our cursor left if the previous search finds | border, not -+-.
    if getline('.')[virtcol('.')] != '+'
      normal! h
    endif
    if a:inner
      " reduce selection a bit more if inner.
      normal! h
    endif
    " expand selection to the bottom line of the table
    call s:cursor(t_rows[-1][0], virtcol('.'))
    let sel_end = getpos('.')

    call setpos('.', sel_start)
    exe "normal! \<C-v>"
    call setpos('.', sel_end)

  else
    " place cursor to the top row of the table
    call s:cursor(t_rows[0][0], virtcol('.'))
    " do not accept the match at cursor position if cursor is next to column
    " separator of the table separator (^ is a cursor):
    " |-----^-+-------|
    " | bla   | bla   |
    " |-------+-------|
    " or it will select wrong column.
    if strpart(getline('.'), virtcol('.')-1) =~ '^-+'
      let s_flag = 'b'
    else
      let s_flag = 'cb'
    endif
    " search the column separator backwards
    if !search('|\|\(-+-\)', s_flag, line('.'))
      return
    endif
    " -+- column separator is matched --> move cursor to the + sign
    if getline('.')[virtcol('.')] == '+'
      normal! l
    endif
    " inner selection --> reduce selection
    if a:inner
      normal! 2l
    endif

    exe "normal! \<C-V>"

    " search for the next column separator
    call search('|\|\(-+-\)', '', line('.'))
    " Outer selection selects a column without border on the right. So we move
    " our cursor left if the previous search finds | border, not -+-.
    if getline('.')[virtcol('.')] != '+'
      normal! h
    endif
    " reduce selection a bit more if inner.
    if a:inner
      normal! h
    endif
    " expand selection to the bottom line of the table
    call s:cursor(t_rows[-1][0], virtcol('.'))
  endif
endfunction "}}}

function! vimwiki#base#count_first_sym(line) "{{{
  let first_sym = matchstr(a:line, '\S')
  return len(matchstr(a:line, first_sym.'\+'))
endfunction "}}}

function! vimwiki#base#AddHeaderLevel() "{{{
  let lnum = line('.')
  let line = getline(lnum)
  let rxHdr = g:vimwiki_rxH
  if line =~ '^\s*$'
    return
  endif

  if line =~ g:vimwiki_rxHeader
    let level = vimwiki#base#count_first_sym(line)
    if level < 6
      if g:vimwiki_symH
        let line = substitute(line, '\('.rxHdr.'\+\).\+\1', rxHdr.'&'.rxHdr, '')
      else
        let line = substitute(line, '\('.rxHdr.'\+\).\+', rxHdr.'&', '')
      endif
      call setline(lnum, line)
    endif
  else
    let line = substitute(line, '^\s*', '&'.rxHdr.' ', '') 
    if g:vimwiki_symH
      let line = substitute(line, '\s*$', ' '.rxHdr.'&', '')
    endif
    call setline(lnum, line)
  endif
endfunction
"}}}

function! vimwiki#base#RemoveHeaderLevel() "{{{
  let lnum = line('.')
  let line = getline(lnum)
  let rxHdr = g:vimwiki_rxH
  if line =~ '^\s*$'
    return
  endif

  if line =~ g:vimwiki_rxHeader
    let level = vimwiki#base#count_first_sym(line)
    let old = repeat(rxHdr, level)
    let new = repeat(rxHdr, level - 1)

    let chomp = line =~ rxHdr.'\s'

    if g:vimwiki_symH
      let line = substitute(line, old, new, 'g')
    else
      let line = substitute(line, old, new, '')
    endif

    if level == 1 && chomp
      let line = substitute(line, '^\s', '', 'g')
      let line = substitute(line, '\s$', '', 'g')
    endif

    let line = substitute(line, '\s*$', '', '')

    call setline(lnum, line)
  endif
endfunction
" }}}


function! s:replace_text(lnum, str, sub) " {{{
  call setline(a:lnum, substitute(getline(a:lnum), a:str.'\V', a:sub, ''))
endfunction " }}}

function! vimwiki#base#apply_template(template, rxUrl, rxDesc, rxStyle) "{{{
  let magic_chars = '.*[]\^$'
  let lnk = escape(a:template, magic_chars)
  let escape_chars = '\'
  let url = escape(a:rxUrl, escape_chars)
  let descr = escape(a:rxDesc, escape_chars)
  let style = escape(a:rxStyle, escape_chars)
  if a:rxUrl != ""
    let lnk = substitute(lnk, '__LinkUrl__', url, '') 
  endif
  if a:rxDesc != ""
    let lnk = substitute(lnk, '__LinkDescription__', descr, '')
  endif
  if a:rxStyle != ""
    let lnk = substitute(lnk, '__LinkStyle__', style, '')
  endif
  return lnk
endfunction
" }}}

function! s:clean_url(url) " {{{
  let url = split(a:url, '/\|=\|-\|&\|?\|\.')
  let url = filter(url, 'v:val != ""')
  let url = filter(url, 'v:val != "www"')
  let url = filter(url, 'v:val != "com"')
  let url = filter(url, 'v:val != "org"')
  let url = filter(url, 'v:val != "net"')
  let url = filter(url, 'v:val != "edu"')
  let url = filter(url, 'v:val != "http\:"')
  let url = filter(url, 'v:val != "https\:"')
  let url = filter(url, 'v:val != "file\:"')
  let url = filter(url, 'v:val != "xml\:"')
  return join(url, " ")
endfunction " }}}

function! s:normalize_link(str, rxUrl, rxDesc, template) " {{{
  let str = escape(a:str, "~")
  let url = matchstr(str, a:rxUrl)
  let descr = matchstr(str, a:rxDesc)
  let template = a:template
  if descr == ""
    let descr = s:clean_url(url)
  endif
  let lnk = substitute(template, '__LinkDescription__', descr, '')
  let lnk = substitute(lnk, '__LinkUrl__', url, '')
  return lnk
endfunction " }}}

function! s:normalize_weblink(str, rxUrl, rxDesc, template) " {{{
  let lnk = s:normalize_link(a:str, a:rxUrl, a:rxDesc, a:template)
  return escape(lnk, "&")
endfunction " }}}

function! s:normalize_wikilink(str, rxUrl, rxDesc, template) "{{{
  let lnk = s:normalize_link(a:str, a:rxUrl, a:rxDesc, a:template)
  return escape(lnk, "&")
endfunction
" }}}

function! s:normalize_imagelink(str, rxUrl, rxDesc, rxStyle, template) "{{{
  let lnk = s:normalize_link(a:str, a:rxUrl, a:rxDesc, a:template)
  let style = matchstr(str, a:rxStyle)
  let lnk = substitute(lnk, '__LinkStyle__', style, '')
  return escape(lnk, "&")
endfunction
" }}}

function! s:normalize_link_syntax_n(wiki_link_at_cursor, wiki_incl_at_cursor,
      \ web_link_at_cursor, image_link_at_cursor) " {{{
  let lnum = line('.')

  " try WikiLink
  if !empty(a:wiki_link_at_cursor)
    let sub = s:normalize_wikilink(a:wiki_link_at_cursor,
          \ g:vimwiki_rxWikiLinkMatchUrl, g:vimwiki_rxWikiLinkMatchDescr,
          \ g:vimwiki_WikiLinkTemplate2)
    call s:replace_text(lnum, g:vimwiki_rxWikiLink, sub)
    if g:vimwiki_debug > 1
      echomsg "WikiLink: ".a:wiki_link_at_cursor." Sub: ".sub
    endif
    return
  endif
  " try WikiIncl
  if !empty(a:wiki_incl_at_cursor)
    " NO-OP !!
    if g:vimwiki_debug > 1
      echomsg "WikiIncl: ".a:wiki_incl_at_cursor." Sub: ".a:wiki_incl_at_cursor
    endif
    return
  endif
  " try Weblink
  if !empty(a:web_link_at_cursor)
    let sub = s:normalize_weblink(a:web_link_at_cursor,
          \ g:vimwiki_rxWeblinkMatchUrl, g:vimwiki_rxWeblinkMatchDescr,
          \ VimwikiGet('web_template'))
    call s:replace_text(lnum, g:vimwiki_rxWeblink, sub)
    if g:vimwiki_debug > 1
      echomsg "WebLink: ".a:web_link_at_cursor." Sub: ".sub
    endif
    return
  endif
  " try Image link
  if !empty(a:image_link_at_cursor)
    let sub = s:normalize_imagelink(a:image_link_at_cursor,
          \ g:vimwiki_rxImagelinkMatchUrl, g:vimwiki_rxImagelinkMatchDescr,
          \ g:vimwiki_rxImagelinkMatchStyle, VimwikiGet('image_template'))
    call s:replace_text(lnum, g:vimwiki_rxImagelink, sub)
    if g:vimwiki_debug > 1
      echomsg "ImageLink: ".a:wiki_link_at_cursor." Sub: ".sub
    endif
    return
  endif

endfunction " }}}

function! s:normalize_link_syntax_v(wiki_link_at_cursor, wiki_incl_at_cursor,
      \ web_link_at_cursor, image_link_at_cursor) " {{{
  let lnum = line('.')
  let sel_save = &selection
  let &selection = "old"
  let rv = @"
  let rt = getregtype('"')
  let done = 0

  try
    norm! gvy
    let visual_selection = @"

    " try WikiLink - substituting link_at_cursor, not buffer @"
    if !done && visual_selection =~ g:vimwiki_rxWikiLink
      call setreg('"', s:normalize_wikilink(a:wiki_link_at_cursor,
            \ g:vimwiki_rxWikiLinkMatchUrl, g:vimwiki_rxWikiLinkMatchDescr,
            \ g:vimwiki_WikiLinkTemplate2), 'v')
      if g:vimwiki_debug > 1
        echomsg 'WikiLink: '.visual_selection.' Sub: '.@"
      endif
    endif
    let done = empty(a:wiki_link_at_cursor) ? done : 1
    " try WikiIncl - substituting link_at_cursor, not buffer @"
    if !done && visual_selection =~ g:vimwiki_rxWikiLink
      " call setreg('"', s:normalize_wikilink(a:wiki_link_at_cursor,
      "       \ g:vimwiki_rxWikiLinkMatchUrl, g:vimwiki_rxWikiLinkMatchDescr,
      "       \ g:vimwiki_WikiLinkTemplate2), 'v')
      if g:vimwiki_debug > 1
        echomsg 'WikiLink: '.visual_selection.' Sub: '.visual_selection
      endif
    endif
    let done = empty(a:wiki_incl_at_cursor) ? done : 1
    " try Weblink - substituting link_at_cursor, not buffer @"
    if visual_selection =~ g:vimwiki_rxWeblink
      call setreg('"', s:normalize_weblink(a:web_link_at_cursor, 
            \ g:vimwiki_rxWeblinkMatchUrl, g:vimwiki_rxWeblinkMatchDescr, 
            \ VimwikiGet('web_template')), 'v')
      let done = 1
      if g:vimwiki_debug > 1
        echomsg 'Weblink: '.visual_selection.' Sub: '.@"
      endif
    endif
    let done = empty(a:web_link_at_cursor) ? done : 1
    " try Imagelink - substituting link_at_cursor, not buffer @"
    if !done && visual_selection =~ g:vimwiki_rxImagelink
      call setreg('"', s:normalize_imagelink(a:image_link_at_cursor,
            \ g:vimwiki_rxImagelinkMatchUrl, g:vimwiki_rxImagelinkMatchDescr, 
            \ g:vimwiki_rxImagelinkMatchStyle, VimwikiGet('image_template')), 'v')
      let done = 1
      if g:vimwiki_debug > 1
        echomsg 'Image: '.visual_selection.' Sub: '.@"
      endif
    endif
    let done = empty(a:image_link_at_cursor) ? done : 1
    " try WikiWord - substituting link_at_cursor, not buffer @"
    if !done && visual_selection =~ g:vimwiki_rxWikiLinkUrl
      call setreg('"', s:normalize_wikilink(@", g:vimwiki_rxWikiLinkUrl,
            \ '', g:vimwiki_WikiLinkTemplate2), 'v')
      if g:vimwiki_debug > 1
        echomsg 'WikiLinkUrl: '.visual_selection.' Sub: '.@"
      endif
    endif

    " paste result
    norm! `>pgvd

  finally
    call setreg('"', rv, rt)
    let &selection = sel_save
  endtry

endfunction " }}}

function! vimwiki#base#NormalizeLinkSyntax(is_visual_mode) "{{{
  let wiki_link_at_cursor = s:get_word_at_cursor(g:vimwiki_rxWikiLink)
  let wiki_incl_at_cursor = s:get_word_at_cursor(g:vimwiki_rxWikiIncl)
  let web_link_at_cursor = s:get_word_at_cursor(g:vimwiki_rxWeblink)
  let image_link_at_cursor = s:get_word_at_cursor(g:vimwiki_rxImagelink)

  if !a:is_visual_mode
    call s:normalize_link_syntax_n(wiki_link_at_cursor, wiki_incl_at_cursor,
          \ web_link_at_cursor, image_link_at_cursor)

  elseif visualmode() ==# 'v' && line("'<") == line("'>")
    " action undefined for 'line-wise' or 'multi-line' visual mode selections
    call s:normalize_link_syntax_v(wiki_link_at_cursor, wiki_incl_at_cursor,
          \ web_link_at_cursor, image_link_at_cursor)
  endif

endfunction "}}}

" }}}

