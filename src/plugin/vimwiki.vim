" vim:tabstop=2:shiftwidth=2:expandtab:foldmethod=marker:textwidth=79
" Vimwiki plugin file
" Author: Maxim Kim <habamax@gmail.com>
" Home: http://code.google.com/p/vimwiki/
" GetLatestVimScripts: 2226 1 :AutoInstall: vimwiki

if exists("loaded_vimwiki") || &cp
  finish
endif
let loaded_vimwiki = 1

let s:old_cpo = &cpo
set cpo&vim

" HELPER functions {{{
function! s:default(varname, value) "{{{
  if !exists('g:vimwiki_'.a:varname)
    let g:vimwiki_{a:varname} = a:value
  endif
endfunction "}}}

" return longest common path prefix of 2 given paths.
" '~/home/usrname/wiki', '~/home/usrname/wiki/shmiki' => '~/home/usrname/wiki'
function! s:path_common_pfx(path1, path2) "{{{
  let p1 = split(a:path1, '[/\\]', 1)
  let p2 = split(a:path2, '[/\\]', 1)

  let idx = 0
  let minlen = min([len(p1), len(p2)])
  while (idx < minlen) && (p1[idx] ==? p2[idx])
    let idx = idx + 1
  endwhile
  if idx == 0
    return ''
  else
    return join(p1[: idx-1], '/')
  endif
endfunction "}}}

function! s:find_wiki(path) "{{{
  " ensure that we are not fooled by a symbolic link
  let realpath = resolve(vimwiki#base#chomp_slash(a:path))
  let idx = 0
  while idx < len(g:vimwiki_list)
    let path = vimwiki#base#chomp_slash(expand(VimwikiGet('path', idx)))
    let path = vimwiki#base#path_norm(path)
    if s:path_common_pfx(path, realpath) == path
      return idx
    endif
    let idx += 1
  endwhile
  return -1
endfunction "}}}

function! s:setup_buffer_leave()"{{{
  if &filetype == 'vimwiki' && !exists("b:vimwiki_idx")
    let b:vimwiki_idx = g:vimwiki_current_idx
  endif

  " Set up menu
  if g:vimwiki_menu != ""
    exe 'nmenu disable '.g:vimwiki_menu.'.Table'
  endif
endfunction"}}}

function! s:setup_filetype() "{{{
  " Find what wiki current buffer belongs to.
  let path = expand('%:p:h')
  let ext = '.'.expand('%:e')
  let idx = s:find_wiki(path)

  if idx == -1 && g:vimwiki_global_ext == 0
    return
  endif

  set filetype=vimwiki
endfunction "}}}

function! s:setup_buffer_enter() "{{{
  if exists("b:vimwiki_idx")
    let g:vimwiki_current_idx = b:vimwiki_idx
  else
    " Find what wiki current buffer belongs to.
    " If wiki does not exist in g:vimwiki_list -- add new wiki there with
    " buffer's path and ext.
    " Else set g:vimwiki_current_idx to that wiki index.
    let path = expand('%:p:h')
    let ext = '.'.expand('%:e')
    let idx = s:find_wiki(path)

    " The buffer's file is not in the path and user do not want his wiki
    " extension to be global -- do not add new wiki.
    if idx == -1 && g:vimwiki_global_ext == 0
      return
    endif

    if idx == -1
      call add(g:vimwiki_list, {'path': path, 'ext': ext, 'temp': 1})
      let g:vimwiki_current_idx = len(g:vimwiki_list) - 1
    else
      let g:vimwiki_current_idx = idx
    endif

    let b:vimwiki_idx = g:vimwiki_current_idx
  endif

  " If you have
  "     au GUIEnter * VimwikiIndex
  " Then change it to
  "     au GUIEnter * nested VimwikiIndex
  if &filetype == ''
    set filetype=vimwiki
  endif

  " Update existed/non-existed links highlighting.
  call vimwiki#base#highlight_links()

  " Settings foldmethod, foldexpr and foldtext are local to window. Thus in a
  " new tab with the same buffer folding is reset to vim defaults. So we
  " insist vimwiki folding here.
  if g:vimwiki_folding == 1 && &fdm != 'expr'
    setlocal fdm=expr
    setlocal foldexpr=VimwikiFoldLevel(v:lnum)
    setlocal foldtext=VimwikiFoldText()
  endif

  " And conceal level too.
  if g:vimwiki_conceallevel && exists("+conceallevel")
    let &conceallevel = g:vimwiki_conceallevel
  endif

  " Set up menu
  if g:vimwiki_menu != ""
    exe 'nmenu enable '.g:vimwiki_menu.'.Table'
  endif
endfunction "}}}

function! s:get_suffix(template, tag) "{{{
  let match_end = matchend(a:template, a:tag)
  let match_end = (match_end > 0) ? match_end : 0
  return a:template[match_end :]
endfunction "}}}

function! s:get_unique_chars(str) "{{{
  let char_dict = {}
  for chr in split(a:str, '\zs')
    let char_dict[chr] = 1
  endfor
  return join(keys(char_dict), '')
endfunction "}}}

" OPTION get/set functions {{{
" return value of option for current wiki or if second parameter exists for
" wiki with a given index.
function! VimwikiGet(option, ...) "{{{
  if a:0 == 0
    let idx = g:vimwiki_current_idx
  else
    let idx = a:1
  endif
  if !has_key(g:vimwiki_list[idx], a:option) &&
        \ has_key(s:vimwiki_defaults, a:option)
    if a:option == 'path_html'
      let g:vimwiki_list[idx][a:option] =
            \VimwikiGet('path', idx)[:-2].'_html/'
    else
      let g:vimwiki_list[idx][a:option] =
            \s:vimwiki_defaults[a:option]
    endif
  endif

  " if path's ending is not a / or \
  " then add it
  if a:option == 'path' || a:option == 'path_html'
    let p = g:vimwiki_list[idx][a:option]
    " resolve doesn't work quite right with symlinks ended with / or \
    let p = vimwiki#base#chomp_slash(p)
    let p = resolve(expand(p))
    let g:vimwiki_list[idx][a:option] = p.'/'
  endif

  return g:vimwiki_list[idx][a:option]
endfunction "}}}

" set option for current wiki or if third parameter exists for
" wiki with a given index.
function! VimwikiSet(option, value, ...) "{{{
  if a:0 == 0
    let idx = g:vimwiki_current_idx
  else
    let idx = a:1
  endif
  let g:vimwiki_list[idx][a:option] = a:value
endfunction "}}}
" }}}

" }}}

" CALLBACK function "{{{
" User can redefine it.
if !exists("*VimwikiWeblinkHandler") "{{{
  function VimwikiWeblinkHandler(weblink)
    " handlers
    function! s:win32_handler(weblink)
      "execute '!start ' . shellescape(a:weblink, 1)
      "http://vim.wikia.com/wiki/Opening_current_Vim_file_in_your_Windows_browser
      execute 'silent ! start "Title" /B ' . shellescape(a:weblink, 1)
    endfunction
    function! s:macunix_handler(weblink)
      execute '!open ' . shellescape(a:weblink, 1)
    endfunction
    function! s:linux_handler(weblink)
      execute 'silent !xdg-open ' . shellescape(a:weblink, 1)
    endfunction
    let success = 0
    " check win32/macunix/? 
    try 
      if has("win32")
        call s:win32_handler(a:weblink)
        return
      endif
      if has("macunix")
        call s:macunix_handler(a:weblink)
        return
      endif
    endtry
    " check executable
    try
      if executable('start')
        call s:win32_handler(a:weblink)
        return
      endif
      if executable('open')
        call s:macunix_handler(a:weblink)
        return
      endif
      if executable('xdg-open')
        call s:linux_handler(a:weblink)
        return
      endif
    endtry

    echomsg 'Default Vimwiki Weblink Handler was unable to open the HTML file!'
  endfunction
endif "}}}
" CALLBACK }}}

if !exists("*VimwikiWikiIncludeHandler") "{{{
  function! VimwikiWikiIncludeHandler(value) "{{{
    " {{imgurl}}                -> <img src="imgurl"/>
    " {{imgurl}{descr}{style}}  -> <img src="imgurl" alt="descr" style="style" />
    " ???
    " {{imgurl}{arg1}{arg2}}    -> ???
    let str = a:value
    if match(str, g:vimwiki_wikiword_escape_prefix) == 0
      return a:value[len(g:vimwiki_wikiword_escape_prefix):]
    endif
    let url = matchstr(str, g:vimwiki_rxWikiInclMatchUrl)

    " resolve url
    let [scheme, path, subdir, lnk, ext] = vimwiki#base#resolve_scheme(url, '.html')

    " construct url from parts
    if scheme == ''
      let url = subdir.lnk.ext
    elseif scheme=~'wiki\d*' || scheme=~'diary\d*' || scheme=~'local\d*'
      " prepend 'file:' for wiki: and local: schemes
      let url = 'file://'.path.subdir.lnk.ext
    else
      let url = scheme.':'.path.subdir.lnk.ext
    endif

    "echom 'transclude url = '.url

    " Include image
    if url =~ g:vimwiki_rxImagelinkUrl.'$'
      let descr = matchstr(str, VimwikiWikiInclMatchArg(1))
      let style = matchstr(str, VimwikiWikiInclMatchArg(2))

      " generate html output
      if g:vimwiki_debug
        echom '{{scheme='.scheme.', path='.path.', subdir='.subdir.', lnk='.lnk.', ext='.ext.'}}'
      endif
      let url = escape(url, '#')
      let line = vimwiki#html#linkify_image(url, descr, style)
      return line
    endif
     
    " Additional handlers ...

    " Otherwise
    return str

  endfunction "}}}
endif "}}}
" CALLBACK }}}

" DEFAULT wiki {{{
let s:vimwiki_defaults = {}
let s:vimwiki_defaults.path = '~/vimwiki/'
let s:vimwiki_defaults.path_html = '~/vimwiki_html/'
let s:vimwiki_defaults.css_name = 'style.css'
let s:vimwiki_defaults.index = 'index'
let s:vimwiki_defaults.ext = '.wiki'
let s:vimwiki_defaults.maxhi = 1
let s:vimwiki_defaults.syntax = 'default'

let s:vimwiki_defaults.template_path = ''
let s:vimwiki_defaults.template_default = ''
let s:vimwiki_defaults.template_ext = ''

let s:vimwiki_defaults.nested_syntaxes = {}
let s:vimwiki_defaults.auto_export = 0
" is wiki temporary -- was added to g:vimwiki_list by opening arbitrary wiki
" file.
let s:vimwiki_defaults.temp = 0

" diary
let s:vimwiki_defaults.diary_rel_path = 'diary/'
let s:vimwiki_defaults.diary_index = 'diary'
let s:vimwiki_defaults.diary_header = 'Diary'
let s:vimwiki_defaults.diary_sort = 'desc'

" Do not change this! Will wait till vim become more datetime awareable.
let s:vimwiki_defaults.diary_link_fmt = '%Y-%m-%d'

let s:vimwiki_defaults.interwiki_prefix = ''
let s:vimwiki_defaults.interwiki_domain = ''

" NEW! in v1.3
" custom_wiki2html
let s:vimwiki_defaults.custom_wiki2html = ''

" NEW! in v1.3
" wikilink, wikiincl separators (should not be the same)
"let s:vimwiki_defaults.wikilink_separator = ']['
"let s:vimwiki_defaults.wikiincl_separator = '}{'
let s:vimwiki_defaults.link_separator = ']['
let s:vimwiki_defaults.incl_separator = '}{'

" NEW! in v1.3
" web_template, image_template
" TODO: move to 'syntax/vimwiki_xxx.vim' ... !!
let s:vimwiki_defaults.web_template = 
      \ '[__LinkUrl__ __LinkDescription__]'
let s:vimwiki_defaults.image_template = 
      \ '{__LinkUrl__|__LinkDescription__|__LinkStyle__}'
"
"}}}

" DEFAULT options {{{
call s:default('list', [s:vimwiki_defaults])
if &encoding == 'utf-8'
  call s:default('upper', 'A-Z\u0410-\u042f')
  call s:default('lower', 'a-z\u0430-\u044f')
else
  call s:default('upper', 'A-Z')
  call s:default('lower', 'a-z')
endif
call s:default('stripsym', '_')
call s:default('badsyms', '')
call s:default('auto_checkbox', 1)
call s:default('use_mouse', 0)
call s:default('folding', 0)
call s:default('fold_trailing_empty_lines', 0)
call s:default('fold_lists', 0)
call s:default('menu', 'Vimwiki')
call s:default('global_ext', 1)
call s:default('hl_headers', 0)
call s:default('hl_cb_checked', 0)
call s:default('camel_case', 0)
call s:default('list_ignore_newline', 1)
call s:default('listsyms', ' .oOX')
call s:default('use_calendar', 1)
call s:default('table_mappings', 1)
call s:default('table_auto_fmt', 1)
call s:default('w32_dir_enc', '')
call s:default('CJK_length', 0)
call s:default('dir_link', '')
call s:default('file_exts', 'pdf,txt,doc,rtf,xls,php,zip,rar,7z,html,gz')
call s:default('image_exts', 'jpg,jpeg,png,gif')
call s:default('valid_html_tags', 'b,i,s,u,sub,sup,kbd,br,hr,div,center,strong,em')
call s:default('user_htmls', '')

call s:default('html_header_numbering', 0)
call s:default('html_header_numbering_sym', '')
call s:default('conceallevel', 2)
call s:default('url_mingain', 12)
call s:default('url_maxsave', 12)
call s:default('debug', 0)

call s:default('wikiword_escape_prefix', '!')

call s:default('diary_months', 
      \ {
      \ 1: 'January', 2: 'February', 3: 'March', 
      \ 4: 'April', 5: 'May', 6: 'June',
      \ 7: 'July', 8: 'August', 9: 'September',
      \ 10: 'October', 11: 'November', 12: 'December'
      \ })


call s:default('current_idx', 0)
"}}}

"
" LINKS: Schemes and Interwikis {{{
let g:vimwiki_web_schemes1 = 'http,https,file,ftp,gopher,telnet,nntp,ldap'.','.
      \ 'rsync,imap,pop,irc,ircs,cvs,svn,svn+ssh,git,ssh,fish,sftp,notes'.','. 
      \ 'ms-help'
let g:vimwiki_web_schemes2 = 'mailto,news,xmpp,sip,sips,doi,urn,tel'

let g:vimwiki_wiki_schemes = 'wiki'.','.
      \ 'wiki0,wiki1,wiki2,wiki3,wiki4,wiki5,wiki6,wiki7,wiki8,wiki9'
let g:vimwiki_diary_schemes = 'diary'.','.
      \ 'diary0,diary1,diary2,diary3,diary4,diary5,diary6,diary7,diary8,diary9'
let g:vimwiki_local_schemes = 'local'.','.
      \ 'local0,local1,local2,local3,local4,local5,local6,local7,local8,local9'

let rxSchemes = '\%('. 
      \ join(split(g:vimwiki_wiki_schemes, '\s*,\s*'), '\|').'\|'.
      \ join(split(g:vimwiki_diary_schemes, '\s*,\s*'), '\|').'\|'.
      \ join(split(g:vimwiki_local_schemes, '\s*,\s*'), '\|').'\|'.
      \ join(split(g:vimwiki_web_schemes1, '\s*,\s*'), '\|').'\|'. 
      \ join(split(g:vimwiki_web_schemes2, '\s*,\s*'), '\|').
      \ '\)'

let g:vimwiki_rxSchemeUrl = rxSchemes.':.*'
let g:vimwiki_rxSchemeUrlMatchScheme = '\zs'.rxSchemes.'\ze:.*'
let g:vimwiki_rxSchemeUrlMatchUrl = rxSchemes.':\zs.*\ze'
" }}}

"
" LINKS: WikiLinks  {{{
let wword = '\C\<\%(['.g:vimwiki_upper.']['.g:vimwiki_lower.']\+\)\{2,}\>'

" 0. WikiWordURLs
" 0a) match WikiWordURLs
let g:vimwiki_rxWikiWord = g:vimwiki_wikiword_escape_prefix.'\@<!'.wword
let g:vimwiki_rxNoWikiWord = g:vimwiki_wikiword_escape_prefix.wword
"
" TODO: put these in 'syntax/vimwiki_xxx.vim'
let g:vimwiki_rxWikiLinkPrefix = '[['
let g:vimwiki_rxWikiLinkSuffix = ']]'
let g:vimwiki_rxWikiLinkSeparator = VimwikiGet('link_separator')
" [[URL]]
let g:vimwiki_WikiLinkTemplate1 = g:vimwiki_rxWikiLinkPrefix . '__LinkUrl__'. 
      \ g:vimwiki_rxWikiLinkSuffix
" [[URL][DESCRIPTION]]
let g:vimwiki_WikiLinkTemplate2 = g:vimwiki_rxWikiLinkPrefix . '__LinkUrl__'. 
      \ g:vimwiki_rxWikiLinkSeparator. '__LinkDescription__'.
      \ g:vimwiki_rxWikiLinkSuffix
"
let magic_chars = '.*[]\^$'
let exclude_chars = g:vimwiki_rxWikiLinkPrefix.g:vimwiki_rxWikiLinkSeparator.
      \ g:vimwiki_rxWikiLinkSuffix
let exclude_chars = s:get_unique_chars(exclude_chars)
let valid_chars = '[^'.escape(exclude_chars, magic_chars).']'
"
let g:vimwiki_rxWikiLinkPrefix = escape(g:vimwiki_rxWikiLinkPrefix, magic_chars)
let g:vimwiki_rxWikiLinkSuffix = escape(g:vimwiki_rxWikiLinkSuffix, magic_chars)
let g:vimwiki_rxWikiLinkSeparator = escape(g:vimwiki_rxWikiLinkSeparator, magic_chars)
let g:vimwiki_rxWikiLinkSeparator = '\%('.g:vimwiki_rxWikiLinkSeparator.'\)\?'
let g:vimwiki_rxWikiLinkUrl = valid_chars.'\+'
let g:vimwiki_rxWikiLinkDescr = valid_chars.'*'
"
" 1. [[URL]], or [[URL][DESCRIPTION]]
" 1a) match [[URL][DESCRIPTION]]
let g:vimwiki_rxWikiLink = g:vimwiki_rxWikiLinkPrefix.
      \ g:vimwiki_rxWikiLinkUrl. g:vimwiki_rxWikiLinkSeparator.
      \ g:vimwiki_rxWikiLinkDescr. g:vimwiki_rxWikiLinkSuffix
" 1b) match URL within [[URL][DESCRIPTION]]
let g:vimwiki_rxWikiLinkMatchUrl = g:vimwiki_rxWikiLinkPrefix.
      \ '\zs'. g:vimwiki_rxWikiLinkUrl. '\ze'. g:vimwiki_rxWikiLinkSeparator.
      \ g:vimwiki_rxWikiLinkDescr. g:vimwiki_rxWikiLinkSuffix
" 1c) match DESCRIPTION within [[URL][DESCRIPTION]]
let g:vimwiki_rxWikiLinkMatchDescr = g:vimwiki_rxWikiLinkPrefix.
      \ g:vimwiki_rxWikiLinkUrl. g:vimwiki_rxWikiLinkSeparator.
      \ '\zs'. g:vimwiki_rxWikiLinkDescr. '\ze'. g:vimwiki_rxWikiLinkSuffix
"
" *. wikilink or wikiword
if g:vimwiki_camel_case
  " *a) match ANY wikilink or wikiword
  let g:vimwiki_rxWikiLink = g:vimwiki_rxWikiLink.'\|'. g:vimwiki_rxWikiWord
  " *b) match URL wikilink or wikiword
  let g:vimwiki_rxWikiLinkMatchUrl = g:vimwiki_rxWikiLinkMatchUrl.'\|'.
        \ g:vimwiki_rxWikiWord
endif
"}}}


"
" LINKS: WikiIncl {{{
"
" TODO: put these in 'syntax/vimwiki_xxx.vim'
let g:vimwiki_rxWikiInclPrefix = '{{'
let g:vimwiki_rxWikiInclSuffix = '}}'
let g:vimwiki_rxWikiInclSeparator = VimwikiGet('incl_separator')
"
" '{{__LinkUrl__}}'
let g:vimwiki_WikiInclTemplate1 = g:vimwiki_rxWikiInclPrefix . '__LinkUrl__'. 
      \ g:vimwiki_rxWikiInclSuffix
" '{{__LinkUrl____LinkDescription__}}'
let g:vimwiki_WikiInclTemplate2 = g:vimwiki_rxWikiInclPrefix . '__LinkUrl__'. 
      \ '__LinkDescription__'.
      \ g:vimwiki_rxWikiInclSuffix
"
let magic_chars = '.*[]\^$'
let exclude_chars = g:vimwiki_rxWikiInclPrefix. g:vimwiki_rxWikiInclSeparator.
      \ g:vimwiki_rxWikiInclSuffix
let exclude_chars = s:get_unique_chars(exclude_chars)
let valid_chars = '[^'.escape(exclude_chars, magic_chars).']'
"
let g:vimwiki_rxWikiInclPrefix = escape(g:vimwiki_rxWikiInclPrefix, magic_chars)
let g:vimwiki_rxWikiInclSuffix = escape(g:vimwiki_rxWikiInclSuffix, magic_chars)
let g:vimwiki_rxWikiInclSeparator = escape(g:vimwiki_rxWikiInclSeparator, magic_chars)
let g:vimwiki_rxWikiInclUrl = valid_chars.'\+'
let g:vimwiki_rxWikiInclArg = valid_chars.'*'
let g:vimwiki_rxWikiInclArgs = '\%('. g:vimwiki_rxWikiInclSeparator. g:vimwiki_rxWikiInclArg. '\)'.'*'
"
"
" *. {{URL}[{...}]}  - i.e.  {{URL}}, {{URL}{ARG1}}, {{URL}{ARG1}{ARG2}}, etc.
" *a) match {{URL}[{...}]}
let g:vimwiki_rxWikiIncl = g:vimwiki_rxWikiInclPrefix.
      \ g:vimwiki_rxWikiInclUrl. 
      \ g:vimwiki_rxWikiInclArgs. g:vimwiki_rxWikiInclSuffix
" *b) match URL within {{URL}[{...}]}
let g:vimwiki_rxWikiInclMatchUrl = g:vimwiki_rxWikiInclPrefix.
      \ '\zs'. g:vimwiki_rxWikiInclUrl. '\ze'.
      \ g:vimwiki_rxWikiInclArgs. g:vimwiki_rxWikiInclSuffix
" *c,d,e),...
"   match n-th ARG within {{URL}[{ARG1}{ARG2}{...}]}
function! VimwikiWikiInclMatchArg(nn_index)
  let rx = g:vimwiki_rxWikiInclPrefix. g:vimwiki_rxWikiInclUrl
  let rx = rx. repeat(g:vimwiki_rxWikiInclSeparator. g:vimwiki_rxWikiInclArg, a:nn_index-1)
  if a:nn_index > 0
    let rx = rx. g:vimwiki_rxWikiInclSeparator. '\zs'. g:vimwiki_rxWikiInclArg. '\ze'
  endif
  let rx = rx. g:vimwiki_rxWikiInclArgs. g:vimwiki_rxWikiInclSuffix
  return rx
endfunction
"}}}


"
" LINKS: WebLinks {{{
" match URL for common protocols;  XXX ms-help ??
" see http://en.wikipedia.org/wiki/URI_scheme  http://tools.ietf.org/html/rfc3986
let g:vimwiki_rxWebProtocols = ''.
      \ '\%('.
        \ '\%('.
          \ '\%('.join(split(g:vimwiki_web_schemes1, '\s*,\s*'), '\|').'\):'.
          \ '\%(\%(//\)\|\%(\\\\\)\)'.
        \ '\)'.
      \ '\|'.
        \ '\%('.join(split(g:vimwiki_web_schemes2, '\s*,\s*'), '\|').'\):'.
      \ '\)'
"
let g:vimwiki_rxWeblinkUrl = g:vimwiki_rxWebProtocols .
    \ '\S\{-1,}'. '\%(([^ \t()]*)\)\='

" FIXME all submatches can be done with "numbered" \( \) groups
" 0. URL : free-standing links: keep URL UR(L) strip trailing punct: URL; URL) UR(L)) 
let g:vimwiki_rxWeblink0 = '[\["(|]\@<!'. g:vimwiki_rxWeblinkUrl .
      \ '\%([),:;.!?]\=\%([ \t]\|$\)\)\@='
" 0a) match URL within URL
let g:vimwiki_rxWeblinkMatchUrl0 = g:vimwiki_rxWeblink0
" 0b) match DESCRIPTION within URL
let g:vimwiki_rxWeblinkMatchDescr0 = ''
"
let template_args = '\%(__LinkUrl__\|__LinkDescription__\)'
let web_template = VimwikiGet('web_template')
if g:vimwiki_debug
  echom 'Weblink Template: '.web_template
endif
let magic_chars = '.*[]\^$'
" list all delimiters that appear in Template *after* DESCRIPTION
let exclude_chars = s:get_suffix(web_template, '__LinkDescription__')
let exclude_chars = join(split(exclude_chars, template_args), '')
let exclude_chars = s:get_unique_chars(exclude_chars)
let valid_chars = '[^'.escape(exclude_chars, magic_chars).']'
let g:vimwiki_rxWeblinkDescr = valid_chars.'*'
"
" " 2012-02-04 TODO not starting with [[ or ][ ?  ... prefix = '[\[\]]\@<!\[' 
" 1. web template
let g:vimwiki_rxWeblink1 = vimwiki#base#apply_template(web_template, 
      \ g:vimwiki_rxWeblinkUrl, 
      \ g:vimwiki_rxWeblinkDescr, 
      \ '')
" 1a) match URL within web template
let g:vimwiki_rxWeblinkMatchUrl1 = vimwiki#base#apply_template(web_template,
      \ '\zs'.g:vimwiki_rxWeblinkUrl.'\ze', 
      \ g:vimwiki_rxWeblinkDescr, 
      \ '')
" 1b) match DESCRIPTION within web template
let g:vimwiki_rxWeblinkMatchDescr1 = vimwiki#base#apply_template(web_template, 
      \ g:vimwiki_rxWeblinkUrl, 
      \ '\zs'.g:vimwiki_rxWeblinkDescr.'\ze', 
      \ '')
"
"
" *. ANY weblink
" *a) match ANY weblink
let g:vimwiki_rxWeblink = ''.
      \ g:vimwiki_rxWeblink1.'\|'.
      \ g:vimwiki_rxWeblink0
" *b) match URL within ANY weblink
let g:vimwiki_rxWeblinkMatchUrl = ''.
      \ g:vimwiki_rxWeblinkMatchUrl1.'\|'.
      \ g:vimwiki_rxWeblinkMatchUrl0
" *c) match DESCRIPTION within ANY weblink
let g:vimwiki_rxWeblinkMatchDescr = ''.
      \ g:vimwiki_rxWeblinkMatchDescr1.'\|'.
      \ g:vimwiki_rxWeblinkMatchDescr0
"
"}}}


"
" LINKS: Images {{{

" match URL
let g:vimwiki_rxImagelinkProtocols = ''.  
      \ '\%('.
        \ '\%('.join(split(g:vimwiki_web_schemes1, '\s*,\s*'), '\|'). '\):'.
        \ '\%(\%(//\)\|\%(\\\\\)\)'.
      \ '\)\?'
"
let g:vimwiki_rxImagelinkUrl = g:vimwiki_rxImagelinkProtocols .
    \ '\S\{-1,}'. '\%(([^ \t()]*)\)\=' .
    \ '\.'.
    \ '\%('.
      \ '\%('. join(split(tolower(g:vimwiki_image_exts), '\s*,\s*'), '\|'). '\)'.
      \ '\|'.
      \ '\%('. join(split(toupper(g:vimwiki_image_exts), '\s*,\s*'), '\|'). '\)'.
    \ '\)'

"
let template_args = '\%(__LinkUrl__\|__LinkDescription__\|__LinkStyle__\)'
let t_Image = VimwikiGet('image_template')
if g:vimwiki_debug
  echom 'Image Template: '.t_Image
endif
let magic_chars = '.*[]\^$'
" list all delimiters that appear in Template *after* DESCRIPTION
let exclude_chars = s:get_suffix(t_Image, '__LinkDescription__')
let exclude_chars = join(split(exclude_chars, template_args), '')
let exclude_chars = s:get_unique_chars(exclude_chars)
let valid_chars = '[^'.escape(exclude_chars, magic_chars).']'
let g:vimwiki_rxImagelinkDescr = valid_chars.'*'
" list all delimiters that appear in Template *after* STYLE
let exclude_chars = s:get_suffix(t_Image, '__LinkStyle__')
let exclude_chars = join(split(exclude_chars, template_args), '')
let exclude_chars = s:get_unique_chars(exclude_chars)
let valid_chars = '[^'.escape(exclude_chars, magic_chars).']'
let g:vimwiki_rxImagelinkStyle = valid_chars.'*'
"
"
" 1. image template
let g:vimwiki_rxImagelink1 = vimwiki#base#apply_template(t_Image, 
      \ g:vimwiki_rxImagelinkUrl, 
      \ g:vimwiki_rxImagelinkDescr,
      \ g:vimwiki_rxImagelinkStyle)
" 1a) match URL within image template
let g:vimwiki_rxImagelinkMatchUrl1 = vimwiki#base#apply_template(t_Image,
      \ '\zs'.g:vimwiki_rxImagelinkUrl.'\ze', 
      \ g:vimwiki_rxImagelinkDescr, 
      \ g:vimwiki_rxImagelinkStyle)
" 1b) match DESCRIPTION within image template
let g:vimwiki_rxImagelinkMatchDescr1 = vimwiki#base#apply_template(t_Image,
      \ g:vimwiki_rxImagelinkUrl, 
      \ '\zs'.g:vimwiki_rxImagelinkDescr.'\ze', 
      \ g:vimwiki_rxImagelinkStyle)
" 1c) match STYLE within image template
let g:vimwiki_rxImagelinkMatchStyle1 = vimwiki#base#apply_template(t_Image,
      \ g:vimwiki_rxImagelinkUrl, 
      \ g:vimwiki_rxImagelinkDescr,
      \ '\zs'.g:vimwiki_rxImagelinkStyle.'\ze')
" 
" *. ANY image
" *a) match ANY image
let g:vimwiki_rxImagelink = ''.
      \ g:vimwiki_rxImagelink1
" *b) match URL within ANY image
let g:vimwiki_rxImagelinkMatchUrl = ''.
      \ g:vimwiki_rxImagelinkMatchUrl1
" *c) match DESCRIPTION within ANY image
let g:vimwiki_rxImagelinkMatchDescr = ''.
      \ g:vimwiki_rxImagelinkMatchDescr1
" *c) match STYLE within ANY image
let g:vimwiki_rxImagelinkMatchStyle = ''.
      \ g:vimwiki_rxImagelinkMatchStyle1
"
"}}}


" AUTOCOMMANDS for all known wiki extensions {{{
" Getting all extensions that different wikies could have
let extensions = {}
for wiki in g:vimwiki_list
  if has_key(wiki, 'ext')
    let extensions[wiki.ext] = 1
  else
    let extensions['.wiki'] = 1
  endif
endfor

augroup filetypedetect
  " clear FlexWiki's stuff
  au! * *.wiki
augroup end

augroup vimwiki
  autocmd!
  for ext in keys(extensions)
    exe 'autocmd BufWinEnter *'.ext.' call s:setup_buffer_enter()'
    exe 'autocmd BufLeave,BufHidden *'.ext.' call s:setup_buffer_leave()'
    exe 'autocmd BufNewFile,BufRead, *'.ext.' call s:setup_filetype()'

    " ColorScheme could have or could have not a
    " VimwikiHeader1..VimwikiHeader6 highlight groups. We need to refresh
    " syntax after colorscheme change.
    exe 'autocmd ColorScheme *'.ext.' syntax enable'.
          \ ' | call vimwiki#base#highlight_links()'

    " Format tables when exit from insert mode. Do not use textwidth to
    " autowrap tables.
    if g:vimwiki_table_auto_fmt
      exe 'autocmd InsertLeave *'.ext.' call vimwiki#tbl#format(line("."))'
      exe 'autocmd InsertEnter *'.ext.' call vimwiki#tbl#reset_tw(line("."))'
    endif
  endfor
augroup END
"}}}

" COMMANDS {{{
command! VimwikiUISelect call vimwiki#base#ui_select()
command! -count VimwikiIndex
      \ call vimwiki#base#goto_index(v:count1)
command! -count VimwikiTabIndex tabedit <bar>
      \ call vimwiki#base#goto_index(v:count1)

command! -count VimwikiDiaryIndex
      \ call vimwiki#diary#goto_index(v:count1)
command! -count VimwikiMakeDiaryNote
      \ call vimwiki#diary#make_note(v:count1)
command! -count VimwikiTabMakeDiaryNote tabedit <bar>
      \ call vimwiki#diary#make_note(v:count1)
"}}}

" MAPPINGS {{{
if !hasmapto('<Plug>VimwikiIndex')
  nmap <silent><unique> <Leader>ww <Plug>VimwikiIndex
endif
nnoremap <unique><script> <Plug>VimwikiIndex :VimwikiIndex<CR>

if !hasmapto('<Plug>VimwikiTabIndex')
  nmap <silent><unique> <Leader>wt <Plug>VimwikiTabIndex
endif
nnoremap <unique><script> <Plug>VimwikiTabIndex :VimwikiTabIndex<CR>

if !hasmapto('<Plug>VimwikiUISelect')
  nmap <silent><unique> <Leader>ws <Plug>VimwikiUISelect
endif
nnoremap <unique><script> <Plug>VimwikiUISelect :VimwikiUISelect<CR>

if !hasmapto('<Plug>VimwikiDiaryIndex')
  nmap <silent><unique> <Leader>wi <Plug>VimwikiDiaryIndex
endif
nnoremap <unique><script> <Plug>VimwikiDiaryIndex :VimwikiDiaryIndex<CR>

if !hasmapto('<Plug>VimwikiMakeDiaryNote')
  nmap <silent><unique> <Leader>w<Leader>w <Plug>VimwikiMakeDiaryNote
endif
nnoremap <unique><script> <Plug>VimwikiMakeDiaryNote :VimwikiMakeDiaryNote<CR>

if !hasmapto('<Plug>VimwikiTabMakeDiaryNote')
  nmap <silent><unique> <Leader>w<Leader>t <Plug>VimwikiTabMakeDiaryNote
endif
nnoremap <unique><script> <Plug>VimwikiTabMakeDiaryNote
      \ :VimwikiTabMakeDiaryNote<CR>

"}}}

" MENU {{{
function! s:build_menu(topmenu)
  let idx = 0
  while idx < len(g:vimwiki_list)
    let norm_path = fnamemodify(VimwikiGet('path', idx), ':h:t')
    let norm_path = escape(norm_path, '\ \.')
    execute 'menu '.a:topmenu.'.Open\ index.'.norm_path.
          \ ' :call vimwiki#base#goto_index('.(idx + 1).')<CR>'
    execute 'menu '.a:topmenu.'.Open/Create\ diary\ note.'.norm_path.
          \ ' :call vimwiki#diary#make_note('.(idx + 1).')<CR>'
    let idx += 1
  endwhile
endfunction

function! s:build_table_menu(topmenu)
  exe 'menu '.a:topmenu.'.-Sep- :'
  exe 'menu '.a:topmenu.'.Table.Create\ (enter\ cols\ rows) :VimwikiTable '
  exe 'nmenu '.a:topmenu.'.Table.Format<tab>gqq gqq'
  exe 'nmenu '.a:topmenu.'.Table.Move\ column\ left<tab><A-Left> :VimwikiTableMoveColumnLeft<CR>'
  exe 'nmenu '.a:topmenu.'.Table.Move\ column\ right<tab><A-Right> :VimwikiTableMoveColumnRight<CR>'
  exe 'nmenu disable '.a:topmenu.'.Table'
endfunction

if !empty(g:vimwiki_menu)
  call s:build_menu(g:vimwiki_menu)
  call s:build_table_menu(g:vimwiki_menu)
endif
" }}}

" CALENDAR Hook "{{{
if g:vimwiki_use_calendar
  let g:calendar_action = 'vimwiki#diary#calendar_action'
  let g:calendar_sign = 'vimwiki#diary#calendar_sign'
endif
"}}}

let &cpo = s:old_cpo
