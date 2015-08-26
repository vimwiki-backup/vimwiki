# Normalize Link Syntax #

Note:  The original page, which elicited the discussion below from January 30th
to February 6th, 2012, has been saved for posterity
[here](http://code.google.com/p/vimwiki/wiki/NormalizeLinkSyntaxV0).

## Command ##

The NormalizeLinkSyntax command is activated by the `+` key.  It can be
activated in normal mode with the cursor over a word.

The command adds placeholder text to Wiki or Web Links that are missing
descriptions, it converts raw URLs into Web Links, and it converts words into
Wikilinks.  For example:

  1. `[[URL]]` _normalizes to_ `[[URL][clean_URL]]`
> > e.g. `[[http://github.com]]` _normalizes to_ `[[http://github.com][github]]`
  1. `[URL ]` _normalizes to_ `[URL clean_URL]`
> > e.g. `[http://github.com ]` _normalizes to_ `[http://github.com github]`
  1. `URL` _normalizes to_ `[URL clean_URL]`
> > e.g. `http://github.com` _normalizes to_ `[http://github.com github]`
  1. `Word` _normalizes to_ `[[Word]]`

Normalized links are not affected by further application of the command.
Thumbnail Links are not affected by NormalizeLinkSyntax since by definition
they already have descriptions.  NormalizeLinkSyntax does not modify Wiki-
Include Links because their semantics may be redefined by users.

NormalizeLinkSyntax prefers certain links over others when choosing the link
context to convert.  For example, when the cursor is positioned over the URL in
`[[http://github.com]]` there are two plausible normalizations.  The first is
to ignore the surrounding `[[` and `]]` braces and generate
`[http://github.com github]`.  The second is to respect the surrounding context
and generate `[[http://github.com][github]]`.

NormalizeLinkSyntax selects as context the first enclosing link returned by
searching, in the following order, for: 1) Wikilinks, 2) Web Links, 3) Image
Links, 4) Raw URLs, and 5) Raw Words.

Note: Support for visual mode is experimental and may produce unexpected
results.  This feature may be deprecated.

## Examples ##

Each example below consists of 4 lines
  1. activation key-sequence
  1. input text
  1. cursor/selection when NormalizeLinkSyntax is activated
  1. output text followed by an optional comment **## formatted like this**

In other words, if one positions the cursor in the first column of the input
(2nd line) and types the key-sequence (1st line), the NormalizeLinkSyntax
command will be activated with the cursor/selection as indicated by the `^`
characters (3rd line) producing the output in the (4th line), modulo comments.

These examples assume default settings for the wiki.

### Normal Mode ###

#### 1. Wikilink Without Description ####

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
+
[[http://github.com]]
^
[[http://github.com][github]]
```

```
w+
[[http://github.com]]
  ^
[[http://github.com][github]]
```

#### 2. Wikilink with Descriptions ####

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

#### 3. Weblink Without Description ####

```
+
[http://github.com]
^
[http://github.com] ## TODO: RM trailing space requirement
```

```
+
[http://github.com ]
^
[http://github.com github]
```

```
w+
[http://github.com ]
 ^
[http://github.com github]
```

#### 4. Weblink With Description ####

```
+
[http://github.com github]
^
[http://github.com github]
```

```
w+
[http://github.com github]
 ^
[http://github.com github]
```

```
wwwwww+
[http://github.com github]
                   ^
[http://github.com github]
```

#### 5. Raw Text ####

```
+
Page2
^
[[Page2]]
```

```
+
this is the index
^
[[this]] is the index
```

#### 6. Raw URL ####

```
+
http://github.com
^
[http://github.com github]
```

```
ww+
http://github.com
       ^
[http://github.com github]
```

#### 7. Enclosed vs. Enclosing Link Contexts ####

```
/[<CR>+
[http://github.com [[github]]]
                   ^
[http://github.com [[github][github]]] ## DOES NORMALIZE b/c Wikilink has higher precedence than enclosing Weblink
```

```
/[<CR>n+
[[http://github.com [http://github.com ] ]]
                    ^
[[http://github.com [http://github.com ] ]] ## DOES NOT NORMALIZE b/c enclosed Weblink has lower precedence than enclosing Wikilink
```


### Visual Mode ###

#### 1. Wikilink Without Description ####

```
v$+
Page2
^^^^^^
[[Page2]]
```

```
v$+
[[Page2]] 
^^^^^^^^^^^
[[Page2][Page2]]
```

```
wviw+
[[Page2]]
  ^^^^^
[[Page2]] ## DOES NOT NORMALIZE b/c link context (Wiki Link) has higher precedence than selected text (Word)
```

#### 2. Wikilink with Descriptions ####

```
wviw+
[[PageTwo][The second page]]
  ^^^^^^^
[[PageTwo][The second page]]
```

```
wviw+
[[Page2][The 2nd page]]
  ^^^^^
[[Page2][The 2nd page]]
```

```
wwwvt]+
[[PageTwo][The second page]]
           ^^^^^^^^^^^^^^^
[[PageTwo][The second page]]
```

```
wwwwv$+
[[PageTwo][The second page]]
               ^^^^^^^^^^^^^^
[[PageTwo][The second page]]
```

#### 3. Weblink Without Description ####

```
v$+
[http://github.com ]
^^^^^^^^^^^^^^^^^^^^^
[http://github.com github]
```

```
wvwwwwll+
[http://github.com ]
 ^^^^^^^^^^^^^^^^^
[http://github.com ] ## DOES NOT NORMALIZE b/c link context (Web Link) has higher precedence than selected text (Raw URL)
```

#### 4. Weblink With Description ####

```
v$+
[http://github.com github]
^^^^^^^^^^^^^^^^^^^^^^^^^^^
[http://github.com github]
```

```
wvwwwwll+
[http://github.com github]
 ^^^^^^^^^^^^^^^^^
[http://github.com github]
```

#### 5. Raw Text ####

```
v$+
Page2
^^^^^^
[[Page2]]
```

```
llv$+
Page2
  ^^^^
Pa[[ge2]]
```

```
vwl+
this is the index
^^^^^^^
[[this is]] the index
```

```
v$+
this is the index
^^^^^^^^^^^^^^^^^^
[[this is the index]]
```

```
V+
this is the index
^^^^^^^^^^^^^^^^^^
this is the index ## DOES NOT WORK for line-wise selections
```

```
v$+
[[this is]] the index
^^^^^^^^^^^^^^^^^^^^^^
[[this is][this is]] ## TODO: visual_selection should be adjusted to size of the link detected at the cursor
```

```
v$+
[[this is][this is]] the index
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
[[this is][this is]] ## TODO: visual_selection should be adjusted to size of the link detected at the cursor
```

```
%lv$+
[[this is][this is]] the index
                    ^^^^^^^^^^^
[[this is][this is]] [[ the index]]
```

```
wvwl+
[[this is][this is]] the index
  ^^^^^^^
[[this is][this is]] the index ## DOES NOT NORMALIZE b/c link context (Wiki Link) has higher precedence than selected text (Word)
```


#### 6. Raw URL ####

```
v$+
http://github.com
^^^^^^^^^^^^^^^^^^
[http://github.com github]
```

```
v$+
[[http://github.com]]
^^^^^^^^^^^^^^^^^^^^^^
[[http://github.com][github]]
```

```
wwv$+
http://github.com
       ^^^^^^^^^^^
http://github.com ## DOES NOT NORMALIZE b/c link context (Raw URL) has higher precedence than selected text (Word)
```

```
wvi]+
[[http://github.com]]
  ^^^^^^^^^^^^^^^^^
[[http://github.com]] ## DOES NOT NORMALIZE b/c link context (Wikilink) has higher precedence than selected text (Raw URL)
```


#### 7. Enclosed vs. Enclosing Link Contexts ####

```
%hv%+
[http://github.com [[github]]]
                   ^^^^^^^^^^
[http://github.com [[github][github]]] ## DOES NORMALIZE b/c link context is [[github]] according to precedence ordering
```

```
%hv%h+
[http://github.com [[github]]]
                  ^^^^^^^^^^^
[http://github.com[[][]]] ## TODO !?
```

```
%hhh+
[[http://github.com [http://github.com ] ]]
                                       ^
[[http://github.com [http://github.com ] ]] ## DOES NOT NORMALIZE b/c link context (Wiki Link) has higher precedence than enclosed link (Weblink)
```



