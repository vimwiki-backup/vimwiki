# Normalize Link Syntax #

Note: This page is out of date.  Please see
[the newer version](http://code.google.com/p/vimwiki/wiki/NormalizeLinkSyntax).

## Command ##

The NormalizeLinkSyntax command is activated by the `+` key.  It can be activated in normal mode with the cursor over a link, or in visual mode with a text-selection over a link.  It converts links from a number of recognized formats into the user's preferred format, or syntax.  Some examples of conversions are shown here.  Numerous examples are given in the testing section below.

  1. `Wikiword` _is converted to_ `[[Wikiword][Wikiword]]`
  1. `[[Target|Description]]` _is converted to_ `[[Target][Description]]`
  1. `"github.com":http://github.com` _is converted to_ `[github.com](http://github.com)`

NormalizeLinkSyntax operates on the variety of links recognized by Vimwiki.
  * Wikilinks:
    1. `WikiWord`
    1. `[[URL]]`
    1. `[[URL][DESCRIPTION]]`
    1. `[[URL|DESCRIPTION]]`
  * Weblinks:
    1. `URL`
    1. `[URL DESCRIPTION]`
    1. `"DESCRIPTION(OPTIONAL)":URL`
    1. `[DESCRIPTION](URL)`
  * Image Links
    1. `IMGURL`
    1. `[[IMGURL]]`
    1. `[[IMGURL][DESCR]]`
    1. `[[IMGURL][DESCR][STYLE]]`
    1. `[[IMGURL|DESCR]]`
    1. `[[IMGURL|DESCR|STYLE]]`
  * Thumbnail Links
    1. `[IMGURL](URL)`
    1. `[URL IMGURL]`
    1. `"IMGURL":URL` <-- XXX: Textile weblink syntax is likely to be dropped
    1. `[[URL][IMGURL]]`
    1. `[[URL|IMGURL]]`
A developer can add new formats simply by adding the requisite regular expressions, as shown in `plugin/vimwiki.vim`

The user's preferred link syntaxes are defined as templates in their `syntax/vimwiki_SYNTAX.vim` file.  These are already defined for existing syntax files.  For example, in the file `syntax/vimwiki_markdown.vim`

```
" default wikilink template
let g:vimwiki_WikilinkTemplate = '[[__LinkUrl__][__LinkDescription__]]'
" default weblink template
let g:vimwiki_WeblinkTemplate = '[__LinkDescription__](__LinkUrl__)'
" default imagelink template
let g:vimwiki_ImageTemplate = '[[__LinkUrl__][__LinkDescription__][__LinkStyle__]]'
```

Within templates, the following strings are placeholders for the corresponding text-objects matched by NormalizeLinkSyntax (via regular expressions) when activated over such a link:
  * `__LinkUrl__` : _The target_
  * `__LinkDescription__` : _The description text_
  * `__LinkSytle__` : _The style text_

NormalizeLinkSyntax tries to be smart about the conversion when from the local context it is not clear whether the text-object is a wikilink or a weblink, for example `[[http://github.com]]`.  Is this an unusual wikilink or an improperly formatted weblink!?  If an embedded text-object is detected, the command may (1) leave it unchanged, (2) convert it into an embedded wikilink/weblink, or (3) replace the surrounding context with the converted wikilink/weblink.  Instead of trying to document this logic in detail, a number of test examples are included below to demonstrate standard usage as well as some boundary cases.

Please share your experiences using this command, idiosyncratic behaviour, and suggested improvements.  The preferred way to do this is via the [issue tracker](http://code.google.com/p/vimwiki/issues/list).

## Limitations ##

  1. Does not work for line-wise visual mode
  1. Whitespace around the visual selection is not trimmed, even though this seems like a sensible thing to do
  1. When a link is detected in a visual selection, the converted region should be trimmed to size of the link, otherwise some surrounding text may be deleted by a conversion
  1. Unpredictable conversions may occur within embedded link contexts; their are endless varieties of these, and many are syntactically invalid

## Test Examples ##

Each example below consists of 4 lines
  1. activation key-sequence
  1. input text
  1. cursor/selection when NormalizeLinkSyntax is activated
  1. output text followed by an optional comment **## formatted like this**

In other words, if one positions the cursor in the first column of the input (2nd line) and types the key-sequence (1st line), the NormalizeLinkSyntax command will be activated with the cursor/selection as indicated by the `^` characters (3rd line) producing the output in the (4th line), modulo comments.

These examples use the template definitions shown above for `syntax/vimwiki_markdown.vim`.

### Examples: Raw Text ###

```
+
this is the index
^
this is the index
```

```
vwl+
this is the index
^^^^^^^
[[this is][this is]] the index
```

```
v$+
this is the index
^^^^^^^^^^^^^^^^^^
[[this is the index][this is the index]]
```

```
V+
this is the index
^^^^^^^^^^^^^^^^^^
this is the index
```

### Examples: Raw Text, Overlapping Explicit [[-Wikilink ###

```
+
[[this is][this is]] the index
^
[[this is][this is]] the index
```

```
w+
[[this is][this is]] the index
  ^
[[this is][this is]] the index
```

```
wvwl+
[[this is][this is]] the index
  ^^^^^^^
[[this is][this is]] the index
```

```
v$+
[[this is][this is]] the index
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
[[this is][this is]] ## visual_selection should be trimmed to size of the link detected at the cursor
```

```
%lv$+
[[this is][this is]] the index
                    ^^^^^^^^^^^
[[this is][this is]][[ the index][ the index]] ##  whitespace around the visual selection should be trimmed
```

### Examples: Raw Text, Word But Not A Wikiword ###

```
+
Page2
^
Page2
```

```
v$+
Page2
^^^^^^
[[Page2][Page2]]
```

```
V+
Page2
^^^^^^
Page2
```

```
llv$+
Page2
  ^^^^
Pa[[ge2][ge2]]
```

### Examples: Explicit [[-Wikilink, Word But Not A Wikiword ###

```
+
[[Page2]]
^
[[Page2][Page2]]
```

```
w+
[[Page2]]
  ^
[[Page2][Page2]]
```

```
v$+
[[Page2]]
^^^^^^^^^^
[[Page2][Page2]]
```

```
wviw+
[[Page2]]
  ^^^^^
[[Page2]] ## DOES NOT normalize
```

### Examples: Raw Text, Wikiword ###

```
+
PageTwo
^
[[PageTwo][PageTwo]]
```

```
v$+
PageTwo
^^^^^^^^
[[PageTwo][PageTwo]]
```

```
viw+
PageTwo
^^^^^^^
[[PageTwo][PageTwo]]
```

```
llv$+
PageTwo
  ^^^^^^
PageTwo ## DOES NOT normalize
```

### Examples: Explicit [[-Wikilink, Wikiword ###

```
+
[[PageTwo]]
^
[[PageTwo][PageTwo]]
```

```
w+
[[PageTwo]]
  ^
[[PageTwo][PageTwo]]
```

```
v$+
[[PageTwo]]
^^^^^^^^^^^^
[[PageTwo][PageTwo]]
```

```
viw+
[[PageTwo]]
^^
[[PageTwo]]
```

```
wviw+
[[PageTwo]]
  ^^^^^^^
[[[[PageTwo][PageTwo]]]] ## DOES normalize
```

### Examples: Explicit [[-Wikilink, Wikiword, Description ###

```
+
[[PageTwo][The second page]]
^
[[PageTwo][The second page]]
```

```
w+
[[PageTwo][The second page]]
  ^
[[PageTwo][The second page]]
```

```
wviw+
[[PageTwo][The second page]]
  ^^^^^^^
[[[[PageTwo][PageTwo]]][The second page]] ## DOES normalize
```

```
wviw+
[[Page2][The 2nd page]]
  ^^^^^
[[Page2][The 2nd page]] ## DOES NOT normalize
```

```
wwwvt]+
[[PageTwo][The second page]]
           ^^^^^^^^^^^^^^^
[[PageTwo][The second page]] ## DOES NOT normalize
```

```
wwwwv$+
[[PageTwo][The second page]]
               ^^^^^^^^^^^^^^
[[PageTwo][The second page]]
```

### Examples: Explicit [[-Wikilink, Description, Alternate Style |-Separator ###

```
+
[[PageTwo|The second page]]
^
[[PageTwo][The second page]]
```

```
w+
[[PageTwo|The second page]]
  ^
[[PageTwo][The second page]]
```

```
wviw+
[[PageTwo|The second page]]
  ^^^^^^^
[[[[PageTwo|The second page]]|The second page]] ## DOES normalize - visual_selection should be resized to type of link detected at the cursor
```

```
wviw+
[[Page2|The 2nd page]]
  ^^^^^
[[Page2|The 2nd page]] ## DOES NOT normalize
```

```
wwwvt]+
[[PageTwo|The second page]]
          ^^^^^^^^^^^^^^^
[[PageTwo|The second page]] ## DOES NOT normalize
```

```
wwwwv$+
[[PageTwo|The second page]]
              ^^^^^^^^^^^^^^
[[PageTwo|The second page]]
```

### Examples: Raw Url ###

```
+
http://github.com
^
[github](http://github.com)
```

```
ww+
http://github.com
       ^
[github](http://github.com)
```

```
v$+
http://github.com
^^^^^^^^^^^^^^^^^^
[github](http://github.com)
```

```
wwv$+
http://github.com
       ^^^^^^^^^^^
http://github.com ## DOES NOT normalize
```

### Examples: Default Weblink ###

```
+
[github](http://github.com)
^
[github](http://github.com)
```

```
w+
[github](http://github.com)
 ^
[github](http://github.com)
```

```
www+
[github](http://github.com)
         ^
[github](http://github.com)
```

```
v$+
[github](http://github.com)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^
[github](http://github.com)
```

```
wwwv$+
[github](http://github.com)
         ^^^^^^^^^^^^^^^^^^^
[github]([github](http://github.com) ## DOES normalize
```

### Examples: Alternate Style Weblink ###

```
+
"github":http://github.com
^
[github](http://github.com)
```

```
w+
"github":http://github.com
 ^
[github](http://github.com)
```

```
www+
"github":http://github.com
         ^
[github](http://github.com)
```

```
v$+
"github":http://github.com
^^^^^^^^^^^^^^^^^^^^^^^^^^^
[github](http://github.com)
```

```
wwwv$+
"github":http://github.com
         ^^^^^^^^^^^^^^^^^^
"github":[github](http://github.com) ## DOES normalize
```

### Examples: Default Weblink, Wikiword ###

```
wviw+
[GitHub](http://GitHub.com)
 ^^^^^^
[GitHub](http://GitHub.com)
```

```
wwwwwviw+
[GitHub](http://GitHub.com)
                ^^^^^^
[GitHub](http://GitHub.com) ## DOES NOT normalize
```

### Examples: Explicit [[-Wikilink, Raw Url ###

```
+
[[http://github.com]]
^
[[http://github.com][http://github.com]]
```

```
w+
[[http://github.com]]
  ^
[[[github](http://github.com)]]
```

```
wvi]+
[[http://github.com]]
  ^^^^^^^^^^^^^^^^^
[[[github](http://github.com)]]
```

```
v$+
[[http://github.com]]
^^^^^^^^^^^^^^^^^^^^^^
[github](http://github.com)  ## visual_selection should be trimmed to size of the link detected at the cursor
```


