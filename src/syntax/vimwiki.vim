" vim:tabstop=2:shiftwidth=2:expandtab:foldmethod=marker:textwidth=79
" Vimwiki syntax file
" Author: Maxim Kim <habamax@gmail.com>
" Home: http://code.google.com/p/vimwiki/

" Quit if syntax file is already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif
"TODO do nothing if ...? (?)
let starttime = reltime()  " start the clock
if VimwikiGet('maxhi')
  let b:existing_wikifiles = vimwiki#base#get_links('*'.VimwikiGet('ext'))
  let b:existing_wikidirs  = vimwiki#base#get_links('*/')
endif
let timescans = vimwiki#base#time(starttime)  "XXX
  "let b:xxx = 1
  "TODO ? update wikilink syntax group here if really needed (?) for :e and such
  "if VimwikiGet('maxhi')
  " ...
  "endif


" LINKS: assume this is common to all syntaxes "{{{
" LINKS: Schemes and Interwikis {{{
let g:vimwiki_web_schemes1 = 'http,https,file,ftp,gopher,telnet,nntp,ldap,'.
      \ 'rsync,imap,pop,irc,ircs,cvs,svn,svn+ssh,git,ssh,fish,sftp'
let g:vimwiki_web_schemes2 = 'mailto,news,xmpp,sip,sips,doi,urn,tel'

let g:vimwiki_wiki_schemes = 'wiki\d\+'
let g:vimwiki_diary_schemes = 'diary'
let g:vimwiki_local_schemes = 'local'

let rxSchemes = '\%('. 
      \ g:vimwiki_wiki_schemes.'\|'.
      \ g:vimwiki_diary_schemes.'\|'.
      \ g:vimwiki_local_schemes.'\|'.
      \ join(split(g:vimwiki_web_schemes1, '\s*,\s*'), '\|').'\|'. 
      \ join(split(g:vimwiki_web_schemes2, '\s*,\s*'), '\|').
      \ '\)'

let g:vimwiki_rxSchemeUrl = rxSchemes.':.*'
let g:vimwiki_rxSchemeUrlMatchScheme = '\zs'.rxSchemes.'\ze:.*'
let g:vimwiki_rxSchemeUrlMatchUrl = rxSchemes.':\zs.*\ze'
" }}}

" LINKS: WikiLinks  {{{
" Words
" - more permissive than '\<\w\+\>' which uses 'iskeyword' characters
" - less permissive than rxWikiLinkUrl which uses non-separator characters
let g:vimwiki_rxWord = '\<\S\+\>'
" }}}

" LINKS: WebLinks {{{
" match URL for common protocols;
" see http://en.wikipedia.org/wiki/URI_scheme  http://tools.ietf.org/html/rfc3986
let g:vimwiki_rxWebProtocols = ''.
      \ '\%('.
        \ '\%('.
          \ '\%('.join(split(g:vimwiki_web_schemes1, '\s*,\s*'), '\|').'\):'.
          \ '\%(//\)'.
        \ '\)'.
      \ '\|'.
        \ '\%('.join(split(g:vimwiki_web_schemes2, '\s*,\s*'), '\|').'\):'.
      \ '\)'
"
let g:vimwiki_rxWeblinkUrl = g:vimwiki_rxWebProtocols .
    \ '\S\{-1,}'. '\%(([^ \t()]*)\)\='
" }}}

" LINKS: Images {{{

" match URL
let g:vimwiki_rxImagelinkProtocols = ''.  
      \ '\%('.
        \ '\%('.join(split(g:vimwiki_web_schemes1, '\s*,\s*'), '\|'). '\):'.
        \ '\%(//\)'.
      \ '\)\?'

let g:vimwiki_rxImagelinkUrl = g:vimwiki_rxImagelinkProtocols .
    \ '\S\{-1,}'. '\%(([^ \t()]*)\)\='
" }}}
" }}}

" -------------------------------------------------------------------------
" Load concrete Wiki syntax: sets regexes and templates for headers and links
execute 'runtime! syntax/vimwiki_'.VimwikiGet('syntax').'.vim'
" -------------------------------------------------------------------------
let time0 = vimwiki#base#time(starttime)  "XXX


" LINKS: setup of larger regexes {{{
function! s:get_prefix(template, tag) "{{{
  let match_start = match(a:template, a:tag)
  let prefix = (match_start > 0) ? a:template[: (match_start-1)] : ''
  return prefix
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

" LINKS: setup wikilink regexps {{{
let wword = '\C\<\%(['.g:vimwiki_upper.']['.g:vimwiki_lower.']\+\)\{2,}\>'
let g:vimwiki_wword = wword
" 0. WikiWordURLs
" 0a) match WikiWordURLs
let g:vimwiki_rxWikiWord = g:vimwiki_wikiword_escape_prefix.'\@<!'.wword
let g:vimwiki_rxNoWikiWord = g:vimwiki_wikiword_escape_prefix.wword
"
" TODO: put these in 'syntax/vimwiki_xxx.vim'
let g:vimwiki_rxWikiLinkPrefix = '[['
let g:vimwiki_rxWikiLinkSuffix = ']]'
let g:vimwiki_rxWikiLinkSeparator = g:vimwiki_link_separator
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
let g:vimwiki_rxWikiLinkSeparatorOpt = '\%('.g:vimwiki_rxWikiLinkSeparator.'\)\?'
let g:vimwiki_rxWikiLinkUrl = valid_chars.'\+'
let g:vimwiki_rxWikiLinkDescr = valid_chars.'*'
"
" 1. [[URL]], or [[URL][DESCRIPTION]]
" 1a) match [[URL][DESCRIPTION]]
let g:vimwiki_rxWikiLink = g:vimwiki_rxWikiLinkPrefix.
      \ g:vimwiki_rxWikiLinkUrl. g:vimwiki_rxWikiLinkSeparatorOpt.
      \ g:vimwiki_rxWikiLinkDescr. g:vimwiki_rxWikiLinkSuffix
" 1b) match URL within [[URL][DESCRIPTION]]
let g:vimwiki_rxWikiLinkMatchUrl = g:vimwiki_rxWikiLinkPrefix.
      \ '\zs'. g:vimwiki_rxWikiLinkUrl. '\ze'. g:vimwiki_rxWikiLinkSeparatorOpt.
      \ g:vimwiki_rxWikiLinkDescr. g:vimwiki_rxWikiLinkSuffix
" 1c) match DESCRIPTION within [[URL][DESCRIPTION]]
let g:vimwiki_rxWikiLinkMatchDescr = g:vimwiki_rxWikiLinkPrefix.
      \ g:vimwiki_rxWikiLinkUrl. g:vimwiki_rxWikiLinkSeparatorOpt.
      \ '\zs'. g:vimwiki_rxWikiLinkDescr. '\ze'. g:vimwiki_rxWikiLinkSuffix
" *. wikilink or wikiword WARNING: g:vimwiki_camel_case may be deprecated
if g:vimwiki_camel_case
  " *a) match ANY wikilink or wikiword
  let g:vimwiki_rxWikiLink = g:vimwiki_rxWikiLink.'\|'. g:vimwiki_rxWikiWord
  " *b) match URL wikilink or wikiword
  let g:vimwiki_rxWikiLinkMatchUrl = g:vimwiki_rxWikiLinkMatchUrl.'\|'.
        \ g:vimwiki_rxWikiWord
endif
" }}}

" LINKS: setup of wikiincl regexps {{{
" TODO: put these in 'syntax/vimwiki_xxx.vim'
let g:vimwiki_rxWikiInclPrefix = '{{'
let g:vimwiki_rxWikiInclSuffix = '}}'
let g:vimwiki_rxWikiInclSeparator = g:vimwiki_incl_separator
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
" }}}

" LINKS: Setup templated weblink regexps {{{
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
let t_Web = g:vimwiki_web_template
if g:vimwiki_debug > 1
  echom 'Weblink Template: '.t_Web
endif
let magic_chars = '.*[]\^$'
" list all delimiters that appear in Template *after* DESCRIPTION
let exclude_chars = s:get_suffix(t_Web, '__LinkDescription__')
let exclude_chars = join(split(exclude_chars, template_args), '')
let exclude_chars = s:get_unique_chars(exclude_chars)
let valid_chars = '[^'.escape(exclude_chars, magic_chars).']'
let g:vimwiki_rxWeblinkDescr = valid_chars.'*'
"
" " 2012-02-04 TODO not starting with [[ or ][ ?  ... prefix = '[\[\]]\@<!\[' 
" 1. web template
let g:vimwiki_rxWeblink1 = vimwiki#base#apply_template(t_Web, 
      \ g:vimwiki_rxWeblinkUrl, 
      \ g:vimwiki_rxWeblinkDescr, 
      \ '')
" 1a) match URL within web template
let g:vimwiki_rxWeblinkMatchUrl1 = vimwiki#base#apply_template(t_Web,
      \ '\zs'.g:vimwiki_rxWeblinkUrl.'\ze', 
      \ g:vimwiki_rxWeblinkDescr, 
      \ '')
" 1b) match DESCRIPTION within web template
let g:vimwiki_rxWeblinkMatchDescr1 = vimwiki#base#apply_template(t_Web,
      \ g:vimwiki_rxWeblinkUrl, 
      \ '\zs'.g:vimwiki_rxWeblinkDescr.'\ze', 
      \ '')
" Syntax helper
let rxWeblink_helper = vimwiki#base#apply_template(t_Web, 
      \ g:vimwiki_rxWeblinkUrl, 
      \ '__LinkDescription__',
      \ '')
let g:vimwiki_rxWeblinkPrefix = s:get_prefix(rxWeblink_helper, '__LinkDescription__')
let g:vimwiki_rxWeblinkSuffix = s:get_suffix(rxWeblink_helper, '__LinkDescription__')
if g:vimwiki_debug > 1
  echom 'Web Prefix: '.g:vimwiki_rxWeblinkPrefix
  echom 'Web Suffix: '.g:vimwiki_rxWeblinkSuffix
endif
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
" }}}

" LINKS: Setup templated imagelink regexps {{{
let template_args = '\%(__LinkUrl__\|__LinkDescription__\|__LinkStyle__\)'
let t_Image = g:vimwiki_image_template
if g:vimwiki_debug > 1
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
" Syntax helper
let rxImagelink_helper = vimwiki#base#apply_template(t_Image, 
      \ g:vimwiki_rxImagelinkUrl, 
      \ '__LinkDescription__',
      \ g:vimwiki_rxImagelinkStyle)
let g:vimwiki_rxImagelinkPrefix = s:get_prefix(rxImagelink_helper, '__LinkDescription__')
let g:vimwiki_rxImagelinkSuffix = s:get_suffix(rxImagelink_helper, '__LinkDescription__')
if g:vimwiki_debug > 1
  echom 'Image Prefix: '.g:vimwiki_rxImagelinkPrefix
  echom 'Image Suffix: '.g:vimwiki_rxImagelinkSuffix
endif
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
" }}}

" }}} end of Links

"TODO
" LINKS: highlighting is complicated due to "nonexistent" links feature {{{
function! s:add_target_syntax_ON(target, type) " {{{
  if g:vimwiki_debug > 1
    echom '[vimwiki_debug] syntax target > '.a:target
  endif
  let prefix0 = 'syntax match '.a:type.' `'
  let suffix0 = '` display contains=@NoSpell,VimwikiLinkRest,'.a:type.'Char'
  let prefix1 = 'syntax match '.a:type.'T `'
  let suffix1 = '` display contained'
  execute prefix0. a:target. suffix0
  execute prefix1. a:target. suffix1
endfunction "}}}

function! s:add_target_syntax_OFF(target) " {{{
  if g:vimwiki_debug > 1
    echom '[vimwiki_debug] syntax target > '.a:target
  endif
  let prefix0 = 'syntax match VimwikiNoExistsLink `'
  let suffix0 = '` display contains=@NoSpell,VimwikiLinkRest,VimwikiLinkChar'
  let prefix1 = 'syntax match VimwikiNoExistsLinkT `'
  let suffix1 = '` display contained'
  execute prefix0. a:target. suffix0
  execute prefix1. a:target. suffix1
endfunction "}}}

"TODO CamelCase
function! s:highlight_existing_links() "{{{
  " Wikilink
  " Conditional highlighting that depends on the existence of a wiki file or
  " directory is only available for 'wiki#:' links
  " links set up upon BufEnter (see plugin/...)
  let safe_links = vimwiki#base#file_pattern(b:existing_wikifiles)
  " Wikilink Dirs set up upon BufEnter (see plugin/...)
  let safe_dirs = vimwiki#base#file_pattern(b:existing_wikidirs)

  let rxScheme = '\%(\%(wiki\|wiki'.g:vimwiki_current_idx.'\):\)\?'

    " a) match WikiWord WARNING: g:vimwiki_camel_case may be deprecated
    if g:vimwiki_camel_case
      "TODO filter only those that are CamelCase and in the present directory
      let ccfiles = substitute(b:existing_wikifiles,"\n\\ze".g:vimwiki_wword."\n","\n#",'g') 
      "let g:VimwikiLog.cc = ccfiles
      let ccfiles = substitute(ccfiles,"\n[^#][^\n]*",'','g') 
      let ccfiles = substitute(ccfiles,"\n\\zs#",'','g') 
      let safe_ccfiles = vimwiki#base#file_pattern(ccfiles)
      call s:add_target_syntax_ON(g:vimwiki_wikiword_escape_prefix.'\@<!\<'. safe_ccfiles. '\>', 'VimwikiLink')
    endif
    " b) match [[URL]]
    let target = vimwiki#base#apply_template(g:vimwiki_WikiLinkTemplate1,
          \ rxScheme.safe_links, g:vimwiki_rxWikiLinkDescr, '')
    call s:add_target_syntax_ON(target, 'VimwikiLink')
    " c) match [[URL][DESCRIPTION]]
    let target = vimwiki#base#apply_template(g:vimwiki_WikiLinkTemplate2,
          \ rxScheme.safe_links, g:vimwiki_rxWikiLinkDescr, '')
    call s:add_target_syntax_ON(target, 'VimwikiLink')

    " a) match {{URL}}
    let target = vimwiki#base#apply_template(g:vimwiki_WikiInclTemplate1,
          \ rxScheme.safe_links, g:vimwiki_rxWikiInclArgs, '')
    call s:add_target_syntax_ON(target, 'VimwikiLink')
    " b) match {{URL}{...}}
    let target = vimwiki#base#apply_template(g:vimwiki_WikiInclTemplate2,
          \ rxScheme.safe_links, g:vimwiki_rxWikiInclArgs, '')
    call s:add_target_syntax_ON(target, 'VimwikiLink')
    " 1a) match [[DIRURL]]
    let target = vimwiki#base#apply_template(g:vimwiki_WikiLinkTemplate1,
          \ rxScheme.safe_dirs, g:vimwiki_rxWikiLinkDescr, '')
    call s:add_target_syntax_ON(target, 'VimwikiLink')
    " 2a) match [[DIRURL][DESCRIPTION]]
    let target = vimwiki#base#apply_template(g:vimwiki_WikiLinkTemplate2,
          \ rxScheme.safe_dirs, g:vimwiki_rxWikiLinkDescr, '')
    call s:add_target_syntax_ON(target, 'VimwikiLink')
endfunction "}}}


" use max highlighting - could be quite slow if there are too many wikifiles
if VimwikiGet('maxhi')
  " WikiLink
  call s:add_target_syntax_OFF(g:vimwiki_rxWikiLink)
  " WikiIncl
  call s:add_target_syntax_OFF(g:vimwiki_rxWikiIncl)

  " Subsequently, links verified on vimwiki's path are highlighted as existing
  let time01 = vimwiki#base#time(starttime)  "XXX
  call s:highlight_existing_links()
  let time02 = vimwiki#base#time(starttime)  "XXX
else
  let time01 = vimwiki#base#time(starttime)  "XXX
  " Wikilink
  call s:add_target_syntax_ON(g:vimwiki_rxWikiLink, 'VimwikiLink')
  " WikiIncl
  call s:add_target_syntax_ON(g:vimwiki_rxWikiIncl, 'VimwikiLink')
  let time02 = vimwiki#base#time(starttime)  "XXX
endif

" Weblink
call s:add_target_syntax_ON(g:vimwiki_rxWeblink, 'VimwikiTemplLink')
" Image
call s:add_target_syntax_ON(g:vimwiki_rxImagelink, 'VimwikiTemplLink')

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
call s:add_target_syntax_ON(target, 'VimwikiLink')
" b) match [[nonwiki-scheme-URL][DESCRIPTION]]
let target = vimwiki#base#apply_template(g:vimwiki_WikiLinkTemplate2,
      \ rxScheme.g:vimwiki_rxWikiLinkUrl, g:vimwiki_rxWikiLinkDescr, '')
call s:add_target_syntax_ON(target, 'VimwikiLink')

" a) match {{nonwiki-scheme-URL}}
let target = vimwiki#base#apply_template(g:vimwiki_WikiInclTemplate1,
      \ rxScheme.g:vimwiki_rxWikiInclUrl, g:vimwiki_rxWikiInclArgs, '')
call s:add_target_syntax_ON(target, 'VimwikiLink')
" b) match {{nonwiki-scheme-URL}[{...}]}
let target = vimwiki#base#apply_template(g:vimwiki_WikiInclTemplate2,
      \ rxScheme.g:vimwiki_rxWikiInclUrl, g:vimwiki_rxWikiInclArgs, '')
call s:add_target_syntax_ON(target, 'VimwikiLink')

" }}}


" generic headers "{{{
if g:vimwiki_symH
  "" symmetric
  for i in range(1,6)
    let g:vimwiki_rxH{i}_Template = repeat(g:vimwiki_rxH, i).' __Header__ '.repeat(g:vimwiki_rxH, i)
    let g:vimwiki_rxH{i} = '^\s*'.g:vimwiki_rxH.'\{'.i.'}[^'.g:vimwiki_rxH.'].*[^'.g:vimwiki_rxH.']'.g:vimwiki_rxH.'\{'.i.'}\s*$'
  endfor
  let g:vimwiki_rxHeader = '^\s*\('.g:vimwiki_rxH.'\{1,6}\)\zs[^'.g:vimwiki_rxH.'].*[^'.g:vimwiki_rxH.']\ze\1\s*$'
else
  " asymmetric
  for i in range(1,6)
    let g:vimwiki_rxH{i}_Template = repeat(g:vimwiki_rxH, i).' __Header__'
    let g:vimwiki_rxH{i} = '^\s*'.g:vimwiki_rxH.'\{'.i.'}[^'.g:vimwiki_rxH.'].*$'
  endfor
  let g:vimwiki_rxHeader = '^\s*\('.g:vimwiki_rxH.'\{1,6}\)\zs[^'.g:vimwiki_rxH.'].*\ze$'
endif

" Header levels, 1-6
for i in range(1,6)
  execute 'syntax match VimwikiHeader'.i.' /'.g:vimwiki_rxH{i}.'/ contains=VimwikiTodo,VimwikiHeaderChar,VimwikiNoExistsLink,VimwikiLink,VimwikiTemplLink,@Spell'
endfor

" }}}

" concealed chars " {{{
if exists("+conceallevel")
  syntax conceal on
endif

syntax spell toplevel

" VimwikiLinkChar is for syntax markers (and also URL when a description
" is present) and may be concealed
let options = ' contained transparent contains=NONE'
" conceal wikilinks
execute 'syn match VimwikiLinkChar /'.g:vimwiki_rxWikiLinkPrefix.'/'.options
execute 'syn match VimwikiLinkChar /'.g:vimwiki_rxWikiLinkSuffix.'/'.options
execute 'syn match VimwikiLinkChar /'.g:vimwiki_rxWikiLinkPrefix.g:vimwiki_rxWikiLinkUrl.g:vimwiki_rxWikiLinkSeparator.'\ze'.g:vimwiki_rxWikiLinkDescr.g:vimwiki_rxWikiLinkSuffix.'/'.options

" conceal wikiincls
execute 'syn match VimwikiLinkChar /'.g:vimwiki_rxWikiInclPrefix.'/'.options
execute 'syn match VimwikiLinkChar /'.g:vimwiki_rxWikiInclSuffix.'/'.options
execute 'syn match VimwikiLinkChar /'.g:vimwiki_rxWikiInclPrefix.g:vimwiki_rxWikiInclUrl.g:vimwiki_rxWikiInclSeparator.'/'.options
execute 'syn match VimwikiLinkChar /'.g:vimwiki_rxWikiInclArgs.g:vimwiki_rxWikiInclSuffix.'/'.options

" conceal weblinks
execute 'syn match VimwikiTemplLinkChar "'.g:vimwiki_rxWeblinkPrefix.'"'.options
execute 'syn match VimwikiTemplLinkChar "'.g:vimwiki_rxWeblinkSuffix.'"'.options

" conceal imagelinks
execute 'syn match VimwikiTemplLinkChar "'.g:vimwiki_rxImagelinkPrefix.'"'.options
execute 'syn match VimwikiTemplLinkChar "'.g:vimwiki_rxImagelinkSuffix.'"'.options


" A shortener for long URLs: LinkRest (a middle part of the URL) is concealed
execute 'syn match VimwikiLinkRest contained `\%(///\=[^/ \t]\+/\)\zs\S\{'
        \.g:vimwiki_url_mingain.',}\ze\%([/#?]\w\|\S\{'
        \.g:vimwiki_url_maxsave.'}\)` cchar=~ '.options

execute 'syn match VimwikiEqInChar contained /'.g:vimwiki_char_eqin.'/'
execute 'syn match VimwikiBoldChar contained /'.g:vimwiki_char_bold.'/'
execute 'syn match VimwikiItalicChar contained /'.g:vimwiki_char_italic.'/'
execute 'syn match VimwikiBoldItalicChar contained /'.g:vimwiki_char_bolditalic.'/'
execute 'syn match VimwikiItalicBoldChar contained /'.g:vimwiki_char_italicbold.'/'
execute 'syn match VimwikiCodeChar contained /'.g:vimwiki_char_code.'/'
execute 'syn match VimwikiDelTextChar contained /'.g:vimwiki_char_deltext.'/'
execute 'syn match VimwikiSuperScript contained /'.g:vimwiki_char_superscript.'/'
execute 'syn match VimwikiSubScript contained /'.g:vimwiki_char_subscript.'/'
if exists("+conceallevel")
  syntax conceal off
endif
" }}}

" non concealed chars " {{{
execute 'syn match VimwikiHeaderChar contained /\%(^\s*'.g:vimwiki_rxH.'\+\)\|\%('.g:vimwiki_rxH.'\+\s*$\)/'
execute 'syn match VimwikiEqInCharT contained /'.g:vimwiki_char_eqin.'/'
execute 'syn match VimwikiBoldCharT contained /'.g:vimwiki_char_bold.'/'
execute 'syn match VimwikiItalicCharT contained /'.g:vimwiki_char_italic.'/'
execute 'syn match VimwikiBoldItalicCharT contained /'.g:vimwiki_char_bolditalic.'/'
execute 'syn match VimwikiItalicBoldCharT contained /'.g:vimwiki_char_italicbold.'/'
execute 'syn match VimwikiCodeCharT contained /'.g:vimwiki_char_code.'/'
execute 'syn match VimwikiDelTextCharT contained /'.g:vimwiki_char_deltext.'/'
execute 'syn match VimwikiSuperScriptT contained /'.g:vimwiki_char_superscript.'/'
execute 'syn match VimwikiSubScriptT contained /'.g:vimwiki_char_subscript.'/'

" Emoticons
"syntax match VimwikiEmoticons /\%((.)\|:[()|$@]\|:-[DOPS()\]|$@]\|;)\|:'(\)/

let g:vimwiki_rxTodo = '\C\%(TODO:\|DONE:\|STARTED:\|FIXME:\|FIXED:\|XXX:\)'
execute 'syntax match VimwikiTodo /'. g:vimwiki_rxTodo .'/'
" }}}

" main syntax groups {{{

" Tables
syntax match VimwikiTableRow /^\s*|.\+|\s*$/ 
      \ transparent contains=VimwikiCellSeparator,
                           \ VimwikiLinkT,
                           \ VimwikiTemplLinkT,
                           \ VimwikiNoExistsLinkT,
                           \ VimwikiEmoticons,
                           \ VimwikiTodo,
                           \ VimwikiBoldT,
                           \ VimwikiItalicT,
                           \ VimwikiBoldItalicT,
                           \ VimwikiItalicBoldT,
                           \ VimwikiDelTextT,
                           \ VimwikiSuperScriptT,
                           \ VimwikiSubScriptT,
                           \ VimwikiCodeT,
                           \ VimwikiEqInT,
                           \ @Spell
syntax match VimwikiCellSeparator 
      \ /\%(|\)\|\%(-\@<=+\-\@=\)\|\%([|+]\@<=-\+\)/ contained

" List items
execute 'syntax match VimwikiList /'.g:vimwiki_rxListBullet.'/'
execute 'syntax match VimwikiList /'.g:vimwiki_rxListNumber.'/'
execute 'syntax match VimwikiList /'.g:vimwiki_rxListDefine.'/'
" List item checkbox
"syntax match VimwikiCheckBox /\[.\?\]/
let g:vimwiki_rxCheckBox = '\s*\[['.g:vimwiki_listsyms.']\?\]\s'
" Todo lists have a checkbox
execute 'syntax match VimwikiListTodo /'.g:vimwiki_rxListBullet.g:vimwiki_rxCheckBox.'/'
execute 'syntax match VimwikiListTodo /'.g:vimwiki_rxListNumber.g:vimwiki_rxCheckBox.'/'
if g:vimwiki_hl_cb_checked
  execute 'syntax match VimwikiCheckBoxDone /'.
        \ g:vimwiki_rxListBullet.'\s*\['.g:vimwiki_listsyms[4].'\]\s.*$/'.
        \ ' contains=VimwikiNoExistsLink,VimwikiLink'
  execute 'syntax match VimwikiCheckBoxDone /'.
        \ g:vimwiki_rxListNumber.'\s*\['.g:vimwiki_listsyms[4].'\]\s.*$/'.
        \ ' contains=VimwikiNoExistsLink,VimwikiLink'
endif

execute 'syntax match VimwikiEqIn /'.g:vimwiki_rxEqIn.'/ contains=VimwikiEqInChar'
execute 'syntax match VimwikiEqInT /'.g:vimwiki_rxEqIn.'/ contained contains=VimwikiEqInCharT'

execute 'syntax match VimwikiBold /'.g:vimwiki_rxBold.'/ contains=VimwikiBoldChar,@Spell'
execute 'syntax match VimwikiBoldT /'.g:vimwiki_rxBold.'/ contained contains=VimwikiBoldCharT,@Spell'

execute 'syntax match VimwikiItalic /'.g:vimwiki_rxItalic.'/ contains=VimwikiItalicChar,@Spell'
execute 'syntax match VimwikiItalicT /'.g:vimwiki_rxItalic.'/ contained contains=VimwikiItalicCharT,@Spell'

execute 'syntax match VimwikiBoldItalic /'.g:vimwiki_rxBoldItalic.'/ contains=VimwikiBoldItalicChar,VimwikiItalicBoldChar,@Spell'
execute 'syntax match VimwikiBoldItalicT /'.g:vimwiki_rxBoldItalic.'/ contained contains=VimwikiBoldItalicChatT,VimwikiItalicBoldCharT,@Spell'

execute 'syntax match VimwikiItalicBold /'.g:vimwiki_rxItalicBold.'/ contains=VimwikiBoldItalicChar,VimwikiItalicBoldChar,@Spell'
execute 'syntax match VimwikiItalicBoldT /'.g:vimwiki_rxItalicBold.'/ contained contains=VimwikiBoldItalicCharT,VimsikiItalicBoldCharT,@Spell'

execute 'syntax match VimwikiDelText /'.g:vimwiki_rxDelText.'/ contains=VimwikiDelTextChar,@Spell'
execute 'syntax match VimwikiDelTextT /'.g:vimwiki_rxDelText.'/ contained contains=VimwikiDelTextChar,@Spell'

execute 'syntax match VimwikiSuperScript /'.g:vimwiki_rxSuperScript.'/ contains=VimwikiSuperScriptChar,@Spell'
execute 'syntax match VimwikiSuperScriptT /'.g:vimwiki_rxSuperScript.'/ contained contains=VimwikiSuperScriptCharT,@Spell'

execute 'syntax match VimwikiSubScript /'.g:vimwiki_rxSubScript.'/ contains=VimwikiSubScriptChar,@Spell'
execute 'syntax match VimwikiSubScriptT /'.g:vimwiki_rxSubScript.'/ contained contains=VimwikiSubScriptCharT,@Spell'

execute 'syntax match VimwikiCode /'.g:vimwiki_rxCode.'/ contains=VimwikiCodeChar'
execute 'syntax match VimwikiCodeT /'.g:vimwiki_rxCode.'/ contained contains=VimwikiCodeCharT'

" <hr> horizontal rule
execute 'syntax match VimwikiHR /'.g:vimwiki_rxHR.'/'

execute 'syntax region VimwikiPre start=/^\s*'.g:vimwiki_rxPreStart.
      \ '/ end=/^\s*'.g:vimwiki_rxPreEnd.'\s*$/ contains=@Spell'

execute 'syntax region VimwikiMath start=/^\s*'.g:vimwiki_rxMathStart.
      \ '/ end=/^\s*'.g:vimwiki_rxMathEnd.'\s*$/ contains=@Spell'


" placeholders
syntax match VimwikiPlaceholder /^\s*%toc\%(\s.*\)\?$/ contains=VimwikiPlaceholderParam
syntax match VimwikiPlaceholder /^\s*%nohtml\s*$/
syntax match VimwikiPlaceholder /^\s*%title\%(\s.*\)\?$/ contains=VimwikiPlaceholderParam
syntax match VimwikiPlaceholder /^\s*%template\%(\s.*\)\?$/ contains=VimwikiPlaceholderParam
syntax match VimwikiPlaceholderParam /\s.*/ contained

" html tags
if g:vimwiki_valid_html_tags != ''
  let html_tags = join(split(g:vimwiki_valid_html_tags, '\s*,\s*'), '\|')
  exe 'syntax match VimwikiHTMLtag #\c</\?\%('.html_tags.'\)\%(\s\{-1}\S\{-}\)\{-}\s*/\?>#'
  execute 'syntax match VimwikiBold #\c<b>.\{-}</b># contains=VimwikiHTMLTag'
  execute 'syntax match VimwikiItalic #\c<i>.\{-}</i># contains=VimwikiHTMLTag'
  execute 'syntax match VimwikiUnderline #\c<u>.\{-}</u># contains=VimwikiHTMLTag'

  execute 'syntax match VimwikiComment /'.g:vimwiki_rxComment.'/ contains=@Spell'
endif
" }}}

" header groups highlighting "{{{

if g:vimwiki_hl_headers == 0
  " Strangely in default colorscheme Title group is not set to bold for cterm...
  if !exists("g:colors_name")
    hi Title cterm=bold
  endif
  for i in range(1,6)
    execute 'hi def link VimwikiHeader'.i.' Title'
  endfor
else
  " default colors when headers of different levels are highlighted differently 
  " not making it yet another option; needed by ColorScheme autocommand
  let g:vimwiki_hcolor_guifg_light = ['#aa5858','#507030','#1030a0','#103040','#505050','#636363']
  let g:vimwiki_hcolor_ctermfg_light = ['DarkRed','DarkGreen','DarkBlue','Black','Black','Black']
  let g:vimwiki_hcolor_guifg_dark = ['#e08090','#80e090','#6090e0','#c0c0f0','#e0e0f0','#f0f0f0']
  let g:vimwiki_hcolor_ctermfg_dark = ['Red','Green','Blue','White','White','White']
  for i in range(1,6)
    execute 'hi def VimwikiHeader'.i.' guibg=bg guifg='.g:vimwiki_hcolor_guifg_{&bg}[i-1].' gui=bold ctermfg='.g:vimwiki_hcolor_ctermfg_{&bg}[i-1].' term=bold cterm=bold' 
  endfor
endif
"}}}

" syntax group highlighting "{{{ 

hi def link VimwikiMarkers Normal

hi def link VimwikiEqIn Number
hi def link VimwikiEqInT VimwikiEqIn

hi def VimwikiBold term=bold cterm=bold gui=bold
hi def link VimwikiBoldT VimwikiBold

hi def VimwikiItalic term=italic cterm=italic gui=italic
hi def link VimwikiItalicT VimwikiItalic

hi def VimwikiBoldItalic term=bold cterm=bold gui=bold,italic
hi def link VimwikiItalicBold VimwikiBoldItalic
hi def link VimwikiBoldItalicT VimwikiBoldItalic
hi def link VimwikiItalicBoldT VimwikiBoldItalic

hi def VimwikiUnderline gui=underline

hi def link VimwikiCode PreProc
hi def link VimwikiCodeT VimwikiCode

hi def link VimwikiPre PreProc
hi def link VimwikiPreT VimwikiPre

hi def link VimwikiMath Number
hi def link VimwikiMathT VimwikiMath

hi def link VimwikiNoExistsLink SpellBad
hi def link VimwikiNoExistsLinkT VimwikiNoExistsLink

hi def link VimwikiLink Underlined
hi def link VimwikiTemplLink VimwikiLink
hi def link VimwikiLinkT VimwikiLink
hi def link VimwikiTemplLinkT VimwikiLink

hi def link VimwikiList Identifier
hi def link VimwikiListTodo VimwikiList
"hi def link VimwikiCheckBox VimwikiList
hi def link VimwikiCheckBoxDone Comment
hi def link VimwikiEmoticons Character
hi def link VimwikiHR Identifier

hi def link VimwikiDelText Constant
hi def link VimwikiDelTextT VimwikiDelText

hi def link VimwikiSuperScript Number
hi def link VimwikiSuperScriptT VimwikiSuperScript

hi def link VimwikiSubScript Number
hi def link VimwikiSubScriptT VimwikiSubScript

hi def link VimwikiTodo Todo
hi def link VimwikiComment Comment

hi def link VimwikiPlaceholder SpecialKey
hi def link VimwikiPlaceholderParam String
hi def link VimwikiHTMLtag SpecialKey

hi def link VimwikiEqInChar VimwikiMarkers
hi def link VimwikiCellSeparator VimwikiMarkers
hi def link VimwikiBoldChar VimwikiMarkers
hi def link VimwikiItalicChar VimwikiMarkers
hi def link VimwikiBoldItalicChar VimwikiMarkers
hi def link VimwikiItalicBoldChar VimwikiMarkers
hi def link VimwikiDelTextChar VimwikiMarkers
hi def link VimwikiSuperScriptChar VimwikiMarkers
hi def link VimwikiSubScriptChar VimwikiMarkers
hi def link VimwikiCodeChar VimwikiMarkers
hi def link VimwikiHeaderChar VimwikiMarkers

hi def link VimwikiEqInCharT VimwikiMarkers
hi def link VimwikiBoldCharT VimwikiMarkers
hi def link VimwikiItalicCharT VimwikiMarkers
hi def link VimwikiBoldItalicCharT VimwikiMarkers
hi def link VimwikiItalicBoldCharT VimwikiMarkers
hi def link VimwikiDelTextCharT VimwikiMarkers
hi def link VimwikiSuperScriptCharT VimwikiMarkers
hi def link VimwikiSubScriptCharT VimwikiMarkers
hi def link VimwikiCodeCharT VimwikiMarkers
hi def link VimwikiHeaderCharT VimwikiMarkers
hi def link VimwikiLinkCharT VimwikiLinkT
hi def link VimwikiNoExistsLinkCharT VimwikiNoExistsLinkT
"}}}

let b:current_syntax="vimwiki"

" EMBEDDED syntax setup "{{{
let nested = VimwikiGet('nested_syntaxes')
if !empty(nested)
  for [hl_syntax, vim_syntax] in items(nested)
    call vimwiki#base#nested_syntax(vim_syntax, 
          \ '^\s*{{{\%(.*[[:blank:][:punct:]]\)\?'.
          \ hl_syntax.'\%([[:blank:][:punct:]].*\)\?',
          \ '^\s*}}}', 'VimwikiPre')
"    call vimwiki#base#nested_syntax(vim_syntax, 
"          \ '^\s*{{\$\%(.*[[:blank:][:punct:]]\)\?'.
"          \ hl_syntax.'\%([[:blank:][:punct:]].*\)\?',
"          \ '^\s*}}\$', 'VimwikiMath')
  endfor
endif
"}}}
let timeend = vimwiki#base#time(starttime)  "XXX
call VimwikiLog_extend('timing',['syntax:scans',timescans],['syntax:regexloaded',time0],['syntax:beforeHLexisting',time01],['syntax:afterHLexisting',time02],['syntax:end',timeend])
