" vim:tabstop=2:shiftwidth=2:expandtab:foldmethod=marker:textwidth=79
" Vimwiki autoload plugin file
" Desc: Handle diary notes
" Author: Maxim Kim <habamax@gmail.com>
" Home: http://code.google.com/p/vimwiki/

" Load only once {{{
if exists("g:loaded_vimwiki_diary_auto") || &cp
  finish
endif
let g:loaded_vimwiki_diary_auto = 1
"}}}

let g:vimwiki_max_scan_for_caption = 20

function! s:prefix_zero(num) "{{{
  if a:num < 10
    return '0'.a:num
  endif
  return a:num
endfunction "}}}

function! s:get_date_link(fmt) "{{{
  return strftime(a:fmt)
endfunction "}}}

function! s:link_exists(lines, link) "{{{
  let link_exists = 0
  for line in a:lines
    if line =~ escape(a:link, '[]\')
      let link_exists = 1
      break
    endif
  endfor
  return link_exists
endfunction "}}}

function! s:diary_path() "{{{
  return VimwikiGet('path').VimwikiGet('diary_rel_path')
endfunction "}}}

function! s:diary_index() "{{{
  return s:diary_path().VimwikiGet('diary_index').VimwikiGet('ext')
endfunction "}}}

function! s:diary_date_link() "{{{
  return s:get_date_link(VimwikiGet('diary_link_fmt'))
endfunction "}}}

function! s:get_position_links(link) "{{{
  let idx = -1
  let links = []
  if a:link =~ '^\d\{4}-\d\d-\d\d'
    let links = keys(s:get_diary_links())
    " include 'today' into links
    if index(links, s:diary_date_link()) == -1
      call add(links, s:diary_date_link())
    endif
    call sort(links)
    let idx = index(links, a:link)
  endif
  return [idx, links]
endfunction "}}}

fun! s:get_month_name(month) "{{{
  return g:vimwiki_diary_months[str2nr(a:month)]
endfun "}}}

function! s:trim(string) "{{{
  let res = substitute(a:string, '^\s\+', '', '')
  let res = substitute(res, '\s\+$', '', '')
  return res
endfunction "}}}


fun! s:read_captions(files) "{{{
  let result = {}
  for fl in a:files
    " remove paths and extensions
    let fl_key = fnamemodify(fl, ':t:r')

    if filereadable(fl)
      for line in readfile(fl, '', g:vimwiki_max_scan_for_caption)
        if line =~ g:vimwiki_rxHeader && !has_key(result, fl_key)
          let result[fl_key] = s:trim(matchstr(line, g:vimwiki_rxHeader))
        endif
      endfor
    endif

    if !has_key(result, fl_key)
      let result[fl_key] = ''
    endif

  endfor
  return result
endfun "}}}

fun! s:get_diary_links(...) "{{{
  let rx = '^\d\{4}-\d\d-\d\d'
  let s_files = glob(VimwikiGet('path').VimwikiGet('diary_rel_path').'*'.VimwikiGet('ext'))
  let files = split(s_files, '\n')
  call filter(files, 'fnamemodify(v:val, ":t") =~ "'.escape(rx, '\').'"')

  " remove backup files (.wiki~)
  call filter(files, 'v:val !~ ''.*\~$''')

  if a:0
    call add(files, a:1)
  endif
  let links_with_captions = s:read_captions(files)

  return links_with_captions
endfun "}}}

fun! s:group_links(links) "{{{
  let result = {}
  let p_year = 0
  let p_month = 0
  for fl in sort(keys(a:links))
    let year = strpart(fl, 0, 4)
    let month = strpart(fl, 5, 2)
    if p_year != year
      let result[year] = {}
      let p_month = 0
    endif
    if p_month != month
      let result[year][month] = {}
    endif
    let result[year][month][fl] = a:links[fl]
    let p_year = year
    let p_month = month
  endfor
  return result
endfun "}}}

fun! s:sort(lst) "{{{
  if VimwikiGet("diary_sort") == 'desc'
    return reverse(sort(a:lst))
  else
    return sort(a:lst)
  endif
endfun "}}}

fun! s:format_diary(...) "{{{
  let result = []

  call add(result, substitute(g:vimwiki_rxH1_Template, '__Header__', VimwikiGet('diary_header'), ''))

  if a:0
    let g_files = s:group_links(s:get_diary_links(a:1))
  else
    let g_files = s:group_links(s:get_diary_links())
  endif

  " for year in s:rev(sort(keys(g_files)))
  for year in s:sort(keys(g_files))
    call add(result, '')
    call add(result, substitute(g:vimwiki_rxH2_Template, '__Header__', year , ''))

    " for month in s:rev(sort(keys(g_files[year])))
    for month in s:sort(keys(g_files[year]))
      call add(result, '')
      call add(result, substitute(g:vimwiki_rxH3_Template, '__Header__', s:get_month_name(month), ''))

      " for [fl, cap] in s:rev(sort(items(g_files[year][month])))
      for [fl, cap] in s:sort(items(g_files[year][month]))
        if empty(cap)
          let entry = substitute(g:vimwiki_WikiLinkTemplate1, '__LinkUrl__', fl, '')
          let entry = substitute(entry, '__LinkDescription__', cap, '')
          call add(result, repeat(' ', &sw).'* '.entry)
        else
          let entry = substitute(g:vimwiki_WikiLinkTemplate2, '__LinkUrl__', fl, '')
          let entry = substitute(entry, '__LinkDescription__', cap, '')
          call add(result, repeat(' ', &sw).'* '.entry)
        endif
      endfor

    endfor
  endfor
  call add(result, '')

  return result
endfun "}}}

function! s:get_file_contents(fname) "{{{
  " read contents of diary index into buffer
  let fname = expand(a:fname)
  let lines = []
  if bufnr(fname) == -1
    let lines = readfile(fname)
  else
    let lines = getbufline(bufnr(fname), 1, '$')
  endif
  return lines
endfunction "}}}

function! s:set_file_contents(fname, lines) "{{{
  " save contents of diary index with lines
  let fname = expand(a:fname)
  if bufnr(fname) == -1
    call writefile(a:lines, fname)
  else
    exe 'buffer '.bufnr(fname)
    if !&readonly
      1,$delete _
      call append(1, a:lines)
      1,1delete _
    endif
  endif
endfunction "}}}

function! s:set_diary_section(lines, diary_lines) "{{{
  " remove diary section
  let lines = a:lines
  let ln_start = match(lines, substitute(g:vimwiki_rxH1_Template, '__Header__', VimwikiGet('diary_header'), ''))
  let ln_end = match(lines, g:vimwiki_rxH1, ln_start+1)

  if ln_end < 0
    let ln_end = len(lines)
  endif

  if ln_start > -1
    call remove(lines, ln_start, ln_end-1)
  endif

  if ln_start < 0
    let ln_start = 0
  endif

  call extend(lines, a:diary_lines, ln_start)

endfunction "}}}

function! s:add_link(diaryfile, newlink) "{{{
  let fname = expand(a:diaryfile)
  if filereadable(fname)
    let lines = s:get_file_contents(fname)
  else
    let lines = []
  endif

  call s:set_diary_section(lines, s:format_diary(a:newlink))

  call s:set_file_contents(fname, lines)
endfunction "}}}

function! s:make_date_link(...) "{{{
  if a:0
    let newlink = a:1
  else
    let newlink = s:diary_date_link()
  endif
  call s:add_link(s:diary_index(), newlink)
  return newlink
endfunction "}}}

function! vimwiki#diary#make_note(index, ...) "{{{
  " XXX: prevent auto_export of index, issue:293
  let prev_auto_export = VimwikiGet('auto_export')
  call VimwikiSet('auto_export', 0)
  " XXX: force loading of appropriate syntax to avoid issue:290
  call vimwiki#diary#goto_index(a:index)
  "call vimwiki#base#select(a:index)
  call vimwiki#base#mkdir(VimwikiGet('path').VimwikiGet('diary_rel_path'))
  if a:0
    let link = 'diary:'.s:make_date_link(a:1)
  else
    let link = 'diary:'.s:make_date_link()
  endif
  call vimwiki#base#open_link(':e ', link, s:diary_index())
  " XXX: prevent auto_export of index, issue:293
  call VimwikiSet('auto_export', prev_auto_export)
endfunction "}}}

function! vimwiki#diary#goto_index(index) "{{{
  call vimwiki#base#select(a:index)
  call vimwiki#base#edit_file(':e', s:diary_index())
endfunction "}}}

" Calendar.vim callback function.
function! vimwiki#diary#calendar_action(day, month, year, week, dir) "{{{
  let day = s:prefix_zero(a:day)
  let month = s:prefix_zero(a:month)

  let link = a:year.'-'.month.'-'.day
  if winnr('#') == 0
    if a:dir == 'V'
      vsplit
    else
      split
    endif
  else
    wincmd p
    if !&hidden && &modified
      new
    endif
  endif

  " Create diary note for a selected date in default wiki.
  call vimwiki#diary#make_note(1, link)
endfunction "}}}

" Calendar.vim sign function.
function vimwiki#diary#calendar_sign(day, month, year) "{{{
  let day = s:prefix_zero(a:day)
  let month = s:prefix_zero(a:month)
  let sfile = VimwikiGet('path').VimwikiGet('diary_rel_path').
        \ a:year.'-'.month.'-'.day.VimwikiGet('ext')
  return filereadable(expand(sfile))
endfunction "}}}

function! vimwiki#diary#goto_next_day() "{{{
  let link = ''
  let [idx, links] = s:get_position_links(expand('%:t:r'))

  if idx == (len(links) - 1)
    return
  endif

  if idx != -1 && idx < len(links) - 1
    let link = 'diary:'.links[idx+1]
  else
    " goto today
    let link = 'diary:'.s:diary_date_link()
  endif

  if len(link)
    call vimwiki#base#open_link(':e ', link)
  endif
endfunction "}}}

function! vimwiki#diary#goto_prev_day() "{{{
  let link = ''
  let [idx, links] = s:get_position_links(expand('%:t:r'))

  if idx == 0
    return
  endif

  if idx > 0
    let link = 'diary:'.links[idx-1]
  else
    " goto today
    let link = 'diary:'.s:diary_date_link()
  endif

  if len(link)
    call vimwiki#base#open_link(':e ', link)
  endif
endfunction "}}}
