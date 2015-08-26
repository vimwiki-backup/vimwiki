# Introduction #

One of the problems with using plain text to represent structure is the following: the structure is expressed using some markup characters or character sequences, which can get in the way of using those same sequences to represent themselves (or something else than the markup). If there are no means of _escaping_ the special meaning of the structure-imposing sequences, those sequences are effectively unusable in their literal meaning.



# Code/Literal Environments and Escapes #
In programming languages, the text structure is highly constrained (and a large portion of it is a markup, in a way), and the problem of escapes is limited to a few special areas (for instance, those parts representing the values of string constants).

In a wiki, on the other hand,
most of the text is the content, not the markup (one would hope).
Availability of many _tags_ (the sequences representing the markup) makes it possible to express a complex structure, but it has a drawback:
it could be very frustrating to try to use a plain (unmarked) text that contains some of the tags.
Therefore it is rather important to deal with the problem of escapes when designing a markup. One should have a way of _escaping_ tags.

## Code or Literal Text ##
_Literal_ (or verbatim, or code environments) should offer a solution to a variation of such an "escape" problem: how to type a string or longer piece of text _without wiki software "looking inside"_ the text and attempting to interpret some parts as being tags.
This is of great use to anyone who often needs to quote pieces of software documentation or program code --- tags are often chosen to be made of characters rather uncommon in a typical prose, but exactly such characters tend to be very common in at least some programming languages, so the chances of "conflicts" are going to be much higher than for prose.

### Inline Code ###
Frequently used for quoting single characters, variables, paths, file names, expressions and other strings intended for machine processing. The tag should be short. Vimwiki chooses the character
`````
as both opening and closing tag.

**Problem 1:** How to represent the "back-tick"
`````
when it is needed _inside_ this environment (as part of the quoted text)?

**Common possibilities:**
  1. **Double** every occurrence of a back-tick inside. Example:
> > ````#``$````
> > > will simply quote the three-character string

> > ``#`$``
  1. Prepend a fixed **escape character**, for instance `\`, so that
> > ```#\`$```
> > will mean the same three-character string as above.
The first choice (doubling) is good:
doubling is quite commonly used with "tags" such as `"` or `'`,
so this is not really going against "the tradition".
But one has to deal with all sort of other escape problems outside this particular code environment, and
some kind of escape character is going to be needed anyway. It would seem _more consistent_ (with the solution to other escape issues) to use an escape character, but there is an unpleasant problem: the case of the escape character as the last character of the code sequence. This cannot be resolved very elegantly, without requiring the escape character to be escaped as well...

When an escape char is used, many people expect that the escape character `\` itself has to be escaped, but this would potentially mean a lot of extra escapes in the quoted strings
(to the point of illegibility in cases where the quoted string is, for instance, a typical regular expression, since here the `\` occurs quite often).
We can say `\` _does not_ need to be escaped, unless it is just before an escaped backtick or at the end of the code string, and it could perhaps make a functioning code environment, but only using some rather heavy rule on how to modify those escape characters. Besides, more people are used to always escaping the escape, and anything more complicated is not going to be easy to remember...

It seems that doubling is going to be much better choice (easier to remember), even though most of the other escape problems are going to be dealt with using an escape character.

### Block Code ###
Used for quoting program segments or other text that is possibly several lines long. Often, one not only wants no interpretation of tags inside, but also faithful reproduction of characters such a spaces and newlines.
Vimwiki chose/inherited `{{{` as the opening tag, `}}}` as the closing tag.

First, to maintain sanity of the whole design, just like the other tags used for multiline environments, these tags have to **stand alone on a line** (or at the very least occupy the space of the first non-whitespace characters on a line).

**Problem 2:** How to quote code segments that contain some lines matching the closing tag `}}}`?


> I am having this problem as I write this: how do I give examples of a block code the way it is typed inside the wiki?
The documentation to Google Code wiki does not hint at any escape mechanism... is it correct to assume there is no such mechanism? Will I have to use `}.}}` here instead of `}}}`? It turns out I can show this
```
{{{
some code ...
}}}
```
by enclosing what you see in another pair of the start/end tags for the block code, like this:
```
{{{
{{{
some code ...
}}}
}}}
```
but if my quoted code inside contained just one of the tags from the pair (instead of several balanced pairs), things would go very wrong...

Common solutions to the problem that do not rely on any "balancing": one needs to either modify the "offending" lines in some way (and the modification is automatically "undone" by the software during the conversion to an output format), or have an (infinite) class of markers that can be used and then pick any one that does not occur in the specific instance of the quoted code.

**Some possibilities:**
  1. **Insert** a fixed character at the start of each "offending" line (to make this fully functional, you have to treat _all lines potentially arising from this process_ as offending too, not just the lines containing only the end tag.)
> > Seems to be used (or at least recommended) by [WikiCreole](http://www.wikicreole.org/wiki/AddNoWikiEscapeProposal).
  1. A variation of a **here-string** solution used in some shells or scripting languages: pick a string of your choice (something not matching the quoted code), say `abrakadabra`, and use
```
  {{{<<abrakadabra
  quoted code ...
  }}}abrakadabra
```
> > At least one wiki uses a similar scheme, but requiring the closing marker in the form `abrakadabra}}}`. Visually, this just looks very poor to me; requiring the mirror image of the string would be even worse!
  1. **Matching length** markers of the "same kind":
```
  {{{{{
  quoted code ...
  }}}}}
```
  1. **Matching whitespace** before both opening and closing markers: while this makes an infinite class of markers, it would create difficulties if the code environment needs to be used in any place where the leading whitespace is important: this is actually the case of many wikis...
> > Could also present a difficulty to people who like the freedom of using initial white space as they like.
  1. A special case of the here-string method, where the string has to be a sequence (possibly empty) of `-` (hyphens/minus signs):
```
  {{{-----
  quoted code ...
  }}}-----
```

The last one I consider to be the best solution: unlike the "insert" method, requires no modification to the quoted code (so the code can be pasted in/copied out easily),
and it looks really pleasing --- some would perhaps use it even if escaping is not necessary, just for the visual separation it provides.
It is also easier for the processing software than the matched length method (with different chars at start and at end).

In reality, it is useful to be able to pass some options to the "code block" environment (for instance, the programming language of the code), so the actual syntax of a code block would be
```
{{{-----%options
  quoted code
}}}-----
```
This choice also leaves the possibility of allowing any whitespace before the markers --- an important aspect because some environments (often lists or block quotes) in wikis are to some extent defined using a leading whitespace. See NewLists.

Remark: Sadly, it does not seem really possible to have Vim highlight the options differently than the preceding marker, as there is neither a way to restrict a match only to _the start of the containing region_ nor a way to match things inside `matchgroup` items. There is a workaround method, but that one will not allow a simple use of a nested syntax for the quoted code.

One final note: It is conceivable some people may frequently need to quote just one line of code. In that case requiring the opening and the closing tags on separate lines seems somewhat wasteful.

**Problem 3:** Should there be a special version of the block-code environment that starts and ends on the same line, provided the start tag is only preceded by a whitespace and the end tag is immediately followed by the end-of-line?

Similar variation would be useful also for displayed math.
(Further relaxation of the positions where literal environments are allowed to start/end is not a good idea, to put is very mildly. See the last section of [WikiGeneralities#Some\_Examples](WikiGeneralities#Some_Examples.md).)

### Literal Text (not code) ###
Some wikis or document systems may have also environment functioning similarly to the "code" environment
(in that all "whitespace" is preserved, and nothing inside is considered as markup),
but after a conversion or export, the quoted text is not presented in a monospaced typeface (which is invariably what happens with the "code" environments).

**Problem 4:** Is it really needed to have a special environment for literal text, with its own tags, or should there be at least some option available for the code environment that selects a different style (one that implies a non-monospaced font for the output)?

## Inline or Display Mathematics ##
From the point of view of the wiki, this is handled almost identically to the code environments: wiki itself does no processing inside.
Semantically, however, this is very different from quoting a "code" or a "text", and it is very easy to imagine someone wanting to use both code and math environments at the same time --- both are very common in technical texts.

It is certainly best to have _dedicated tags for math_ (despite the unfortunate fact that basic HTML has no equivalent). Most serious wikis seem to support at least one such environment, even though it was sometimes not a part of the original design.
This topic is on its own page at NewMath.


## Escaping Individual Tags ##
_Escaping_ the character (or sequence) means arranging to have the character taken as is, without its special wiki meaning.

**Problem 5:** How to write a text that contains characters or sequences of characters that are normally interpreted as a _tag_ that has a certain function in wiki?

For instance, a `*` under some conditions starts a bold text, in other circumstances starts a list item. People wanting to write about a `*pointer` may have a proper environment (namely the inline code) to "hide" the `*` from being interpreted, but it does not mean that there aren't other people with other uses of `*` in mind, for some of which the code or math environments are not even close semantically.

**Some possibilities:**
  1. Doubling is not a very common choice in cases several tags need to be escaped, and quite awkward in cases where tags consist of more than one character.
  1. A special tag (or tag pair) is introduced, say `<nowiki>...</nowiki>`. This would be fine for a block environment, but is quite intrusive and a huge waste of space if you only need to escape a character or two...
  1. An **escape character** is used, say `\`, which itself becomes "special" and needs to be escaped too: so `\*` is treated as a literal, non-special `*`, but in order to obtain a literal `\` one has to write `\\`. That is quite common in many popular programming languages, as already mentioned above. But it can get rather annoying if you need `\` more than once in a while (as an example, on some systems this character is used to separate levels in a file path).
  1. An **escape character** is used, but its use is required **only in the context where a special meaning** could normally be triggered.
    * the code or math environments do not allow any wiki markup inside, so only the relevant end tag needs to be escaped inside them;
    * inline styles (such as text emphasis) are allowed in mosts contexts, so the relevant markers need to be escaped in most contexts;
    * multi-line (or block) environments can only be started/terminated at (or near) the beginning of a line, therefore the relevant sequences would only need to be escaped if they are at such a position.

The last mechanism seems the most suitable for a wiki: the use of escape characters is much reduced compared to the method 3, and it also feels very "human" to many people, compared to the "machine" strictness of method 3. Therefore one may write `|` as `|` in most places, and have to escape it as `\|` only where the pipe symbol has a special meaning (for instance, inside table cells or inside some links).

The disadvantage of the method 4 compared to the method 3: the precise description of "escaping rules" is now more-or-less just as complicated as the "syntax rules" for the entire wiki, so in complex cases, it could be quite hard to figure out what is escaped and what is not.
Nevertheless, if _syntax highlighting_ clearly distinguishes which sequences are "escaped", this method is highly usable --- one does not have to think much about the precise rules and their consequences, the highlighting will simply indicate whether the sequence is consider a tag, an escaped tag, or "normal" text.

In practice, one may choose some sort of compromise or simplification (in order to simplify the implementation of the "escape rules"), so that there will perhaps be some sequences in some contexts that cannot be escaped.
But one should never be trapped in a situation where a certain common character simply cannot be escaped --- this can be very frustrating. The "unescapable" exceptions would ideally be just some rather unlikely sequences.

For the multiline code and similar environments, the preferred method might still be the alternative one outlined in the subsection [NewEscapes#Block\_Code](NewEscapes#Block_Code.md) for the reasons stated there: there should be no doubt that what is quoted is _exactly_ the quoted code (and not a code where something is possibly escaped).

**Problem 6:** Which character to choose as _the escape_ character?

In programming languages, `\` is definitely a popular choice. WikiCreole seems to recommend the [context-limited escape character](http://www.wikicreole.org/wiki/EscapeCharacterProposal) too, but the [choice fell on tilda](http://www.wikicreole.org/wiki/EscapeCharacterDecision) `~` as the escape character (the reasons for that decision are not very clear, though).

It is reasonable to assume that people exposed to programming would find the traditional `\` less strange (backslash as escape is used at least in [Markdown](http://daringfireball.net/projects/markdown/syntax#backslash) and in [reStructuredText](http://docutils.sourceforge.net/docs/ref/rst/restructuredtext.html), using the method 3 of "machine escape", and there is little doubt it is going to function similarly in some other systems too).
Besides, using `\` leaves the character `~` open for some other special uses: most notably as a non-breaking space (as in TeX).


---

Are there any examples of wikis or documentation systems that successfully tackled most of these problems?