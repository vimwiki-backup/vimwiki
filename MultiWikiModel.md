This is not about configuring the current version (1.2) of vimwiki; if you are interested in that, the most basic settings are discussed at MultipleWikies.



# Multi-Wiki Model #

Some people may find it useful to have several wikis present on their system. As explained in LinkProperties, the main point in making this work smoothly is the following: the necessary condition for having both interwiki links and "movable" HTML output is to have one main HTML directory, not each wiki having its output in completely unrelated directory. This makes it possible to use vimwiki both as a "personal" wiki (with many references to purely local resources that would not make sense on another system) and as a "public" wiki, with well-behaved links to resources that are meant to be public (and easily transferable to a different system).

The second main point is that each wiki should be distinctly named. This can be put to a good use by disposing of a large amount of configuration parameters, among other things, so that multi-wiki setup is greatly simplified, even though different wikis may still be physically located in unrelated directories (as in the original model, which had no provisions for interwiki linking).

There is nothing here that was not already outlined in LinkProperties, but here it might be more easily digestible.

The basic assumptions on individual wikis are based on the approximate model vimwiki seems to use:
  * each of (possibly several) declared wikis has files of a certain **wiki syntax** and uses a certain **file extension**, and those wiki files are located in a certain **subtree** of the local filesystem (which may contain some nonwiki files as well)
  * the generated HTML files for these are generally located in a different directory, whose subtree structure mirrors that of the source wiki files
  * aside from the above _regular_ wikis, one is allowed to create wiki files also in any other directory, but for these "wiki" files, no separate directory (or anything else, for that matter(?)) is configured, so the only natural place for placing any generated output seems to be the same directory where the file is; in vimwiki documentation, these seem to be related to "temporary wikis", here (and in LinkProperties, these individual wiki files are referred to as _orphan_ wiki files.

## A Short Recap of Link Properties ##
A short summary of schemes to be used to refer to local resources:
  * **wiki files**: no scheme (internal wiki links), `wikiname:` (internal interwiki links, when names not available: `wiki1:`, etc.), `orphan:` to refer to wiki files not belonging to a declared wiki
  * **non-wiki files**: `file:///` (the standard way to refer to "localhost", requires absolute path), `loc:` (path relative to the current wikifile), `media:` (path relative to a "media root" location, which itself must be in a fixed position relative to html directories)

HTML links are "movable" if they remain functional after the (HTML output) files are moved to a different system/location. The absolute "internet" links have that property, and relative (in HTML!) local links have that property.

Here is a short, simple summary:
  * movable (or "**public**") are all regular wiki and interwiki links and links to `media:`, as well as normal "internet" links
  * non-movable (or "**private**", tied up to the local filesystem) are all `loc:` links, `file:///` links and links to orphans

Do note that this does not quite correspond to relative path vs. absolute path specification of the link in the source wiki file (`loc:` links use a relative path in the wiki source, but they result in a non-movable link in HTML).

Having a "movable" output is useful in several scenarios: if one wants to make the same HTML output available on a web server, or have a copy in a "synchronized" folder (hence on several systems, each with possibly quite different filesystem structure). Also, if anything like conversion between different syntaxes was contemplated, the "movable" links are probably the only kind that is going to make sense in many wiki formats (since the most popular ones are always designed for "public" wikis).

## Multi-Wiki Model Specification and Configuration ##

The interwiki model has to be better specified. Rational simplification of configuration is necessary for the HTML output, but is also useful for wiki files, to make it easier to setup several wikis without having to tweak paths and names using half a dozen variables for each wiki.

To avoid confusion with the original model (which uses per-wiki paths `vimwiki_path` and  `vimwiki_path_html`), the main paths are called `vimwiki_dir` and `vimwiki_html_dir` below.

### Wiki files ###
Several wikis can be declared, each has a distinct name, and each uses one kind of syntax, and one file extension for its wiki files (syntax kinds or extensions are not necessarily distinct). A "wiki" means the collection of all appropriate wiki files of its "root" directory and also all its subdirectories.

Needed variables:
  * A single `vimwiki_dir` for the location of the main directory (one for all wikis).
  * An ordered list of names of individual wikis (their "names", only reasonable characters, please), their type (syntax), and file extension.
  * The names have to be given, syntax and file extension can be assigned by default.
  * A number of other per-wiki options are possible, but not really necessary for the main functionality.

**Example** with three declared wikis: `work`, `people`, `travel`, and we assume `vimwiki_dir=~/vimwiki`; the file system will contain (among other possible files)
```
~/vimwiki/
    |-- work/     (can be a filesystem link:  work ----> /path/.../somework/)
    |-- people/
    |-- travel/
```
**Notes:**
  * it is OK to have filesystem links to directories (symbolic links or "shortcuts") instead of actual subdirectories, therefore the actual location of an individual wiki can be any place which is potentially accessible from the local filesystem (even removable storage devices that are not attached all the time)
  * we do not want to assume there are no other files or directories present in `vimwiki_dir`, therefore it is better to declare the names (rather that having the directory scanned for all subdirectories); also the order may be useful, for instance the first declared wiki is considered the "main" or the "default" one, and should be available all the time
  * these declared names can be used as scheme names to make interwiki links; since they might be too long or contain unacceptable characters for a scheme name, perhaps it useful to allow to use `wiki1:` etc. instead as the scheme name (but then one has to be careful and declare "new" wikis at the end of the list in order to not invalidate the "old" interwiki links)
  * there is a possibility that some people will not find it intuitive that interwiki links (for instance from the `travel` wiki) have to be done as in `work:subwork/WikiPage` instead of `work/subwork/WikiPage`, but perhaps people will declare several different wikis for a good reason only (i.e. different syntax or extension or a very different part of their filesystem) and those should understand the difference
  * not relevant now, but for the possible future: the "main" vimwiki directory could be later used to store various files needed to support "advanced" functionality (cached anchor locations or backlinks/interwiki links "database", statistics or "recent" changes etc.); currently, any of this is completely out of question for performance reasons (not because of a lack of a suitable "natural" location for storage)

**Example** (a single wiki only, likely the most common example): assuming a single wiki with the location given in the original model by default path `vimwiki_path`, the same location could be reused in this model by setting `vimwiki_dir` to  the parent directory `vimwiki_path/..` and the name of the (single) declared wiki to `vimwiki`.

**Example** (several wikis configured in the old model, probably not very common): assuming several wikis with arbitrary locations given in the original model by several paths `vimwiki_path`, the same locations could be reused in this model by setting `vimwiki_dir` to  `vimwiki_path/..` (using the first wiki, for instance) and then creating symbolic (filesystem) links (disctinctly named!) in `vimwiki_path/..`, each pointing to the respective "other"  `vimwiki_path` directory. The (distinct) names of all the wikis now have to be declared, of course, in a fixed order.

During plugin initialization (or ftplugin, with caching so it does not have to be done each time), vimwiki finds out the actual location of "root" of each wiki from the file system (some wikis may be non-accessible, e.g. those on removable media, that is not a problem).

On opening a wiki file: it needs to be first determined which wiki the file belongs to. Basically, one wants to find out which of the declared wikis it belongs to based on the file path. Problems to be resolved in a specification:
  * One cannot quite assume that the declared wikis are non-overlapping (because of the possibility of filesystem links). Therefore to avoid ambiguities, one has to say in which order are wikis tried when searching for the "owner" of a wikifile (even if one tries all and selects the "closest" match).
  * What if the extension does not agree with the location? In that case, the file cannot be considered a regular wiki file, it should be treated as an "orphan" wiki, or not a wiki file at all.
  * If the wiki file does not belong to any of the declared subtrees, the file is an orphan wiki. It still needs to be specified how to determine its syntax, though.

There is a possibility of overlapping wiki trees (in the worst case, two wikis could point to the identical directories). But as said above, since wikis are declared in a certain order, a rule can formulated that assigns a unique wiki to a file (provided it does fall into at least one of the declared subtrees).

The only serious issues are coming from orphan files (vimwiki docs call it "temporary wiki"?), since there is no guarantee that extension determines syntax (it is probably assumed to be the "default" syntax, but it seems they can have many extensions(?)). This needs to be specified/restricted/disallowed if there were several kinds of syntax possible. Allowing more than one extension for these files makes it impossible to refer to these as wiki files in normal fashion (i.e. not writing the extension) unless several `orphan:` schemes are used to allow the disambiguation. Which would be a totally needless complication just to support such a marginal "feature" that these orphan wiki files represent.


### HTML files ###
Needed variables:
  * A single `vimwiki_html_dir` for the location of the main directory
> > (The default can be derived automatically from `vimwiki_dir` as usual, appending `_html`).
Possibly configurable:
  * The location of the "media" directory, let's call it `vimwiki_media_path`, relative to `vimwiki_html_dir` (the default is `media/`); the directory is to hold all the material that is needed by HTML generated files, such as stylesheets, local images and anything else that is meant to be possibly "public" (and should be/could be moved alongside the HTML files anytime they are copied somewhere else); the templates used for generating the HTML files can be there for convenience, so that no other configuration is needed.

Nothing else is needed for all the basic functionality. For the three-wiki example above, assuming that `vimwiki_html_dir` is set (or not set and simply defaults to) `~/vimwiki_html`, we have the following in the filesystem:
```
~/vimwiki_html/
    |-- work/
    |-- people/
    |-- travel/
    |-- media/
         |-- style/ (contains stylesheets work.css, people.css, travel.css, 
         |          and also templates work.html, people.html, travel.html)
         |-- ...    (any "public" files needed by HTML, such as images, scripts)
```
**Notes:**
  * the structure of each of the tree HTML subdirectories mirrors that of the corresponding wiki directory
  * unlike for wiki files, there cannot be any symlinks here if we want to have interwiki links working via relative links (and we want that, so that if the entire `~/vimwiki_html/` is moved somewhere else, all normal interwiki links and links to media still work)
  * even if  `vimwiki_html_dir` is set to `vimwiki_dir`, everything should work, the html file would then go to the same directory where the wiki file is (things are not going to work smoothly if symlinks were used, or if someone declares "html" as the wiki extension, obviously)
  * all the custom templates and stylesheets would also go into `media/style`
  * there is a slight duplication in the style directory in case someone with several wikis uses only one template, one stylesheet, but the setup is transparent and simple: no need for a dozen more configuration paths or names
  * the rest of media directory is useful for anything else that user wants to include/refer to in HTML via relative links (for instance images)
  * in the case of a single wiki and little or no "public" material, those who would find it less "nice" to need a separate directory just to hold the default stylesheet (and template) could override the default location of "media" to coincide with their (only) wiki (for instance `wiki1/`) or to set "media" to the same directory as `vimwiki_html_dir` (this has a similar effect, but this time `style/` is a sibling of `wiki1`, not a child); this single-wiki situation is really the only reason to make the `media:` location configurable, in case of multiple wikis, it is hard to imagine any reason to try to change the default

**Compatibility note:** It is not possible (except for special cases) to "reuse" the locations of the HTML directories configured under the old system. In general, one has to change the "old" HTML directory names (to match the associated declared wiki file), and probably also move the directories, so that all HTML "root directories" become siblings in the filesystem, with `vimwiki_html_dir` pointing to the common parent directory. Unlike in case of wikifiles, it is not a good idea to try to make symlinks to the "old" locations: basic internal wiki links would be movable, but the interwiki links would either not work or would have to be made absolute (hence non-movable), and sharing of "media" files would be similarly difficult.

### Convenience settings: custom schemes ###
These are just for convenience, and their main use is to allow easy creation of (non-internal or internal) interwiki links, without having to type the full path to the resource.

The simplest setup is the following: allow specification of custom `schemename`, `protocol:pathprefix` pairs, and vimwiki will treat URL `schemename:path/filename` exactly as `protocol:pathprefix/path/filename`. Specifically, we have just about three cases, depending on the `protocol`:
  1. "universal" internet protocol (such as `http:`, or `file:`): the absolute path is generated
  1. a registered wiki (for instance `work:`): here we are basically creating internal interwiki (or subwiki) links: this means extensions are managed (`filename` is written without the extension) and generated HTML links are relative
  1. the "media" scheme: these are considered non-wiki links (thus no extension juggling is done here), but the HTML links are again relative, and therefore "movable", provided the `pathprefix/path/` does not go "up"
No other protocols can be used to specify these abbreviations: only a subset of IANA protocols, "registered" vimwiki wikis and the "media" scheme (so each of the custom links is unambiguously of one of the three kinds: **U** or **W** or **O L**, using the terminology of LinkProperties)

An **example configuration**, here just a simple `schemename=protocol:pathprefix` format is used:
```
wp-ja=http://ja.wikipedia.org/wiki/
ggs=http://www.google.com/search?q=
Issues=http://code.google.com/p/vimwiki/issues/detail?id=`
docs=file:///home/joe/Documents/
invoice=work:administration/invoice/
diary-work=work:diary/
Barcelona=media:photos/2010/Spain/Barcelona/
```

**Example of use** of "URL"s in wiki files (not showing any syntax for links, just URL itself, without any URL "%"-encoding), and assuming we have the three-wiki setup, with no modification to the default configuration:
  1. `wp-ja:日本列島`  will be expanded to `http://ja.wikipedia.org/wiki/日本列島`   (`wp-ja` allows to make an external "interwiki" link)
  1. `ggs:Vim+vimwiki` will refer to `http://www.google.com/search?q=Vim+vimwiki`  (this is a "query" link)
  1. `Issues:111` for `http://code.google.com/p/vimwiki/issues/detail?id=111` (again, a query)
  1. `docs:other/Proposal.odt` will refer to `file:///home/joe/Documents/other/Proposal.odt` (of course, this link in HTML is likely to be unusable if HTML files are "served" or are moved to a different system, and is effectively only as a "private" link; the same is going to happen with any local non-wiki resources except those under `media:`)
  1. `invoice:2010-10-16` will, in the HTML output generated for a wiki file in `work/2010/` subwiki, refer to `../../work/administration/invoice/2010-10-16.html` (so we use `invoice:` to refer to a "subwiki" here, where a simpler `../administration/invoice/2010-10-16.html` would work, but one could just as well use it from another wiki); in general: this relative path is the concatenation of the relative paths `rel_path_to_root` (of the current wiki, here `..`), `..` (to get to `vimwiki_html_dir`), `protocol:path/filename` (for the `invoice` custom scheme, here `work/administration/invoice/`) and the actual wiki-filename plus extension (here `2010-10-16.html` for HTML output), with some simplification possible (but inessential) if we are in a "subwiki" situation
  1. `diary-work:2010-10-16` is fairly similar to the previous example, but kind of pointless: if the diary is not buried deeper in the wiki hierarchy, it is just as easy to write directly `work:diary/2010-10-16` (even if you have a complex subwiki hierarchy in "work" wiki from which you need to refer to diary files, as this works from any level or any other internal wiki), so there is no real need for a custom "scheme" in this instance
  1. `Barcelona:DCM1234.jpg` would, in the HTML output for a wiki file on the "root level" of the `travel` wiki (or any other wiki, as long as we are on the root level of that wiki), refer to `../media/photos/2010/Spain/Barcelona/DCM1234.jpg`; in general: this relative path is the concatenation of the relative paths `rel_path_to_root` (of the current wiki), `vimwiki_media_path` (global setting), `path/filename` (for the `Barcelona` custom scheme) and the actual path/filename (here just `DCM1234.jpg`)

**Remarks**:
  * in order to make this mechanism useful for "queries" and similar server-generated pages (at least in simple situation where no "suffix" is needed, such as the example of `ggs:`), one should take care to configure the path-prefixes of normal interwiki-like links with the ending `/`, and not expect those to be inserted automatically
  * the more customization there is (and this applies to the "interwiki" schemes in particular), the less universal the wiki file that uses them becomes, and more complicated natural conversion to a different format might be; this should be kept in mind if you ever plan to possibly migrate your wiki files to a different format or to share them with other people
  * it makes no sense to introduce new schemes just because one can do that, it is useful only if you make a heavy use of those links and it shortens their form significantly; for instance, the `diary-work:` scheme is not really useful, as noted above
  * note that the type of the link is automatically deduced from the scheme of the definition, which greatly simplifies the configuration and makes it very intuitive (well, at least for the person who knows what the personalized schemenames stand for)
