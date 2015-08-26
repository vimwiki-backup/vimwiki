# Multiple wikies #
There is g:vimwiki\_list global variable which is a list with options for wikies you could have.

Each item in g:vimwiki\_list is a Dictionary (`:h Dictionary`) that holds all customization available for a wiki represented by that item. It is in form of
```
  {'option1': 'value1', 'option2: 'value2', ...}
```

Consider the following example:
```
  let g:vimwiki_list = [{'path': '~/my_site/', 'path_html': '~/public_html/'}]
```
It gives us one wiki located at ~/my\_site/ that could be htmlized to
~/public\_html/

The next example:
```
  let g:vimwiki_list = [{'path': '~/my_site/', 'path_html': '~/public_html/'},
            \ {'path': '~/my_docs/', 'ext': '.mdox'}]
```
gives us 2 wikies, first wiki as in previous example, second one is located in
~/my\_docs/ and its files have .mdox extension.

Empty Dictionary in the g:vimwiki\_list is the wiki with default options:
```
  let g:vimwiki_list = [{},
            \ {'path': '~/my_docs/', 'ext': '.mdox'}]
```

If you have 2 or more wikies in the g:vimwiki\_list then hitting `<Leader>ww` opens first wiki, `2<Leader>ww` -- second, `3<Leader>ww` -- third etc.
There is also `<Leader>ws` that lists available wikies you could select.