# Contents #


# Introduction #

_Wikis_ vary greatly in many aspects, regardless of whether the word to refers to documents or the software that helps to create those documents.
  * **[Capabilities and scaleability](http://en.wikipedia.org/wiki/Comparison_of_wiki_software)**: going from massively collaborative projects, incorporating content managements systems (Wikipedia being the best known example) all the way down to wikis intended for personal note-taking.
  * **[Implementation](http://c2.com/cgi/wiki?WikiEngines)** or system environment used to run the software: from requiring nontrivial server setups to run the wiki engine and supporting databases, to simple scripts that process the input file and produce a formatted version of some sort (often an HTML file).
  * **[The "syntax rules"](http://www.wikimatrix.org/syntax.php)** used for marking-up the text (for those wikis or document systems which work with "plain text" documents) are just as varied, there is no such thing as _the wiki syntax_. As is to be expected, wikis with greater scope and capabilities often feature rather complex sets of rules. A tiny sample of four examples from dozens (or hundreds?) of possibilities follows, each with its own strengths that reflect slightly different design goals:
    * [MediaWiki](http://meta.wikimedia.org/wiki/Help:Wikitext_examples) (used by Wikipedia and related projects) does not have a reputation for extreme ease of use, but allows one to create a very large subset of HTML markup. Aside from the simplest constructs, however, this requires the use of templates, HTML tags and attributes to mark-up the source wiki. Heavily marked-up source text could be rather hard to read for someone not used to MediaWiki. The end results are excellent, of course, and visited daily by millions of people.
    * [ReStructured Text](http://docutils.sourceforge.net/docs/user/rst/quickref.html) (a documentation format very popular with the Python community) has many advanced features too. Unlike MediaWiki, it supports export to many formats, and looks extremely nice as a plain text. To achieve that, however, some of the markup is more visual that structural, so the files could take a significant effort to create or maintain after editing changes.
    * http://txt2tags.org/txt2tags uses a much simpler markup, but supports a great (and growing) number of output formats, including half a dozen of other "wiki" formats. Compared to many other wikis that allow to mark-up documents of similar complexity, txt2tags has mark-up rules that seem to have been chosen quite well: easy to remember, easy to process.
    * [Creole](http://www.wikicreole.org/) intentionally aims to be as simple as possible, and use only the most essential mark-up in a form that will look familiar to a lot of wiki users. The goal is to serve as a markup optionally recognized by many different wiki engines (that usually have their own syntax with more features), and that makes it attractive to people who need to migrate between different wiki systems.


Where **Vimwiki** stands is very clear: it is much closer to the personal note-taking end of the scale, is very easy to use and install (provided you are a Vim user with a recent version of Vim), with a rather simple syntax.

Some Vim scripts with goals or functionality similar or overlapping with [Vimwiki](http://www.vim.org/scripts/script.php?script_id=2226):
  * [Viki/Deplate : A personal wiki for Vim](http://www.vim.org/scripts/script.php?script_id=861) --- many more features, but needs a ruby tool for conversion of documents; actively developed.
  * [VST : Vim reStructured Text](http://www.vim.org/scripts/script.php?script_id=1334) --- pure Vim script, output to HTML or LaTeX format or S5 HTML presentation; seems stale.
  * [VimOrganizer : An Emacs' Org-mode clone for Vim](http://www.vim.org/scripts/script.php?script_id=3342) --- pure Vim script, more functions for task management than document creation; very early version.

## Vimwiki Syntax ##
The Vimwiki syntax is to a great extent compatible with [the syntax used for wikis on Google Code pages](http://code.google.com/p/support/wiki/WikiSyntax) (you are reading one such wiki right now), and that one, in turn, is based on a small subset of the rules used by the [MoinMoin](http://moinmo.in/HelpOnMoinWikiSyntax).
As such, it is currently ([Vimwiki 1.1.1](http://www.vim.org/scripts/script.php?script_id=2226) from September 2010) one of the fairly basic ones, not far from the minimalistic Creole in its expressiveness.

# Goals and Design Principles #
Given the uses Vimwiki is intended for, the following goals seem relevant,
stated roughly in the order of importance.

## Ease of Editing ##
Text must be easy and **quick to create** and modify. After all, "wiki" comes from the Hawaiian word for "fast". Editing convenience should be more important than what it looks like while in raw wiki form: one spends a lot of time working with the text when it is not yet in "finished form" (if ever).

It is more productive to spend time marking up the structure of the text, not its presentation. One would hope that from a properly structured text, a nicely formatted document can be generated (HTML or LaTeX -> PDF) when the text is "finished".

## Economy ##
**Screen space** is limited, it should be used well. Even if some have an extra large monitor, and run their wiki editor in an extra large window, it does not mean that everyone else does the same. Vim in particular is well known, among other things, for being be more or less fully functional on numerous platforms, even when editing in a simple terminal window.

Vim (from version 7.3) has a _conceal_ feature (which can be used to hide markers or parts of text on screen), but with the current implementation, the use of this feature leaves artifacts that are slightly unpleasant (in cases where lines wrap).

**Short markers** are preferable, at least for elements that may have quite short content and occur frequently.

Computer power is limited. Even if it were not, there is no reason to waste a lot of it just to figure out what could have been rather obvious had the mark-up been designed with some thought. While in principle a lot can be programmed in Vimscript, it can get slow if lots of lines need to be sifted through. Simple things should be **simple to process**, leaving plenty of resources that could perhaps be put to a good use when some more advanced features get implemented.


## Compatibility ##
Fundamental is the ability to **generate validating output** (for output formats like HTML that have a formal specification),
and allowing a reasonably **good conversion** to a wiki or document format that itself has converters to many other formats, so that people who created some content do not feel locked in and have a chance of moving their content to some wiki with greater capabilities (if or when they need to).

With so much variety in the world of wikis, there is little harm in creating something a little different, provided it functions well.
Attempting to be strictly compatible with a specific wiki is probably not a good idea, since the implementation platforms are often very different, formal specifications nonexistent, and popular wikis keep developing and changing anyway.
But if there is a range of choices, one should try to choose something that will be familiar to many people and easy to adjust to for others (as Creole states it).

Important is to keep in mind that the platform being used is Vim, so the design has to allow a sensible and efficient implementation based on what Vim offers. It is good to exploit the strengths of the platform, and stay away from areas where serious difficulties could arise very soon. Notably, Vim has a quite flexible **syntax highlighter/parser**.

## Extensibility ##
The future is notoriously hard to predict, but one can make some effort already in the beginning to anticipate the need for future extensions or generalizations. One should think about possible **conflicts**, ways of **escaping** special meaning, problems with **nesting**.

Think carefully when introducing a _special tag_: is it going to be difficult to use them for people that may need them to represent themselves, or some other _special_ meaning? How about people with different keyboard, language, or even a different script?
Is it going to be difficult to specify when you can or cannot use the "special" character as special or as a normal character?
Is it clear whether you can nest one environment inside another one? Is there going to be a way to pass some additional parameters to more complex environments, so that some variants can be created, without having to make a lot of changes to the way wiki is processed?

For many wikis (especially the "easy to use, learn in two minutes" type), it is usually fairly difficult to find out answers to any of these questions.

It seems wise to distinguish _inline_ environments and _multi-line_ ones, as they usually serve a quite different purpose. **Multi-line environments** should have a different start and end markers, and those should be at or near the beginning of a line (or end of line), preferably both at the same time, that is **alone on a line**: this make it possible to pass extra options without immediately creating conflicts. Besides, this should make it possible to make a **fast pass** through the wiki, finding out its overall structure, without having to do a full "parse" through all the inline markup.

Relying a lot on certain amount of indentation or alignment as the only indication of some special environment is rather shortsighted, as it pretty much precludes any simple nesting --- unless there is precisely one such environment.

When there is sufficient control to prevent conflicts, one could think of adding a mechanism for **user-defined environments**, instead for trying to hard-code a lot of different cases. Many people need only a few environments, but need them very often; unfortunately, it is different environments for different people in general.

## Nice Looks ##
Relatively unobtrusive markup is what most wikis try to come up with. The **content** should not be lost to all the marking. The challenge is to do that while allowing more complex documents being created too. But trying to make the text to "look nice" should never be taken as far as to result in a large processing penalty or a use of a lot of space for things that are more or less just decorative. And, of course, not to get in the way of quick editing.

# Some Examples #

  1. Good (actual): The use of ```...``` for quoting a code or "literal text" or TeX's `$...$` for inline formulas or technical notation (it is not so great your keyboard does not have that crucial character, though...) --- in some people's notes, these occur with high density, so the extreme shortness of the marker may offset the otherwise rather troublesome fact that the opening and closing markers are the same. These are at the same time good examples of a markup that is making an important semantic distinction, and its use should be encouraged.
    * +economy, +semantic markup
  1. Bad (fictional): SecureWiki interprets the `&` character either as `&` or as the start of a text in red color, depending on whether a secure hash sum of the previous 15 lines of the wiki text is even or odd, presumably to prevent an unauthorized use of comments (or red color) --- nobody is sure. But computers are fast, and checking the condition is just a function call away, so why not...
    * -economy
  1. Bad (real): a certain programming language family signals the beginning of a comment (which could span over many lines do not have to be marked in any way) with `/*`. That means, in general, that any place you a looking at may turn out to be a comment, because of the special sequence might have occurred two hundred lines above, in column 389. So unless you happen to see the end marker sooner, you are in for a lot of checking: including some of the parsing, to see if any of those `/*` above are real or inside a quoted string or any other hiding place that could deactivate them. In a programming language, the lines are supposed to be rather short, but in any case, this is bad: environments that can swallow large amounts of lines should be discoverable without doing a fairly complete parse of everything above. In a wiki, this would be a terrible design choice.
    * -economy, -extensibility
  1. Questionable -- depending on language (real): many wikis are fond of using _CamelCase_ words for easy automatic linking. This convention cannot be extended to most of world's scripts that do not have "upper case". Moreover, it does not look palatable to a lot of people whose scripts use upper case. Similarly, the practice of recognizing some _text style_ markers as such only if they are preceded/followed by a space is very convenient --- unless you happen to use a language that does not use spaces to separate words (we are talking about a lot of people here): in that case, you basically cannot emphasize text at all (not without making it look rather strange).
    * +ease of use, -extensibility  OR  ---ease of use, -extensibility
  1. Bad (fictional): In ArtWiki, level-four headers are to be typed in at least four lines high ASCIIart
```
| (_) | _____  | |_| |__ (_)___ 
| | | |/ / _ \ | __| '_ \| / __|
| | |   <  __/ | |_| | | | \__ \
|_|_|_|\_\___|  \__|_| |_|_|___/
```
> > (taken from http://www.figlet.org/). This may look great as a "plain text", but who would want to spend several minutes correcting a simple typo? Yes, someone probably wrote some macros for your editor that make this easier (provided you know how to use them), but it is much better to have an easily detected marker indicating a heading: it is easier for people to type, much easier for the processing program to detect. And saves a lot of space.
      * +nice looks, -economy
  1. Bad (real): Take a look at "grid tables" used by [reStructuredText](http://docutils.sourceforge.net/docs/ref/rst/restructuredtext.html#grid-tables), and maybe you would prefer to correct the header above to "Not like that" rather than adding a sentence or two to some of the table cells.
    * +nice looks, -economy
  1. Bad as an input (real): Looking at [MathML](http://www.w3.org/TR/MathML3/chapter1.html#intro.example) (an XML for describing mathematical notation), you see a format designed to capture the structure of a formula (which it does well, given that it has to be XML), but is utterly impractical for humans to enter. It would take "fast" out of "Wiki" if one were required to use this for input. If you have no intention looking at the linked example, just look at a source of pretty much any HTML table you find in the wild: you are very likely to see something where the actual content (the important bits for us humans) is completely marginalized by heaps and heaps of marking.
    * +semantic marking, -economy, -ease of use


# Vimwiki: Planned (and Other) Improvements #
In order to increase flexibility and reliability, the syntax file and the processing Vimwiki does to create the output (HTML) has to be changed to take advantage of Vim's syntax engine. This will open up many possibilities for greatly extending the complexity of markup that can be handled.

What could be done in the near future:
  * NewLists -- lists (ordered, unordered, definition lists)
  * NewMath -- environments for equations, setup for browsers
  * NewEscapes -- escaping _special tags_ used for markup, and "literal" environments for `code`
Perhaps to be done after that:
  * NewLinks -- wiki and external links, images etc.
  * NewTables -- table designs that are practical
Certainly worth discussing, but no concrete plans:
  * NewOutlining -- something akin to [[TagList4Vimwiki](TagList4Vimwiki.md)] could work without having to run `ctags`
  * NewLabels -- labels, footnotes, citing a bibliography, indexes, advanced features such as templates, macros, substitutions


---

In order to solicit some comments:
  * This page is not intended to become an encyclopedia of wikis; if you have some knowledge of other wikis, please contribute to one of the pages focused on a specific area. But you are very welcome to suggest a correction of any factual errors or an addition of important notes that should not be omitted on this page. Also any Vim scripts with similar goals should be mentioned here.
  * Especially welcome would be examples of **good** design from other wikis or documentation systems that serve as a good model for Vimwiki. The comments should go into the appropriate page. Many suggestions and wishes went into GuestBook and some keep coming to the [Issues tracker](http://code.google.com/p/vimwiki/w/list). The former has become too long now, the latter is not easily summarized either. It would be good to start a more focused discussion on separate pages.
