# 2.1 #

  * Concealing of links can be turned off - set |g:vimwiki\_url\_maxsave| to 0.     The option g:vimwiki\_url\_mingain was removed
  * |g:vimwiki\_folding| also accepts value 'list'; with 'expr' both sections and code blocks folded, g:vimwiki\_fold\_lists option was removed
  * [Issue 261](https://code.google.com/p/vimwiki/issues/detail?id=261): Syntax folding is back. |g:vimwiki\_folding| values are changed to '', 'expr', 'syntax'.
  * [Issue 372](https://code.google.com/p/vimwiki/issues/detail?id=372): Ignore case in g:vimwiki\_valid\_html\_tags
  * [Issue 374](https://code.google.com/p/vimwiki/issues/detail?id=374): Make autowriteall local to vimwiki. It is not 100% local though.
  * [Issue 384](https://code.google.com/p/vimwiki/issues/detail?id=384): Custom\_wiki2html script now receives templating arguments
  * [Issue 393](https://code.google.com/p/vimwiki/issues/detail?id=393): Custom\_wiki2html script path can contain tilde character
  * [Issue 392](https://code.google.com/p/vimwiki/issues/detail?id=392): Custom\_wiki2html arguments are quoted, e.g names with spaces
  * Various small bug fixes.


# 2.0 #
  * Quick page-link creation.
  * **Redesign of link syntaxes (!)**
    * No more `CamelCase` links. Check the ways to convert them http://goo.gl/15ctX
    * No more `[[link][desc]]` links.
    * No more `[http://link description]` links.
    * No more plain image links. Use transclusions.
    * No more image links identified by extension. Use transclusions.
  * Interwiki links.
  * Link schemes.
  * Transclusions.
  * Normalize link command.
  * Improved diary organization and generation.
  * List manipulation.
  * Markdown support.
  * Mathjax support.
  * Improved handling of special characters and punctuation in filenames and urls.
  * Back links command: list links referring to the current page.
  * Highlighting nonexisted links are off by default.
  * Table syntax change. Row separator uses | instead of +.
  * Fold multilined list items.
  * Custom wiki to HTML converters.
  * Conceal long weblinks.
  * Option to disable table mappings.

# 1.2 #
  * [Issue 70](https://code.google.com/p/vimwiki/issues/detail?id=70): Table spanning cell support.
  * [Issue 72](https://code.google.com/p/vimwiki/issues/detail?id=72): Do not convert again for unchanged file. `:VimwikiAll2HTML` converts only changed wiki files.
  * [Issue 117](https://code.google.com/p/vimwiki/issues/detail?id=117): `VimwikiDiaryIndex` command that opens diary index wiki page.
  * [Issue 120](https://code.google.com/p/vimwiki/issues/detail?id=120): Links in headers are not highlighted in vimwiki but are highlighted in HTML.
  * [Issue 138](https://code.google.com/p/vimwiki/issues/detail?id=138): Added possibility to remap table-column move bindings. See `:VimwikiTableMoveColumnLeft` and `:VimwikiTableMoveColumnRight` commands. For remap instructions see `vimwiki_<A-Left>` and `vimwiki_<A-Right>`.
  * [Issue 125](https://code.google.com/p/vimwiki/issues/detail?id=125): Problem with 'o' command given while at the of the file.
  * [Issue 131](https://code.google.com/p/vimwiki/issues/detail?id=131): Filetype is not set up when GUIEnter autocommand is used in vimrc. Use 'nested' in `au GUIEnter * nested VimwikiIndex`
  * [Issue 132](https://code.google.com/p/vimwiki/issues/detail?id=132): Link to perl (or any non-wiki) file in vimwiki subdirectory doesn't work as intended.
  * [Issue 135](https://code.google.com/p/vimwiki/issues/detail?id=135): %title and %toc used together cause TOC to appear in an unexpected place in HTML.
  * [Issue 139](https://code.google.com/p/vimwiki/issues/detail?id=139): `:VimwikiTabnewLink` command is added.
  * Fix of g:vimwiki\_stripsym = '' (i.e. an empty string) -- it removes bad symbols from filenames.
  * [Issue 145](https://code.google.com/p/vimwiki/issues/detail?id=145): With modeline 'set ft=vimwiki' links are not correctly highlighted when open wiki files.
  * [Issue 146](https://code.google.com/p/vimwiki/issues/detail?id=146): Filetype difficulty with ".txt" as a vimwiki extension.
  * [Issue 148](https://code.google.com/p/vimwiki/issues/detail?id=148): There are no mailto links.
  * [Issue 151](https://code.google.com/p/vimwiki/issues/detail?id=151): Use location list instead of quickfix list for `:VimwikiSearch` command result. Use :lopen instead of :copen, :lnext instead of :cnext etc.
  * [Issue 152](https://code.google.com/p/vimwiki/issues/detail?id=152): Add the list of HTML files that would not be deleted after `:VimwikiAll2HTML`.
  * [Issue 153](https://code.google.com/p/vimwiki/issues/detail?id=153): Delete HTML files that has no corresponding wiki ones with `:VimwikiAll2HTML`.
  * [Issue 156](https://code.google.com/p/vimwiki/issues/detail?id=156): Add multiple HTML templates. See `vimwiki-option-template_path`. Options html\_header and html\_footer are no longer exist.
  * [Issue 173](https://code.google.com/p/vimwiki/issues/detail?id=173): When virtualedit=all option is enabled the 'o' command behave strange.
  * [Issue 178](https://code.google.com/p/vimwiki/issues/detail?id=178): Problem with alike wikie's paths.
  * [Issue 182](https://code.google.com/p/vimwiki/issues/detail?id=182): Browser command does not quote url.
  * [Issue 183](https://code.google.com/p/vimwiki/issues/detail?id=183): Spelling error highlighting is not possible with nested syntaxes.
  * [Issue 184](https://code.google.com/p/vimwiki/issues/detail?id=184): Wrong foldlevel in some cases.
  * [Issue 195](https://code.google.com/p/vimwiki/issues/detail?id=195): Page renaming issue.
  * [Issue 196](https://code.google.com/p/vimwiki/issues/detail?id=196): vim: modeline bug -- syn=vim doesn't work.
  * [Issue 199](https://code.google.com/p/vimwiki/issues/detail?id=199): Generated HTML for sublists is invalid.
  * [Issue 200](https://code.google.com/p/vimwiki/issues/detail?id=200): Generated HTML for todo lists does not show completion status the fix relies on CSS, thus your old stylesheets need to be updated!; may not work in obsolete browsers or font-deficient systems.
  * [Issue 205](https://code.google.com/p/vimwiki/issues/detail?id=205): Block code: highlighting differs from processing. Inline code block ` ... ` is removed. Use `...` instead.
  * [Issue 208](https://code.google.com/p/vimwiki/issues/detail?id=208): Default highlight colors are problematic in many colorschemes. Headers are highlighted as `hl-Title` by default, use `g:vimwiki_hl_headers` to restore previous default Red, Green, Blue or custom header colors. Some other changes in highlighting.
  * [Issue 209](https://code.google.com/p/vimwiki/issues/detail?id=209): Wild comments slow down html generation. Comments are changed, use %% to comment out entire line.
  * [Issue 210](https://code.google.com/p/vimwiki/issues/detail?id=210): HTML: para enclose header.
  * [Issue 214](https://code.google.com/p/vimwiki/issues/detail?id=214): External links containing Chinese characters get trimmed.
  * [Issue 218](https://code.google.com/p/vimwiki/issues/detail?id=218): Command to generate HTML file and open it in webbrowser. See `:Vimwiki2HTMLBrowse`(bind to `<leader>`whh)
  * NEW: Added `<Leader>`wh mapping to call `:Vimwiki2HTML`


# 1.1.1 #
  * FIX: [Issue 122](https://code.google.com/p/vimwiki/issues/detail?id=122): Dot character in vimwiki's directory path isn't escaped.
  * FIX: [Issue 123](https://code.google.com/p/vimwiki/issues/detail?id=123): Where is Vimwiki2HTML and other commands? Sometimes filetype is not set up to vimwiki.
  * FIX: [Issue 124](https://code.google.com/p/vimwiki/issues/detail?id=124): Highlight group not found: Normal

# 1.1 #
  * NEW: [Issue 57](https://code.google.com/p/vimwiki/issues/detail?id=57): Make it possible to have pre block inside list item.
  * NEW: [Issue 82](https://code.google.com/p/vimwiki/issues/detail?id=82): Add quick goto command. See `:VimwikiGoto`.
  * NEW: [Issue 83](https://code.google.com/p/vimwiki/issues/detail?id=83): Quick switch in diary. See `:VimwikiDiaryNextDay` and `:VimwikiDiaryPrevDay` commands.
  * FIX: [Issue 84](https://code.google.com/p/vimwiki/issues/detail?id=84): Vimwiki rename removed the `WikiWord` display name.
  * FIX: [Issue 85](https://code.google.com/p/vimwiki/issues/detail?id=85): Errors if you have '~' subdirectory in a wiki directory.
  * FIX: [Issue 86](https://code.google.com/p/vimwiki/issues/detail?id=86): Existed links '`[[WikiLink1|Alias1]]` | `[[WikiLink2]]`' are highlighted as a single link.
  * FIX: [Issue 88](https://code.google.com/p/vimwiki/issues/detail?id=88): Underline text. See `g:vimwiki_valid_html_tags`.
  * FIX: [Issue 92](https://code.google.com/p/vimwiki/issues/detail?id=92): Wikies in a subdir could be renamed to an empty file.
  * FIX: [Issue 93](https://code.google.com/p/vimwiki/issues/detail?id=93): Use alias name in html title. See `vimwiki-title`.
  * FIX: [Issue 94](https://code.google.com/p/vimwiki/issues/detail?id=94): Relative links to PHP files are broken. See `g:vimwiki_file_exts` for details.
  * FIX: [Issue 96](https://code.google.com/p/vimwiki/issues/detail?id=96): Closing bracket at the end of weblink shouldn't be a part of that link.
  * FIX: [Issue 97](https://code.google.com/p/vimwiki/issues/detail?id=97): Error opening weblink in a browser if it has # inside.
  * FIX: [Issue 99](https://code.google.com/p/vimwiki/issues/detail?id=99): Vim is not responing while opening arbitrary wiki file.
  * FIX: [Issue 100](https://code.google.com/p/vimwiki/issues/detail?id=100): Additional content on diary index page could be corrupted.
  * NEW: [Issue 101](https://code.google.com/p/vimwiki/issues/detail?id=101): Customized HTML tags. See `g:vimwiki_valid_html_tags`
  * NEW: [Issue 102](https://code.google.com/p/vimwiki/issues/detail?id=102): Conceal feature usage. See `g:vimwiki_conceallevel`.
  * FIX: [Issue 103](https://code.google.com/p/vimwiki/issues/detail?id=103): Always highlight links to non-wiki files as existed.
  * FIX: [Issue 104](https://code.google.com/p/vimwiki/issues/detail?id=104): vimwiki#nested\_syntax needs 'keepend' to avoid contained language syntax eat needed '}}}'.
  * FIX: [Issue 105](https://code.google.com/p/vimwiki/issues/detail?id=105): `<i_CR>` on a todo list item with `[ ]` doesn't create new todo list item.
  * FIX: [Issue 106](https://code.google.com/p/vimwiki/issues/detail?id=106): With `MediaWiki` syntax `<C-Space>` on a child todo list item produce errors.
  * FIX: [Issue 107](https://code.google.com/p/vimwiki/issues/detail?id=107): With `MediaWiki` syntax `<C-Space>` on a list item creates todo list item without space between `*` and `[ ]`.
  * FIX: [Issue 110](https://code.google.com/p/vimwiki/issues/detail?id=110): Syntax highlighting doesn't work for indented codeblock.
  * FIX: [Issue 115](https://code.google.com/p/vimwiki/issues/detail?id=115): Nested Perl syntax highlighting differs from regular one.
  * MISC: Many vimwiki commands were renamed from `Vimwiki.*Word` to `Vimwiki.*Link`. `VimwikiGoHome` is renamed to `VimwikiIndex`, `VimwikiTabGoHome` to `VimwikiTabIndex`.
  * MISC: vimwiki-option-gohome is removed.

# 1.0 #
  * NEW: [Issue 41](https://code.google.com/p/vimwiki/issues/detail?id=41): Table cell and column text objects. See `vimwiki-text-objects`.
  * NEW: [Issue 42](https://code.google.com/p/vimwiki/issues/detail?id=42): Commands to move table columns left and right. See `:VimwikiTableMoveColumnLeft` and `:VimwikiTableMoveColumnRight`.
  * NEW: [Issue 44](https://code.google.com/p/vimwiki/issues/detail?id=44): `<S-Tab>` should move cursor to the previous table cell.
  * NEW: [Issue 45](https://code.google.com/p/vimwiki/issues/detail?id=45): It should be possible to indent tables. Indented tables are centered in html.
  * NEW: [Issue 46](https://code.google.com/p/vimwiki/issues/detail?id=46): Do not htmlize some wiki pages (blacklist). New placeholder is added: `%nohtml`. See `vimwiki-nohtml`.
  * FIX: [Issue 47](https://code.google.com/p/vimwiki/issues/detail?id=47): Lists aren't HTMLized properly.
  * FIX: [Issue 48](https://code.google.com/p/vimwiki/issues/detail?id=48): With autochdir it is impossible to have path\_html such as `d:\vimwiki\html\`
  * FIX: [Issue 49](https://code.google.com/p/vimwiki/issues/detail?id=49): Table is not HTMLized properly at the end of wiki page.
  * FIX: [Issue 50](https://code.google.com/p/vimwiki/issues/detail?id=50): Inline formatting is not performed in table cells.
  * FIX: [Issue 51](https://code.google.com/p/vimwiki/issues/detail?id=51): Cannot insert '-' (minus) into table cells of the first column.
  * FIX: [Issue 52](https://code.google.com/p/vimwiki/issues/detail?id=52): Table cell width is incorrect when double wide characters are used (ie. Chinese). Check `g:vimwiki_CJK_length`.
  * NEW: [Issue 53](https://code.google.com/p/vimwiki/issues/detail?id=53): Wiki markup can not nested. (Use links and inline markup in Headers).
  * NEW: [Issue 54](https://code.google.com/p/vimwiki/issues/detail?id=54): Highlight for placeholders.
  * NEW: [Issue 56](https://code.google.com/p/vimwiki/issues/detail?id=56): Directory indexes. See `g:vimwiki_dir_link` option and `:VimwikiGenerateLinks` command.
  * NEW: [Issue 58](https://code.google.com/p/vimwiki/issues/detail?id=58): Html new lines with `<br />`. Could be inserted with `<S-CR>` in insert mode.
  * FIX: [Issue 59](https://code.google.com/p/vimwiki/issues/detail?id=59): List item's text can't be started from `*`.
  * NEW: [Issue 60](https://code.google.com/p/vimwiki/issues/detail?id=60): Links inside completed gtd-items.
  * NEW: [Issue 61](https://code.google.com/p/vimwiki/issues/detail?id=61): Headers numbering. See `g:vimwiki_html_header_numbering` and `g:vimwiki_html_header_numbering_sym` options.
  * FIX: [Issue 63](https://code.google.com/p/vimwiki/issues/detail?id=63): Table cannot have leading empty cells in html.
  * FIX: [Issue 65](https://code.google.com/p/vimwiki/issues/detail?id=65): Table separator is not htmlized right if on top of the table.
  * FIX: [Issue 66](https://code.google.com/p/vimwiki/issues/detail?id=66): Table empty cells are very small in html.
  * FIX: [Issue 67](https://code.google.com/p/vimwiki/issues/detail?id=67): Wrong html conversion of multilined list item with bold text on the start of next line.
  * FIX: [Issue 68](https://code.google.com/p/vimwiki/issues/detail?id=68): auto-indent problem with langmap.
  * FIX: [Issue 73](https://code.google.com/p/vimwiki/issues/detail?id=73): Link navigation by Tab. "Escaped" wiki-word should be skipped for navigation with `<tab>`.
  * FIX: [Issue 75](https://code.google.com/p/vimwiki/issues/detail?id=75): `code` syntax doesn't display correctly in toc.
  * FIX: [Issue 77](https://code.google.com/p/vimwiki/issues/detail?id=77): Diary index only showing link to today's diary entry file for extensions other than '.wiki'.
  * FIX: [Issue 79](https://code.google.com/p/vimwiki/issues/detail?id=79): Further calendar.vim integration -- add sign to calendar date if it has corresponding diary page.
  * FIX: [Issue 80](https://code.google.com/p/vimwiki/issues/detail?id=80): Debian Lenny GUI Vim 7.2 has problems with toggling inner todo list items.
  * FIX: [Issue 81](https://code.google.com/p/vimwiki/issues/detail?id=81): Don't convert `WikiWord` as a link in html when `let g:vimwiki_camel_case = 0`

# 0.9.9 #
  * NEW: Diary. Help in making daily notes. See `:h vimwiki-diary`. Now you can really easy add information into vimwiki that should be sorted out later.
  * NEW: Tables are redesigned. Syntax is changed. Now they are auto-formattable. You can navigate them with `<tab>` and `<cr>` in insert mode. See `vimwiki-syntax-tables` and `vimwiki-tables` for more details.
  * NEW: Keyword STARTED: is added.
  * NEW: Words TODO:, DONE:, STARTED:, XXX:, FIXME:, FIXED: are highlighed inside headers.
  * FIX: Export to html external links with `file://` protocol. Ex: `[file:///home/user1/book.pdf my book]`.
  * FIX: Menu is corrupted if wiki's path contains spaces.
  * FIX: Settings `wrap` and `linebreak` are removed from ftplugin. Add them into your personal settings file `.vim/after/ftplugin/vimwiki.vim` if needed.
  * NEW: Headers are highlighted in different colors by default.  See `:h g:vimwiki_hl_headers` to turn it off.
  * FIX: [Issue 40](https://code.google.com/p/vimwiki/issues/detail?id=40): Links with russian subdirs don't work.
  * NEW: It is now possible to generate HTML files automatically on page save. See `:h vimwiki-option-auto_export`.


# 0.9.801 #
  * NEW: Rename `g:vimwiki_fold_empty_lines` to `g:vimwiki_fold_trailing_empty_lines`.
  * NEW: One can use `-` along with `*` to start unordered list item.
  * NEW: List items could be started from the first column.  As a result some limitations appeared:
    * a space after `*`, `-` or `#` for a list item is mandatory.
    * `g:vimwiki_fold_trailing_empty_lines` if set to 0 folds one trailing empty line.
  * NEW: Folding is off by default. Use `g:vimwiki_folding` to enable it.
  * NEW: Speed up vimwiki's folding a bit. Should lag a bit less in a long todo lists.
  * NEW: Centered headers. Start header with at least one space to make it html centered.
  * NEW: Change in default css: header's colors.
  * NEW: Vimwiki is aware of `GetLatestVimScripts` now.
  * FIX: Use `<del>` tag instead of custom `<span class="strike">` in html.
  * FIX: There are no text styling in htmlized quoted text.
  * FIX: set default value of `g:vimwiki_fold_lists` to 0 as written in this help.
  * FIX: [Issue 33](https://code.google.com/p/vimwiki/issues/detail?id=33): Folded list items have wrong indentation when 'tabs' are used.
  * FIX: [Issue 34](https://code.google.com/p/vimwiki/issues/detail?id=34): `vimwiki#subdir` got wrong dir when `VimwikiGet('path')` is a symbolic link. Thanks lilydjwg for the patch.
  * FIX: [Issue 28](https://code.google.com/p/vimwiki/issues/detail?id=28): todo-list auto-indent enhancement. New item should always be unchecked.
  * FIX: [Issue 36](https://code.google.com/p/vimwiki/issues/detail?id=36): Change the name of the `:Search` command to `:VimwikiSearch` as it conflicts with `MultipleSearch`. Alias `:VWS` is also available.
  * NEW: You can generate 'Table of contents' of your wiki page. See `:h vimwiki-toc` for details.

# 0.9.701 #
  * FIX: [Issue 30](https://code.google.com/p/vimwiki/issues/detail?id=30): Highlighting doesn't work for checked list item.

# 0.9.7 #
  * NEW: Default checkbox symbols are changed to `[ ]`, `[.]`, `[o]`, `[O]`, `[X]`.  You can change them using `g:vimwiki_listsyms` variable.
  * NEW: Color group names are renamed from wikiBold, wikiItalic, etc to `VimwikiBold`, `VimwikiItalic`, etc.
  * NEW: Open external links in a browser. There are default browsers defined in `g:vimwiki_browsers` list. You can also redefine `VimwikiWeblinkHandler` function to open weblinks in other programs.
  * NEW: [Issue 25](https://code.google.com/p/vimwiki/issues/detail?id=25): Toggle the states of multiple TODO list items at a time (in VISUAL and in VISUAL LINE modes)
  * NEW: [Issue 26](https://code.google.com/p/vimwiki/issues/detail?id=26): Highlight code snippets in vimwiki's pre. See `vimwiki-option-nested_syntaxes`. Thanks kriomant.
  * NEW: [Issue 27](https://code.google.com/p/vimwiki/issues/detail?id=27): Automatic garbage deletion from html directory.
  * NEW: Save all open vimwiki buffers before export to html.
  * NEW: [Issue 29](https://code.google.com/p/vimwiki/issues/detail?id=29): Custom `:Search` command.
  * NEW: Header text objects are now expandable in VISUAL mode. Tap 'vah' to select a header. Tap again 'ah' to expand selection further. Thanks Andy Wokula.
  * FIX: Folding settings are reset to vim defaults in a new tab (think of \wt) so you cannot hide things in folds.
  * FIX: https links in form of `[https://hello.world.com]` are not exported into html. Thanks Saurabh Sarpal for the patch.

# 0.9.6 #
  * NEW: You can have multiline list items. See `:h vimwiki-syntax-lists`.
  * NEW: You can ignore newlines in multiline list items when do export to html. See `:h g:vimwiki_list_ignore_newline` option.
  * NEW: Different checkbox symbols `[.]`, `[:]`, `[o]` are added. See `:h vimwiki-todo-lists`.
  * NEW: Now there is no longer syntax of preformatted text that is started by a whitespace.
  * NEW: Blockquotes. See `:h vimwiki-syntax-blockquote`.
  * NEW: Per wiki folding option (vimwiki-option-folding) is removed. Global `:h g:vimwiki_folding` and `:h g:vimwiki_fold_lists` are added.
  * NEW: Due to being quite slow folding of list items is off by default.  Use `:h g:vimwiki_fold_lists` to turn it on.
  * NEW: If you want replace some symbols in a wikifilename use `:h g:vimwiki_badsyms` option (Andreas Baldeau).
  * FIX: Command `:VimwikiToggleListItem` doesn't work for one of the two wikies opened at the same time with different syntaxes.
  * FIX: Command `:VimwikiToggleListItem` do not switch parent checkboxes if there are non-checkbox list items available.
  * FIX: [Issue 24](https://code.google.com/p/vimwiki/issues/detail?id=24): Link error in html when write `[[one.two.three]]`.
  * FIX: Rename `WikiWord` to something with a colon (:) does nasty things.
  * FIX: Command `:VimwikiToggleListItem` do not switch right if there are list items without checkboxes in the list.

# 0.9.5 #
  * NEW: Added `g:vimwiki_global_ext` to control creation of temporary wikies in a dirs that are not listed in `g:vimwiki_list`.
  * NEW: Added `g:vimwiki_hl_headers` to highlight headers with different predefined colors.
  * NEW: Checked `[x]` items are not highlighted with Comment syntax group by default. Use `g:vimwiki_hl_cb_checked` to turn it on.
  * NEW: Added new syntax for links: `[[link address][link description]]`.
  * NEW: Added `<C-@>` allias of `<C-Space>` mapping for `*nix` systems.
  * NEW: Added `g:vimwiki_camel_case`. Set it to 0 if you do not want `CamelCased` `WikiWords` to be linkified.
  * FIX: Links with `g:viwmiki_stripsym` (default `'_'`) `[[My_Link|Text]]` are not highlighted when created.
  * FIX: `indent/vimwiki.vim` is obsolete. If you upgrade from previous versions remove it. It causes wrong list indentation if noexpandtab is set.
  * FIX: If tabs and spaces are used to indent list items html export gives error. Thanks Klaus Ethgen for report.
  * FIX: Some html export fixes.

# 0.9.4 #
  * NEW: Links with directories: `[[dir_name/Link|Text]]`. Thanks Jie Wu.
  * NEW: Added %root\_path% template variable to get relative root dir of path\_html. See `:h vimwiki-option-html_header`.
  * FIX: Indent incorrect for vim without "float" compile option. Thanks Julian Kooij.
  * FIX: Convert to html doesn't work right with links like `[[foo::bar]]`.
  * FIX: Rename wikiword doesn't work right when rename `WikiWord` to `[[WikiWord blablabla]]`.
  * FIX: Renaming of links with description doesn't work.
  * FIX: Weblinks with commas are not highlighted.
  * MISC: Some changes in default css file.

# 0.9.3 #
  * NEW: `g:vimwiki_menu` option is a string which is menu path. So one can use `let g:vimwiki_menu = 'Plugin.Vimwiki'` to set the menu to the right place.
  * NEW: `g:vimwiki_fold_empty_lines` -- don't or do fold in empty lines between headers. See `:h g:vimwiki_fold_empty_lines`
  * FIX: Encoding error when running vimwiki in Windows XP Japanese.  Thanks KarasAya.

# 0.9.2c #
  * FIX: Regression bug. Export to HTML of `[[link|desc]]` is wrong.

# 0.9.2b #
  * FIX: Installation on Linux doesn't work. (Dos line endings in Vimball archive file).
  * FIX: Clear out FlexWiki ftplugin's setup. Now you don't have to hack filetype.vim to get rid of unexpected ':setlocal bomb' from FlexWiki's ftplugin.
  * FIX: When write done: it will show another done: in html file.

# 0.9.2a #
  * FIX: Remove dos line endings from some files.

# 0.9.2 #
  * NEW: Option 'folding' added to turn folding on/off.
  * NEW: Header text object. See `:h vimwiki-text-objects`.
  * NEW: Add/remove Header levels with '=' and '-'. See `:h vimwiki_=`.
  * NEW: Vimwiki GUI menu to select available wikies. See `:h g:vimwiki_menu`.
  * NEW: You can specify the name of your css file now. See `:h vimwiki-option-css_name`
  * NEW: You can add styles to image links, see `:h vimwiki-syntax-links`.
  * FIX: History doesn't work after `:VimwikiRenameWord`.
  * FIX: Some of wikipedia links are not correctly highlighted. Links with parentheses.
  * MISC: Renamed vimwiki\_gtd to vimwiki\_lst.

# 0.9.1 #
  * NEW: HTML Table cell text alignment, see `:h vimwiki-syntax-tables`
  * NEW: Wikipage history simplified. Each vimwiki buffer now holds `b:vimwiki_prev_word` which is list of `[PrevWord, getpos()]`.
  * NEW: If highlight for groups wikiHeader1..wikiHeader6 exist (defined in a colorscheme) -- use it. Otherwise use Title highlight for all Headers.
  * FIX: Warn only once if `html_header` or `html_footer` does not exist.
  * FIX: Wrong folding for the text after the last nested list item.
  * FIX: Bold and Italic aren't highlighted in tables without spaces between `||` and `*` or `_`. `||*bold*||_asdf_ ||` (Thanks Brett Stahlman)

# 0.9.0 #
  * NEW: You can add classes to 'pre' tag -- `:h vimwiki-syntax-preformatted`. This might be useful for coloring some programming code with external js tools like google syntax highlighter.
  * NEW: WikiPage is not highlighted. It is just a plain word WikiPage in HTML, without exclamation mark
  * NEW: Definition lists, see `:h vimwiki-syntax-lists`.
  * NEW: New implementation of `:h VimwikiRenameWord`. CAUTION: It was tested on 2 computers only, backup your wiki before use it. Email me if it doesn't work for you.
  * NEW: HTML: convert `[ ]` to html checkboxes.
  * NEW: Default CSS: gray out checked items.
  * FIX: Less than 3 characters are not highlighted in Bold and Italic.
  * FIX: Added vimwiki autocmd group to avoid clashes with user defined autocmds.
  * FIX: Pressing ESC while `:VimwikiUISelect` opens current wiki index file.  Should cancel wiki selection.

# 0.8.3 #
  * NEW: `<C-Space>` on a list item creates checkbox.
  * FIX: With `*` in the first column, `<CR>` shouldn't insert more `*` (default syntax).
  * FIX: With MediaWiki's `** [ ]`, `<CR>` should insert it on the next line.
  * FIX: HTML export should use 'fileencoding' instead of 'encoding'.
  * FIX: Code cleanup.

# 0.8.2 #
  * DEL: Removed google syntax file.
  * NEW: Default vimwiki syntax is a subset of google's one. Header's has been changed from `!Header` to `=Header=`. It is easier to maintain only 2 syntaxes. See :h vimwiki-syntax-headers.
  * NEW: Multiline paragraphs -- less longlines.
  * NEW: Comments. See :h vimwiki-syntax-comments.
  * DEL: Removed setlocal textwidth = 0 from ftplugin.
  * FIX: New regexps for bold, italic, bolditalic.
  * FIX: The last item in List sometimes fold-in incorrectly.
  * FIX: Minor tweaks on default css.

# 0.8.1 #
  * NEW: Vimwiki's foldmethod changed from syntax to expr. Foldtext is changed to be nicer with folded list items.
  * NEW: Fold/outline list items.
  * NEW: It is possible now to edit wiki files in arbitrary directories which is not in g:vimwiki\_list's paths. New WikiWords are created in the path of the current WikiWord.
  * NEW: User can remap Vimwiki's built in mappings.
  * NEW: Added `g:vimwiki_use_mouse`. It is off by default.
  * FIX: Removed `<C-h>` mapping.

# 0.8.0 #
  * NEW: Multiple wikies support. A lot of options have been changed, see `:h vimwiki-options`
  * NEW: Auto create directories.
  * NEW: Checked list item highlighted as comment.
  * FIX: Multiple `set ft=vimwiki` for each buffer disabled. Vimwiki should load its buffers a bit faster now.

# 0.7.1 #
  * NEW: `<Plug>VimwikiToggleListItem` added to be able to remap `<C-Space>` to anything user prefers more.
  * FIX: Toggleable list items do not work with MediaWiki markup.
  * FIX: Changing `g:vimwiki_home_html` to path with ~ while vimwiki is loaded gives errors for HTML export.
  * DEL: Command `:VimwikiExploreHome`.

# 0.7 #
  * NEW: GTD stuff -- toggleable list items. See `h: vimwiki-gtd`.
  * FIX: Headers do not fold inner headers. (Thanks Brett Stahlman)
  * FIX: Remove last blank lines from preformatted text at the end of file (HTML).
  * DEL: Removed g:vimwiki\_smartCR option.

# 0.6.2 #
  * NEW: `[[link|description]]` is available now.
  * FIX: Barebone links (ie: `http://bla-bla-bla.org/h.pl?id=98`) get extra escaping of ? and friends so they become invalid in HTML.
  * FIX: In linux going to `[[wiki with whitespaces]]` and then pressing BS to go back to prev wikipage produce error. (Thanks Brendon Bensel for the fix)
  * FIX: Remove setlocal encoding and fileformat from vimwiki ftplugin.
  * FIX: Some tweaks on default style.css

# 0.6.1 #
  * FIX: `[blablabla bla]` shouldn't be converted to a link.
  * FIX: Remove extra annoing empty strings from PRE tag made from whitespaces in HTML export.
  * FIX: Moved functions related to HTML converting to new autoload module to increase a bit vimwiki startup time.

# 0.6 #
  * NEW: Header and footer templates. See `g:vimwiki_html_header` and `g:vimwiki_html_footer` in help.
  * FIX: `:Vimwiki2HTML` does not recognize ~ as part of a valid path.

# 0.5.3 #
  * FIX: Fixed `:VimwikiRenameWord`. Error when g:vimwiki\_home had whitespaces in path.
  * FIX: `:VimwikiSplitWord` and `:VimwikiVSplitWord` didn't work.

# 0.5.2 #
  * NEW: Added `:VimwikiGoHome`, `:VimwikiTabGoHome` and `:VimwikiExploreHome` commands.
  * NEW: Added `<Leader>wt` mapping to open vimwiki index file in a new tab.
  * NEW: Added g:vimwiki\_gohome option that controls how `:VimwikiGoHome` works when current buffer is changed. (Thanks Timur Zaripov)
  * FIX: Fixed `:VimwikiRenameWord`. Very bad behaviour when autochdir isn't set up.
  * FIX: Fixed commands `:Wiki2HTML` and `:WikiAll2HTML` to be available only for vimwiki buffers.
  * FIX: Renamed `:Wiki2HTML` and `:WikiAll2HTML` to `:Vimwiki2HTML` and `:VimwikiAll2HTML` commands.
  * FIX: Help file corrections.

# 0.5.1 #
  * NEW: Help file is created.
  * NEW: Now you can fold headers.
  * NEW: `<Plug>VimwikiGoHome` and `<Plug>VimwikiExploreHome` were added.
  * FIX: Bug with `{{{HelloWikiWord}}}` export to HTML is fixed.
  * DELETED: Sync option removed from: Syntax highlighting for preformatted text `{{{ }}}`.

# 0.5 #
  * NEW: vimwiki default markup to HTML conversion improved.
  * NEW: Added basic `GoogleWiki` and `MediaWiki` markup languages.
  * NEW: Chinese `[[complex wiki words]]`.

# 0.4 #
  * NEW: vimwiki=>HTML converter in plain vim language.
  * NEW: Plugin autoload.

# 0.3.4 #
  * FIX: Backup files (.wiki~) caused a bunch of errors while opening wiki files.

# 0.3.3 #
  * FIX: `[[wiki word with dots at the end...]]` didn't work.
  * NEW: Added error handling for `delete wiki word` function.
  * NEW: Added keybindings `o` and `O` for list items when g:vimwiki\_smartCR=1.
  * NEW: Added keybinding `<Leader>wh` to visit wiki home directory.

# 0.3.2 #
  * FIX: Renaming - error if complex wiki word contains %.
  * FIX: Syntax highlighting for preformatted text ` `. Sync option added.
  * FIX: smartCR bug fix.

# 0.3.1 #
  * FIX: Renaming - `[[hello world?]]` to `[[hello? world]]` links are not updated.
  * FIX: Buffers menu is a bit awkward after renaming.
  * NEW: Use mouse to follow links. Left double-click to follow `WikiWord`, Rightclick then Leftclick to go back.

# 0.3 #
  * NEW: - Highlight non-existent `WikiWords`.
  * NEW: - delete current `WikiWord` (`<Leader>wd`).
  * NEW: - g:vimwiki\_smartCR=2 => use vim `comments` (see `:h comments` `:h formatoptions`) feature to deal with list items. (thx - Dmitry Alexandrov)
  * NEW: Add highlighting to TODO:, DONE:, FIXED:, FIXME:.
  * NEW: Rename current `WikiWord` - be careful on Windows you cannot rename `wikiword` to `WikiWord`. After renaming update all links to that renamed `WikiWord`.
  * FIX: Bug - do not duplicate `WikiWords` in wiki history.
  * FIX: after renaming `[[wiki word]]` twice buffers are not deleted.
  * FIX: when renaming from `[[wiki word]]` to `WikiWord` result is `[[WikiWord]]`
  * FIX: more than one complex words on one line is bugging each other when try go to one of them. `[[bla bla bla]] [[dodo dodo dodo]]` becomes `bla bla bla ]] [[dodo dodo dodo`.


# 0.2.2 #
  * NEW: Added keybinding `<S-CR>` - split `WikiWord`
  * NEW: Added keybinding `<C-CR>` - vertical split `WikiWord`

# 0.2.1 #
  * NEW: Install on linux now works.

# 0.2 #
  * NEW: Added part of Google's Wiki syntax.
  * NEW: Added auto insert # with ENTER.
  * NEW: On/Off auto insert bullet with ENTER.
  * NEW: Strip `[[complex wiki name]]` from symbols that cannot be used in file names.
  * NEW: Links to non-wiki files. Non wiki files are files with extensions ie `[[hello world.txt]]` or `[[my homesite.html]]`

# 0.1 #
  * First public version.