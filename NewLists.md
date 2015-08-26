# Introduction #

**Lists** allow one to groups together a collection of items, and are universally regarded as one of the most basic and useful means of structuring a document.
In the formatted output, it is easy to visually locate the items' markers, with the items' content indented: this formatting makes **nesting** of lists visible.

It is rather important for a wiki to support simple creation of lists, without imposing unnecessarily limiting constrains on the use of lists.
The three most common kinds of lists (with the HTML/LaTeX terminology):
  * _unordered/itemized_ lists
  * _ordered/enumerated_ lists
  * _definition/description_ lists
Towards the end, the _blockquote/quotation_ environments are discussed too. Although they are not normally used for collections of items,
their presentation in a formatted text is similar (indenting), and their nesting is also sometimes useful (think of e-mail or conversation threads).

Finally, some questions are raised about the use of lists for task tracking. No solutions for this part, though.



## Goals for List Design ##
Some more specific goals, going along the outline of WikiGeneralities.
  1. **Easy to create**: do not require explicit opening/closing of a list or explicit closing of an item
  1. **Allow "hard" line breaks**: a list item can be split over several input lines
  1. **Allow block environments**: block code, tables etc. can occur inside list items
  1. **No unreasonable limitations**: ending of sublist should not force the containing item to end etc.
  1. **Support description lists**: if possible, with syntax and behaviour resembling other lists

**Ad 1:** This is something common to most wikis and other structured plain-text systems, so it could as well be under a "compatibility" banner.

**Ad 2:** Many people are less efficient when editing text with very long lines. Also, the input text file can be made to look "nice" (resembling a formatted list) if line breaks can be employed. This goal is certainly going to be regarded as unessential, and rightly so. However, the next two goals pretty much imply that the ability to use multi-line items is a must anyway.

**Ad 3-4:** It seems to be rather common among simpler wikis that what is really supported are "shopping lists", not "document-structure lists" whose items can contain (aside from other "sublists") possibly several paragraphs, block environments etc.; even in complex wikis, it appears that one would be often required to switch to "HTML" mode to get such non-trivial lists.
Some people claim that if items are "complex", they should be recast as subsub\*sections instead of items in a list. But I do not agree: one should have a choice.

**Ad 5:** Very simple wiki systems sometimes do not even attempt to support description lists.
Some people argue such list could/should be recast as other lists, subsub\*sections, tables etc. instead of description lists. For many others, however, description lists are extremely useful for grouping items which naturally have a shorter name or headword associated with them; these lists are definitely more appropriate and better looking than tables. Some feature-full systems (such as reStructured Text) even have several specialized versions of such an environment --- for lists of program options, for instance.

# Lists #
## Nesting by Indentation ##
A wiki list example which uses _indentation_ to indicate the **nesting level**:
```
 * The first item starts here, implicitly starting an unordered list (Goal 1)
   and it's text continues on a new line (Goal 2)
   # This sublist is an enumeration
     and this is part of its first item
   # The second item has some code (Goal 3):
     {{ {
     printf("Hello world!\n");
     return 0;
     }} }
     which I would certainly like to be able to comment on (Goal 4).
   This line is still a part of the first item of the top-level list (Goal 4)
 * Item 2 also contains a shopping list:
   * milk
   * eggs
   and maybe more things, if I could only remember ...
This line terminates all lists: it is not indented enough to fall under any of the open items 
(there was really only one such item: the one talking about the shopping list, and ending with "...").
```

The example above is not at all complex, but from looking at various wiki syntax help pages or introductions, one rarely gets a sense of whether an equivalent of such a list can be created at all (even if we just needed the Item 2 --- despite its extreme simplicity, it would pose a serious challenge to many wikis).
(Note: The block code markers `{{{` and `}}}` are not supposed to have a space inside, but the wiki you are reading would damage the indentation if they were shown correctly.)

The description lists haven't been included here in order to convey the most important goals in a simple manner. They are discussed in a separate section further below.

## Nesting Using Marker Paths ##
Among wikis, one other nesting method is popular: indicating the nesting level by a sequence of item markers:
```
 * First Item (at the top level)
 * # Enumerated sublist Item 1 (belongs under the First Item)
 * # Enumerated sublist Item 2
 * Second Item (at the top level)
```
This method is very logical: each item indicates how is nested and in what (well, in some wikis, the latter information cannot be inferred, as it is allowed to start the second line with `# # ` with the same intended list nesting). Except that in practice, one has to deal with sequences of items that do not seem logical (for instance, `* * *` followed by `# # #`), so in reality one still has many decisions to take when attempting to specify this syntax.

What about the continuation lines? In cases they are allowed, they would often automatically belong to the last opened item. If there is no provision to overrule this default, the lists cannot satisfy the fourth goal (and there are likely going to be some difficulties with the third one as well). There are at least two ways to overcome this restriction: have an explicit way of closing a (sub)list (for instance, using an empty line), or use a _continuation character_, for instance `+`, as in
```
 * Item 2 also contains a shopping list:
 * * milk
 * * eggs
 + and maybe more things, if I could only remember ...
```
which would be interpreted in the same way as the second item of the first example on this page.

## Implementation in Vimwiki ##
Vimwiki uses the indentation syntax.
The syntax facilities in Vim do not make it possible to properly define full syntax for such indentation-based structures, unless the allowed indentation is fixed (for instance, level 1 list must have a marker in column 2, level 2 list in column 4 etc.). Such a strict scheme would probably not be regarded as extra easy to use, and compatibility with the previous implementations would be rather low.

Therefore, a nontrivial amount of state-tracking must be done for list processing by output generators (unlike for most of the other environments, where all this tracking can be done by Vim internally via its syntax facilities). Because Vim does not track the nesting depth, some things are not really possible (for instance, highlighting distinct levels differently).

### Indentation and Nesting in Detail ###
All this extra coding has its benefits, though. One can use larger amounts of indentation at each step, according to one's own preference --- the indentation requirements are very permissive a flexible.

Both `*` and `-` can be used for an itemized (bulleted) list, but they cannot be mixed at the same level of the same list --- there is no reason to promote inconsistency:
```
* List A
- List B
- List C
```
here two top-level lists are created, the first one has just one item.

Most choices in the following were made for the maximum compatibility with the older versions of Vimwiki. If you indent nicely, as in the first example on this page, you do not really need to know any of the following details. The examples that follow are here to exhibit the behaviour in corner cases, they are all indented quite poorly!

The minimum significant indentation step is one space, so it is possible to make a three-level list as follows:
```
* Level 1
 * Level 2
  * Level 3
* Level 1 item 2
```

Next example is to clarify how the indentation levels work in case the input is rather inconsistent: an item belongs to the deepest opened sublist whose indentation does not exceed that of the new item (if there is no such open list, a new list is opened).
```
  * Item 1
        * Sub-Item 1
      * Item 2
    * Item 3
  * Item 4
* New List, Item 1
```

For multiline items: a continuation line belongs to the deepest opened list whose (first) marker is indented less than the new item (in the example above: the position of `*` of Item 1 is significant, not that of Item 2 or 3).
```
 * Item 1
   continues here (preferable)
 * Item 2
  continues here (not as nice, but possible)
   * Sub-Item 1
    subitem continues here (not as nice, but possible)
   but this line is indented too little, so it belongs to Item 2
 * Item 3
 the list gets terminated here, this line is not part of Item 3!
```

Again: there is really no need to know any of this. Just indent your lists "nicely", preferably with a step of at least two spaces, and it should get interpreted the way you mean it.

### Interaction with Headings ###
Headings that are indented enough to be a part of a list are going to be swallowed by the relevant list item, and not considered a section heading.
```
 * list stars here
   == not a real heading ==
 * list continues
 == A Real Heading (not part of the list) ==
```

### Interaction with Block Environments ###
Some of the most used multi-line environments, aside from lists, are the block code and tables. They can be complex or very sensitive environments, it is not a good idea to require some changes inside just because we want to nest such an environment inside something else. Therefore, in lists, where the indentation determines the nesting level, only the indentation of the opening marker (of the code block or table) is important: the rest is better to leave unindented. More precisely, it is more convenient, visually it breaks the list somewhat, of course.
Therefore the part of the first example would actually be
```
   # The second item has some code (Goal 3):
     {{ {
  printf("Hello world!\n");
  return 0;
     }} }
     which I would certainly like to be able to comment on (Goal 4).
```
in case the two lines of the code listing start at column 3: the list will not break because of this, and it is up to you whether the closing marker is aligned or not. (Again, the block code markers had to be broken up so that the spacing is preserved in this example).

The markers for such multiline environments (block code, tables) **have to be on a line of their own**, they cannot be put on the same line as the list marker: ` * {{{` will not start a code listing inside a list.

### Key Maps ###
At least two maps are going to make it easier to create lists:
  * (close current item, and) create a new item at the same level
  * create a new line for the current item
Both of these would naturally fit well with some kind of _Modifier+Enter_ or _Enter_ map. At present, the Enter key does half of the first function
(works that way only if on the first line of an item).

Other mapping could be useful too:
  * "increase indent" (move to a sublist)
  * "decrease indent" (move to the parent list)
Both are much easier to implement for newly opened items. In that case, the _Enter_ key could perhaps even be overloaded,
as suggested in http://code.google.com/p/vimwiki/issues/detail?id=169.
<pre></pre>

# Description Lists #
These lists allow to use a short phrase (we will call it the definition _term_) which, in the formatted output, will be displayed instead of a list marker, and a possibly longer _description_ that will provide the main content of the list item. In LaTeX, this pairing between terms and their descriptions is more or less enforced. HTML, on the other hand, allows any sequence of terms and description parts to occur as components of a definition list. What is common is that terms are "inline" only, while the descriptions are possibly block environments.

The principle use of these lists is for glossaries, list of terms, hierarchies or outlines (see [Arabic loanwords](http://en.wikipedia.org/wiki/List_of_English_words_of_Arabic_origin) or [Pinball Glossary](http://en.wikipedia.org/wiki/Glossary_of_pinball_terms) or [Wikipedia outlines](http://en.wikipedia.org/wiki/Portal:Contents/Outlines) for some Wikipedia examples).
They are often (mis)used too as a simple alignment tool: using only the description parts, one can achieve the effects of indentation and slight increase of interline space.

## A Popular Syntax for Description Lists ##
The most popular syntax among wikis seems to be the one using `;` and `:` as markers. An example from MediaWiki:
```
;item 1
: definition 1
;item 2
: definition 2-1
: definition 2-2
```
Sometimes a short notation is supported too:
```
;item 1 : definition 1
```
which however brings some problems: it may very well be that `:` needs to be used as a part of the term. Less obvious, but much more difficult is the problem of detecting quickly that this short notation is being used: in case a markup is used in the term part, it may not be quite obvious whether the second marker (the colon) follows or not.

## Implementation of Description Lists in Vimwiki ##
The following uses markers `: ` for the term, and `:: ` for the description. This is not at all common, but is rather compatible with the syntax that Vimwiki 1.1.1 uses, and also reduces greatly the need for escaping when `:` is a part of the term.

An example showing two (or three) ways of using a wiki syntax to create a definition list:
```
: Term 0 :: some definitions are really short
: Term 1 :: definition of term one, this time it
  can turn out to be rather long, of course
: Term 2
  :: The definition is on its own line, some people may prefer that,
     of course it may get longer too ...
  :: Another definition is on its own line
     it may get longer too ...
: Term 3 is exactly the same as Term 2
:: The definition is on its own line, some people may prefer that,
   of course it may get longer too ...
:: Another definition is on its own line
   it may get longer too ...
```
All this is allowed so as to be rather flexible when it comes to whitespace and "compatible" with Vimwiki 1.1.1 (just the initial "term" marker needs to be added). Again, full nesting with other environments works (keep in mind that the "term" is inline: only the description part can contain complex structures). Note that the description markers may be indented somewhat (compared to the term markers --- see the Term 2) without starting a "deeper" sublist. (Indenting more that what is shown in Term 2 would already cause a new sublist to be started, however.)

In particular, allowing the "short" syntax (as in the first two lines of the example above) is a _big compromise_ in the name of compatibility and convenience: as mentioned earlier, due to the possible inline markup of the term, it is rather difficult in general to detect that the short syntax is employed. Ideally, all potentially multiline environments should be detectable just by looking at th beginning of a line, which is not the case here!

The "long" syntax relates to a hidden problem too: what if a continuation line follows the definition term? If the indentation suggests the continuation line belongs to the description, there is a problem: the term is not supposed to be on several lines. And if you think this is not a real problem, that consider the case the term is followed by a start of another list environment: this simply cannot belong to the term, which is inline only. In this situation, instead of abruptly terminating the list at this point, an error notification will be issued and the output generator will proceed as if the description marker preceded the offending line.

Descriptions simply are more complicated than other kinds of lists. But their usefulness is worth the trouble of supporting them.

# Quotations #
These environments are known as "blockquote" in HTML. The syntax employed by wikis is often pure indentation (this, of course, does not play out well if the indentation is also used for anything else that may be nestable with quotations), or sometimes prepending a `> ` marks to every input line as seen in many e-mail programs. That is more work than necessary. For a reasonable compatibility with Vimwiki 1.1.1 (where four spaces --- in some situations --- mark the quotation environment), it is enough to use a style similar to lists, but with a `>` marker instead:
```
> quoted at the first level
  still at the first level
  > quoted at the second level
    still at the second level
  now continuing at the first level
and this line is already outside of the quotation
```
This implementation means that the nesting machinery for lists will work as well for any combination of lists or quotations. It is rather unlikely that full nesting ability could be done with the indentation-only syntax.

Some systems support also quotation environments with en extra _attribution_ parameter (which indicates the author or the source of the quoted text). Again, this is commonly seen in e-mails. If we were to support this, that is, the quotation may possibly have an "inline" attribution and a "block" of quoted text, we would (on a syntactic level) need precisely what we are using for the description environment. But neither the HTML nor standard LaTeX classes provide a default way of handling such attributions, so we will leave it at that: no syntax for attributions. It is more important for a wiki to a have a way of citing/referencing (even traditional media, not just URL's), but this should be a separate topic at NewLabels.

# Task/Todo Lists #
Vimwiki supports task lists to some extent (basically, a "completion level" mark). This area is also a frequent target of feature requests, as there are specialized tools with much more complete support (well known [orgmode](http://orgmode.org/worg/org-tutorials/index.html) is just one example, more links at http://www.abstractspoon.com/tdl_resources.html). There are also some Vim projects going in that direction:
  * VimOrganizer http://www.vim.org/scripts/script.php?script_id=3342
  * vimtl http://www.vim.org/scripts/script.php?script_id=3089
  * vikitasks http://www.vim.org/scripts/script.php?script_id=2894
  * vorg http://www.vim.org/scripts/script.php?script_id=2842
  * TaskList http://www.vim.org/scripts/script.php?script_id=2607
  * WOIM http://www.vim.org/scripts/script.php?script_id=2518
  * taskpaper http://www.vim.org/scripts/script.php?script_id=2027
  * gtd http://www.vim.org/scripts/script.php?script_id=1566
Some serious thought would have to be put into this topic to determine what is desirable and what is feasible, so as to avoid a situation
where a lot of little features get implemented that cannot be connected to a reasonably complete and effective system.
The following is certainly not a proposal for such a system, only a list of a few starting points.

## Completion Level ##
To make it syntactically easily detectable and not influencing other things, it has to be restricted to the position right after the item marker.
The input used in Vimwiki is `[ ],[.],[o],[O],[X]`, but how to make an output (say, in HTML) that would look nice and display properly for most people?
  1. Using some characters from [Unicode Block Elements](http://www.fileformat.info/info/unicode/block/block_elements/list.htm) U+2580-259F: ▁, ▖, ▄, ▚, ▙, █, ░, ▒, ▓, █ ?
  1. Using some characters from the [Unicode Geometric Shapes Block](http://www.fileformat.info/info/unicode/block/geometric_shapes/list.htm) U+25A0-25FF: ◔, ◒, ◕ ?
  1. Embed a simple shape with [SVG](http://en.wikipedia.org/wiki/Svg)?
None of these would work for everyone... If you see just spaces or empty rectagles between commas in the first two points above, your browser
does not find any fonts for displaying those characters, and there are likely more people with the same problem.

## Dates and Times ##
Only one input format is sensible, _2011-01-10 15:00_ (local oddities such as _Year 32 of Queen Qwerty's rule_ or _01/10/2011 3pm_ perhaps for output only, if configuration could be made easy). For humans, indicating a day in a week is useful, but this would be hard to do in a language independent way. More configuration is needed?

  1. Time zone is sometimes useful, but is it really necessary?
  1. How many types of dates are needed? Simple event dates and intervals, and also deadlines, distinguished syntactically or with a special tag? Or just something simple, like an `!` in front of a date to indicate a deadline?
  1. Is there a need (and suitable syntax) for periodic/recurring dates? Again, language independence is a problem here...

## Tags Specific to Tasks? ##
  1. Is it worth having a few special keywords just to support some functions?
  1. Or should there be a general syntax for tags, usable outside lists?
  1. Tags hierarchical or parametric? The problem is going to be with their processing (assuming they are spread over many files): no database back-end can be assumed in general, and Vimscript is not fast. A well thought-out use of automatically generated areas in wiki files and of auxilliary files would work, on a moderate scale.
  1. Tags only in a restricted position to speed up their collection?
  1. What functions should really be supported for dealing with tasks and "todo" lists?


---
