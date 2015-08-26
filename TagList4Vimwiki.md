# Introduction #
Insert `%toc` in Vimwiki file(.wiki), and convert it to html,
we will have a table of contents in the html document.

and now we use taglist and ctags to show the outline for wiki file.

# Installation #
[Exuberant Ctags](http://ctags.sourceforge.net/):
  1. Download ctags and intall it.
> > !IMPORTANT need ctags v5.8 +regex support.
  1. Extract ctags.exe to $path for Windows(C:\Windows\system32), use command `ctags -version` in commandline to test.
  1. or extract to any path and set vimrc:
```
" for Windows:
let g:ctags_path='path\to\ctags.exe'
```

[TagList](http://www.vim.org/scripts/script.php?script_id=273):
  1. Download and extract taglist.vim to $VIM\vimfiles\plugin or ~/.vim/plugin.
  1. vimrc setting:
```
filetype on
let g:Tlist_Use_Right_Window=1
let g:Tlist_WinWidth=25
" If ctags not in $path, set this.
"let Tlist_Ctags_Cmd='path\to\ctags.exe'
nnoremap <F12> :TlistToggle<CR>
```

# Details #
$HOME/.ctags setting:<br />
for Windows create `$HOME\.ctags` or `$HOME\ctags.cnf` file.<br />
for Linux or Mac: `~/.ctags`
```
--langdef=wiki
--langmap=wiki:.wiki
--regex-wiki=/^=[ \t]+(.+)[ \t]+=$/\1/h,header/
--regex-wiki=/^==[ \t]+(.+)[ \t]+==$/. \1/h,header/
--regex-wiki=/^===[ \t]+(.+)[ \t]+===$/.   \1/h,header/
--regex-wiki=/^====[ \t]+(.+)[ \t]+====$/.     \1/h,header/
--regex-wiki=/^=====[ \t]+(.+)[ \t]+=====$/.       \1/h,header/
--regex-wiki=/^======[ \t]+(.+)[ \t]+======$/.         \1/h,header/
```
or simply:
```
--langdef=wiki
--langmap=wiki:.wiki
--regex-wiki=/^(={1,6})[ \t]+(.+)[ \t]+\1$/\2/h,header/
```

vimrc setting:
```
let tlist_vimwiki_settings = 'wiki;h:Headers'
```

Screenshot: <br />
http://www.flickr.com/photos/hotoo/4555003526/ <br />
http://www.flickr.com/photos/hotoo/4553944243/