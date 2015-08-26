# Syntax #
see `:h vimwiki-syntax`

| **SYNTAX**              | **RESULT**                  |
|:------------------------|:----------------------------|
|`*bold*`                 | **bold**                    |
|`_italic_`               |_italic_                     |
|`~~strikeout text~~`     |~~strikeout text~~           |
|`hello^super script^`    |hello<sup>super script</sup>        |
|`hello,,sub script,,`    |hello<sub>sub script</sub>        |
|`WikiWord`               |link to `WikiWord`           |
|`[[complex wiki word]]`  |link to `complex wiki word`  |
|External link with description `[http://habamax.ru/blog habamax home page]`|[habamax home page](http://habamax.ru/blog)|
|`http://habamax.ru/blog/wp-content/uploads/2008/07/dsc01075-300x199.jpg`|![http://habamax.ru/blog/wp-content/uploads/2008/07/dsc01075-300x199.jpg](http://habamax.ru/blog/wp-content/uploads/2008/07/dsc01075-300x199.jpg)|
|Linked thumbnail `[http://habamax.ru/blog/wp-content/uploads/2008/07/dsc01075.jpg http://habamax.ru/blog/wp-content/uploads/2008/07/dsc01075-300x199.jpg]`|![![](http://habamax.ru/blog/wp-content/uploads/2008/07/dsc01075-300x199.jpg)](http://habamax.ru/blog/wp-content/uploads/2008/07/dsc01075.jpg)|

## Lists ##
```
Unordered lists use '* ' or '- ':
* unordered list item 1
    - unordered list item 2
    - unordered list item 3
    * unordered list item 4
        * unordered list item 5
* unordered list item 6

Ordered lists use '# ':
# ordered list item 1
    # ordered list item 2
    # ordered list item 3
# ordered list item 4

Definition lists:
Term:: Definition
Term::
:: Definition
:: Definition
:: Definition
```

## Headers ##
```
= Header1 =
== Header2 ==
=== Header3 ===
==== Header4 ====
===== Header5 =====
====== Header6 ======
```

## Pre ##
One or more spaces before your text and it becomes preformatted.

Or use triple { at the beginnig of the line to begin preformatted text and triple } to end it.

`{{{`
```
Tyger! Tyger! burning bright
 In the forests of the night,
  What immortal hand or eye
   Could frame thy fearful symmetry?
In what distant deeps or skies
 Burnt the fire of thine eyes?
  On what wings dare he aspire?
   What the hand dare sieze the fire?
```
`}}}`