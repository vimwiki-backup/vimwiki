# Vimwiki development goes to github #
Google code closes "Downloads" and thus we wouldn't be able to distribute vimwiki releases the way it was. On the other hand there are other ways to distribute vim plugins available: pathogen or vundle. Plus github.com, where one can find vast majority of vim plugins as a separate repos or united under vim-scripts's mirror. Not to mention there is an easy way to download zipped vimwiki sources which is practically the same as vimwiki-2-1.zip we have at "Downloads" tab.

So meet https://github.com/vimwiki/vimwiki




# Description #
Hosted on [vim scripts](http://www.vim.org/scripts/script.php?script_id=2226) too.

Vimwiki is a personal wiki for Vim -- a number of linked text files that have
their own syntax highlighting.

With vimwiki you can
  * organize notes and ideas
  * manage todo-lists
  * write documentation


# Screenshots #
|![![](http://vimwiki.googlecode.com/hg/screenshots/tn_vimwiki1.png)](http://vimwiki.googlecode.com/hg/screenshots/vimwiki1.png)|![![](http://vimwiki.googlecode.com/hg/screenshots/tn_vimwiki2.png)](http://vimwiki.googlecode.com/hg/screenshots/vimwiki2.png)|![![](http://vimwiki.googlecode.com/hg/screenshots/tn_vimwiki3.png)](http://vimwiki.googlecode.com/hg/screenshots/vimwiki3.png)|![![](http://vimwiki.googlecode.com/hg/screenshots/tn_vimwiki4.png)](http://vimwiki.googlecode.com/hg/screenshots/vimwiki4.png)|
|:------------------------------------------------------------------------------------------------------------------------------|:------------------------------------------------------------------------------------------------------------------------------|:------------------------------------------------------------------------------------------------------------------------------|:------------------------------------------------------------------------------------------------------------------------------|


# Quick start #
Press `<Leader>ww` (this is usually `\ww`) to go to your index wiki file. By
default it is located in:
```
~/vimwiki/index.wiki
```

Feed it with the following example:
```
= My knowledge base =
    * My Urgent Tasks -- things to be done _yesterday_!!!
    * Project Gutenberg -- good books are power.
    * Scratch Pad -- various temporary stuff.
```

Place your cursor on 'Tasks' and press Enter to create a link.  Once pressed,
'Tasks' will become '`[[Tasks]]`' -- a vimwiki link.  Press Enter again to
open it.  Edit the file, save it, and then press Backspace to jump back to your
index.

A vimwiki link can be constructed from more than one word.  Just visually
select the words to be linked and press Enter.  Try it with 'Project
Gutenberg'.  The result should look something like:
```
= My knowledge base =
    * [[Tasks]] -- things to be done _yesterday_!!!
    * [[Project Gutenberg]] -- good books are power.
    * Scratchpad -- various temporary stuff.
```

For the various options see `:h vimwiki-options`.
