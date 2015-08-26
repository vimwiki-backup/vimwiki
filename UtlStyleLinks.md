# Introduction #

The [Univeral Text Linking](http://www.vim.org/scripts/script.php?script_id=293) Vim plugin has some good ideas about links.

# UTL-style links #

  * `wikiname/PageName`: interwiki-link.
  * `PageName#sometext`: search for `sometext` on `PageName`.  (less complicated than UTL: if you want to search for an ID, just write `PageName#id=someid`, it's just a plain search like any other).
  * `wikiname/PageName#sometext`: `sometext` on `PageName` in `wikiname`.

## Considerations ##

  * Renaming pages would have to search cross-wiki.
  * How would renaming/moving wiki's work? Manually change `.vimrc` and modify the links afterwards?