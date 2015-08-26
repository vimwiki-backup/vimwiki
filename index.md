# Personal Wiki for Vim #
Hosted on [vim scripts](http://www.vim.org/scripts/script.php?script_id=2226) too.

# Screenshots #
|![![](http://vimwiki.googlecode.com/svn/screenshots/tn_vimwiki1.png)](http://vimwiki.googlecode.com/svn/screenshots/vimwiki1.png)|![![](http://vimwiki.googlecode.com/svn/screenshots/tn_vimwiki2.png)](http://vimwiki.googlecode.com/svn/screenshots/vimwiki2.png)|![![](http://vimwiki.googlecode.com/svn/screenshots/tn_vimwiki3.png)](http://vimwiki.googlecode.com/svn/screenshots/vimwiki3.png)|![![](http://vimwiki.googlecode.com/svn/screenshots/tn_vimwiki4.png)](http://vimwiki.googlecode.com/svn/screenshots/vimwiki4.png)|
|:--------------------------------------------------------------------------------------------------------------------------------|:--------------------------------------------------------------------------------------------------------------------------------|:--------------------------------------------------------------------------------------------------------------------------------|:--------------------------------------------------------------------------------------------------------------------------------|

# Quick start #
Vimwiki is a personal wiki for Vim. Using it you can organize text files with
hyperlinks. To do a quick start press `<Leader>ww` (this is usually \ww) to go
to your index wiki file. By default it is located in:
```
~/vimwiki/index.wiki
```
You do not have to create it manually -- vimwiki can make it for you.

Feed it with the following example:
```
= My knowledge base =
  * MyUrgentTasks -- things to be done _yesterday_!!!
  * ProjectGutenberg -- good books are power.
  * MusicILike, MusicIHate.
```

Notice that ProjectGutenberg, MyUrgentTasks, !MusicILike and !MusicIHate
highlighted as errors. These WikiWords (WikiWord or WikiPage --
capitalized word connected with other capitalized words) do not exist yet.

Place cursor on ProjectGutenberg and press Enter. Now you are in
ProjectGutenberg. Edit and save it, then press Backspace to return
to previous WikiPage. You should see the difference in highlighting now.

Now it's your turn ...

## Help ##
After installation, `:help vimwiki` shows a detailed description of all the features.

A condensed one-page summary of help: a printable [Vimwiki 1.1.1 Quick Reference](http://vimwiki.googlecode.com/hg/misc/Vimwiki1.1.1QR.pdf) (90 KiB PDF, A4 paper, landscape).

For the various options see `:h vimwiki-options`


# Other pages #
  * [[Prerequisites](Prerequisites.md)]
  * [[Installation](Installation.md)]
  * [[Syntax](Syntax.md)]
  * KeyAndMouseMappings
  * [[Commands](Commands.md)]
  * MultipleWikies
  * HighlightProgrammingCode
  * HighlightHeaders
  * KnownIssues
  * ChangeLog
  * GuestBook