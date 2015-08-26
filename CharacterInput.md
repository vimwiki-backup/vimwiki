Right now it does not say much about encoding setup: it should be expanded later to provide more detailed guidance.

# Introduction #

The problem: **How do I get a specific character into my file if that character does not appear on my keyboard?**

Sometimes, it may be just an occasional special character you do not normally use (say, in a "foreign" name). It is more painful if you need a character more often (for instance, the proper quote characters in you language). In the worst case, it could even be one of the characters used for wiki markup.

There is no simple answer: the problem depends on many (wildly variable) things: the character, the keyboard, the operating system setup and its localization...

There are usually several ways in which you can setup your Vim to allow you to insert "unusual" characters conveniently, but _only in the case that your operating system supports it_. (All modern systems support Unicode, at least in principle, but if you work in a terminal window, you may have problems.)

The problem involves roughly three different areas: encoding issues, the actual character input, and font support.



# Encodings #

A Unicode encoding is ideal, UTF-8 specifically is preferable. Choose something else only after a careful consideration. If you have your encoding set as UTF-8 ( `set encoding=utf-8` will do that,; if in your .vimrc, this encoding will be the default), you should be able to paste any character from any other window and it will get into your file (it has to be a character (sequence), not a picture or some other object). You may not see the glyph, though: this depends on which font is your Vim using. But in principle, the character is there.

Read more on the topic of encodings using `:he enc` and `:he fencs`, or look at http://vim.wikia.com/wiki/Working_with_Unicode.

**Method 0**: Copy/paste in GUI.

For a comprehensive list of glyphs, you can consult [WikiBook on Unicode Characters](http://en.wikibooks.org/wiki/Unicode/Character_reference/0000-0FFF), or just look at a [small sample of characters](http://en.wikibooks.org/wiki/Unicode/List_of_useful_symbols) first.

In other (non-unicode) encodings, you can only successfully do the same with the characters that the encoding supports (often, this is just a hundred characters in single-byte encodings).


# Character Input #

Assuming you prefer typing rather than pasting from some other window, vim has several ways that you could employ to get a character that your keyboard does not provide.

  * `:imap` _mappings_
> > Ideal for cases you need to insert something very often.
  * `:dig` _digraphs_
> > Good for both frequent and occasional uses, has a pre-defined support for several hundred characters already.
  * `:ia` _abbreviations_
> > More often used to insert longer sequences via a custom shorthand.
  * `keymap` (option) _mbyte-keymap_
> > For the brave ones looking for a more complete remapping of the keyboard.
  * `CTRL-V` direct codepoint entry _24.8_
> > This is only useful if you know the number of the character you need (in the encoding you use).
  * use a Vim script or plugin
> > Works only if someone with similar specific needs prepared some methods and made them available.

Use the Vim help command to get more information: for instance `:he digraphs` to read on digraphs or `:he 24.8` to read on direct codepoint entry.

You can put the commands that will help with your specific needs into your .vimrc file (if you do not mind that the mapping will work on other types than just .wiki).
If you do not feel like doing your own customization, explore the "digraph" method, that is the only one that may cover your needs out-of-the-box (or the more general codepoint numeric entry, which is however much harder to remember).

Unicode has over 100 000 codepoints for which there is no built-in setup in Vim or Vimwiki, which is quite understandable. Depending on your needs, you may need to do some customization once in a while...

## Mappings ##

Examples:
  * `:imap <F5> ¡`  will allow you to use the fifth function key to insert the inverted exclamation mark used in Spanish
  * `:imap \? ¿` will convert typed `\?` in insert mode into the inverted question mark
To have the first map always available, you would put in your .vimrc the line
```
imap <F5> ¡
```
For more help, see `:he mapping`.

Things to avoid: remapping keys that you may need for their original function, and attempting to remap keys that are intercepted by the operating system (Vim cannot overrule that).

## Digraphs ##

Examples:
  * `CTRL-K o:` inserts ö
  * `CTRL-K =e` inserts € (also `CTRL-K Eu` will do that)
  * `CTRL-K <<` and `CTRL-K >>` insert quotation marks « and » used in French
  * `CTRL-K Co` and `CTRL-K Rg` insert © and ®
  * `CTRL-K NS` inserts a non-breakable space
Type `:dig` to see a list of default digraphs. Do not expect your default font to show all the glyphs, though.

Frequent users may set it up so that instead of having to type `CTRL-K char1 char2`, the sequence `char1 <BS> char2` will do the job (`<BS>` represents the Backspace key) --- see `:he digraph`.

For many digraphs, the actual pair of characters used is to some extent predictable. Here is the significance of the second character (from `:he digraph-default`):
  * `! ' > ? - (`
> > accents: grave, acute, circumflex, tilde, macron, breve
  * `. : , _ /`
> > accents: dot, diaresis (umlaut), cedilla, underline, stroke
  * `" ; < 0 2 9`
> > accents:  double acute (Hungarian umlaut), ogonek, caron (háček), ring, hook, horn
  * `3`
> > various Latin/Greek/Cyrillic letters
  * `= * %`
> > Cyrillic and Greek
  * `+`
> > Arabic and Hebrew
  * `4`
> > Bopomofo (Chinese phonetic alphabet)
  * `5 6`
> > Hiragana and Katakana (Japanese syllabaries)

## Abbreviations ##

Simple example: `:ia VW Vimwiki` sets it up so that in insert mode, typing `VW ` expands to Vimwiki (after you type the space).

For more complex abbreviations (where the replacement string is not fixed, but calculated by a function), see `:he map-expression`.

## Keymap ##

As said above, this is an option to consider if you need an extensive set of mappings.
It maybe worth exploring if the operating system does not provide something you would be happy with.

  * Advantage: your setup via keymap may work on many different systems.

  * Disadvantage: only applies to Vim, not other applications.

Using the operating system's key-map facilities, it is going to be the opposite.

## Direct Codepoint Entry ##

You need to know the character's **codepoint** (= the number of the character in the used encoding) --- in decimal, octal or hexadecimal representation.
In insert mode, you press `CTRL-V` and then input the number. (On Windows, it is often the case that `CTRL-Q` has to be used, because `CTRL-V` is used to paste text for consistency with other applications.)
Examples (assuming a unicode encoding is used):
  * `CTRL-V 165` enters the Japanes Yen sign ¥, as its codepoint is 165 (in decimal, three digits should be used only)
  * `CTRL-V xb1` enters ±, whose hexadecimal codepoint is `b1` (two hexadecimal digits after `x`)
  * `CTRL-V u2211` enters ∑, the summation sign(four hexadecimal digits after u)
  * `CTRL-V U0001F609` enters the winking face emoticon 😉 (up to eight hexadecimal digits, needed only for Unicode characters beyond the Basic Multilingual Plane)

See `:he 24.8` (in recent versions of Vim, it is 24th chapter of the user documentation, section on _Entering special characters_) or `:he i_CTRL-V_digit`.
Look at the [List of Unicode Blocks](http://www.fileformat.info/info/unicode/block/index.htm) if you want to see how codepoints are organized.

In Vim's normal mode, to see the codepoint for the character under cursor, press `ga` and the status line will show the decimal, octal and hexadecimal values.


## Vim Scripts for Input ##

Just as with the keymap method: many people would first see if their operating system could provide some support (especially when the issue is just a specific language support).

For a heavy Unicode user, this script will allow you to search the official **Unicode character description** (a text database):
  * [unicode.vim](http://www.vim.org/scripts/script.php?script_id=2822) : A Completion function for Unicode glyphs

The next script, on the other hand, covers the entry of only a handful of basic, but frequently used characters (proper quotes, ellipsis, dashes):
  * [UniCycle](http://www.vim.org/scripts/script.php?script_id=1384) : Unicode character cycler

The following scripts will help you with **inputting Chinese** (note that you will still need to make sure that you have a suitable font to show you the result of your efforts):
  * [ywvim](http://www.vim.org/scripts/script.php?script_id=2662) : Another input method(IM) for VIM, supports all modes.
  * [VimIM](http://www.vim.org/scripts/script.php?script_id=2506) : Vim Input Method -- Vim 中文输入法

These scripts help with **inputting mathematical symbols** in Unicode (greek letters, arrows, operator symbols etc.):
  * [utf8-math](http://www.vim.org/scripts/script.php?script_id=2566) : Keyboard shortcuts for math UTF-8 symbols
  * [math](http://www.vim.org/scripts/script.php?script_id=2723) : Math keymap and a menu for inserting math symbols
Again, how many of these symbols are actually going to show up on your screen is a different matter entirely: you need suitable fonts for this convenience, not just the scripts.



&lt;BR&gt;




# Fonts #

This is a complicated issue in general: Vim can use only mono-spaced fonts (which usually comprise just a tiny fraction of available fonts on a modern system),
and pretty much only one font family at a time (unlike GUI programs, that may try to combine many fonts in order to display as many symbols as possible). If you need some very unusual characters, it may not be easy to find a Vim-usable font that has them.

A list of free monospaced fonts is at http://www.thefreecountry.com/programming/programmers-fonts.shtml
The following have a very wide coverage, including reasonably good technical and mathematical symbol coverage (not supporting East Asian characters, though):
  * FreeMono from GNU FreeFont collection (free)
  * DejaVu Sans Mono font (free)
  * Everson Mono font (shareware, not free)

You can use the script http://vim.wikia.com/wiki/Generate_all_Unicode_characters to help you see what glyphs are in your font within a given range.

---


If you have any suggestions, please leave a comment below. Information on suitable font sets is particularly needed: this is the one topic where Vim help is not telling you all you need.