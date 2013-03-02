" vim:tabstop=2:shiftwidth=2:expandtab:foldmethod=marker:textwidth=79
" Vimwiki syntax file
" Author: Macropodus <the.macropodus@gmail.com>
" Home: http://code.google.com/p/vimwiki/

" LINKS: assume this is common to all syntaxes "{{{

" }}}

" -------------------------------------------------------------------------
" Load concrete Wiki syntax: sets regexes and templates for headers and links

" -------------------------------------------------------------------------



" LINKS: setup of larger regexes {{{

" LINKS: setup wikilink regexps {{{
" }}}

" LINKS: setup wikilink1 regexps {{{

let g:vimwiki_rxWikiLinkPrefix = '['
let g:vimwiki_rxWikiLinkSuffix = ')'
let g:vimwiki_rxWikiLinkSeparator = ']('

" [URL]()
let g:vimwiki_WikiLinkTemplate1 = g:vimwiki_rxWikiLinkPrefix . '__LinkUrl__'.
      \ g:vimwiki_rxWikiLinkSeparator.g:vimwiki_rxWikiLinkSuffix
" [DESCRIPTION](URL)
let g:vimwiki_WikiLinkTemplate2 = g:vimwiki_rxWikiLinkPrefix . '__LinkDescription__'.
      \ g:vimwiki_rxWikiLinkSeparator. '__LinkUrl__'.
      \ g:vimwiki_rxWikiLinkSuffix

let magic_chars = '.*[]\^$'
let valid_chars = '[^\\\[\]]'

let g:vimwiki_rxWikiLinkPrefix = escape(g:vimwiki_rxWikiLinkPrefix, magic_chars)
let g:vimwiki_rxWikiLinkSuffix = escape(g:vimwiki_rxWikiLinkSuffix, magic_chars)
let g:vimwiki_rxWikiLinkSeparator = escape(g:vimwiki_rxWikiLinkSeparator, magic_chars)
let g:vimwiki_rxWikiLinkUrl = valid_chars.'\{-1,}'
let g:vimwiki_rxWikiLinkDescr = valid_chars.'\{-1,}'

let g:vimwiki_rxWord = '[^[:blank:]()\\]\+'

"
" 1. [URL]()
" 1a) match [URL]()
let g:vimwiki_rxWikiLink1 = g:vimwiki_rxWikiLinkPrefix.
      \ g:vimwiki_rxWikiLinkDescr.g:vimwiki_rxWikiLinkSeparator.
      \ g:vimwiki_rxWikiLinkSuffix
" 1b) match URL within [URL]()
let g:vimwiki_rxWikiLink1MatchUrl = g:vimwiki_rxWikiLinkPrefix.
      \ '\zs'.g:vimwiki_rxWikiLinkUrl.'\ze'.g:vimwiki_rxWikiLinkSeparator.
      \ g:vimwiki_rxWikiLinkSuffix
" 2. [DESCRIPTION](URL)
" 2a) match [DESCRIPTION](URL)
let g:vimwiki_rxWikiLink2 = g:vimwiki_rxWikiLinkPrefix.
      \ g:vimwiki_rxWikiLinkDescr.g:vimwiki_rxWikiLinkSeparator.
      \ g:vimwiki_rxWikiLinkUrl.g:vimwiki_rxWikiLinkSuffix
" 2b) match URL within [DESCRIPTION](URL)
let g:vimwiki_rxWikiLink2MatchUrl = g:vimwiki_rxWikiLinkPrefix.
      \ g:vimwiki_rxWikiLinkDescr.g:vimwiki_rxWikiLinkSeparator.
      \ '\zs'.g:vimwiki_rxWikiLinkUrl.'\ze'.g:vimwiki_rxWikiLinkSuffix
" 2c) match DESCRIPTION within [DESCRIPTION](URL)
let g:vimwiki_rxWikiLink2MatchDescr = g:vimwiki_rxWikiLinkPrefix.
      \ '\zs'.g:vimwiki_rxWikiLinkDescr.'\ze'.g:vimwiki_rxWikiLinkSeparator.
      \ g:vimwiki_rxWikiLinkUrl.g:vimwiki_rxWikiLinkSuffix
" }}}

" LINKS: Syntax helper {{{
" }}}


" LINKS: setup of wikiincl regexps {{{
" }}}

" LINKS: Syntax helper {{{
let g:vimwiki_rxWikiLinkPrefix1 = g:vimwiki_rxWikiLinkPrefix
let g:vimwiki_rxWikiLinkSuffix1 = g:vimwiki_rxWikiLinkSeparator.
      \ g:vimwiki_rxWikiLinkUrl.g:vimwiki_rxWikiLinkSuffix
let g:vimwiki_rxWikiLinkSuffix2 = g:vimwiki_rxWikiLinkSeparator.
      \ g:vimwiki_rxWikiLinkSuffix
" }}}

" LINKS: Setup weblink regexps {{{
" }}}


" LINKS: Setup anylink regexps {{{
" }}}


" }}} end of Links

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

function! s:highlight_existing_links() "{{{
  " Wikilink
  " Conditional highlighting that depends on the existence of a wiki file or
  "   directory is only available for *schemeless* wiki links
  " Links are set up upon BufEnter (see plugin/...)
  let safe_links = vimwiki#base#file_pattern(b:existing_wikifiles)
  " Wikilink Dirs set up upon BufEnter (see plugin/...)
  let safe_dirs = vimwiki#base#file_pattern(b:existing_wikidirs)

  " match [URL]()
  let target = vimwiki#base#apply_template(g:vimwiki_WikiLinkTemplate1,
        \ safe_links, g:vimwiki_rxWikiLinkDescr, '')
  call s:add_target_syntax_ON(target, 'VimwikiLink')
  " match [DESCRIPTION](URL)
  let target = vimwiki#base#apply_template(g:vimwiki_WikiLinkTemplate2,
        \ safe_links, g:vimwiki_rxWikiLinkDescr, '')
  call s:add_target_syntax_ON(target, 'VimwikiLink')

  " match [DIRURL]()
  let target = vimwiki#base#apply_template(g:vimwiki_WikiLinkTemplate1,
        \ safe_dirs, g:vimwiki_rxWikiLinkDescr, '')
  call s:add_target_syntax_ON(target, 'VimwikiLink')
  " match [DESCRIPTION](DIRURL)
  let target = vimwiki#base#apply_template(g:vimwiki_WikiLinkTemplate2,
        \ safe_dirs, g:vimwiki_rxWikiLinkDescr, '')
  call s:add_target_syntax_ON(target, 'VimwikiLink')
endfunction "}}}


" use max highlighting - could be quite slow if there are too many wikifiles
if VimwikiGet('maxhi')
  " WikiLink
  call s:add_target_syntax_OFF(g:vimwiki_rxWikiLink1)
  call s:add_target_syntax_OFF(g:vimwiki_rxWikiLink2)

  " Subsequently, links verified on vimwiki's path are highlighted as existing
  let time01 = vimwiki#u#time(starttime)  "XXX
  call s:highlight_existing_links()
  let time02 = vimwiki#u#time(starttime)  "XXX
else
  let time01 = vimwiki#u#time(starttime)  "XXX
  " Wikilink
  call s:add_target_syntax_ON(g:vimwiki_rxWikiLink1, 'VimwikiLink')
  call s:add_target_syntax_ON(g:vimwiki_rxWikiLink2, 'VimwikiLink')
  let time02 = vimwiki#u#time(starttime)  "XXX
endif

" }}}


" generic headers "{{{
" }}}

" concealed chars " {{{
if exists("+conceallevel")
  syntax conceal on
endif

syntax spell toplevel

if g:vimwiki_debug > 1
  echom 'WikiLink Prefix1: '.g:vimwiki_rxWikiLinkPrefix1
  echom 'WikiLink Suffix1: '.g:vimwiki_rxWikiLinkSuffix1
  echom 'WikiLink Suffix2: '.g:vimwiki_rxWikiLinkSuffix2
endif

" VimwikiLinkChar is for syntax markers (and also URL when a description
" is present) and may be concealed
let options = ' contained transparent contains=NONE'
" conceal wikilinks
execute 'syn match VimwikiLinkChar /'.g:vimwiki_rxWikiLinkPrefix1.'/'.options
execute 'syn match VimwikiLinkChar /'.g:vimwiki_rxWikiLinkSuffix1.'/'.options
execute 'syn match VimwikiLinkChar /'.g:vimwiki_rxWikiLinkSuffix2.'/'.options

if exists("+conceallevel")
  syntax conceal off
endif
" }}}

" non concealed chars " {{{
" }}}

" main syntax groups {{{

" Tables
" }}}

" header groups highlighting "{{{
"}}}


" syntax group highlighting "{{{ 
"}}}

" EMBEDDED syntax setup "{{{
"}}}
