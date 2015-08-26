# Link Properties #




Here examples in the familiar syntax are avoided as much as possible to avoid confusing the intent and the syntax of the current or past implementations.
## Basic distinctions ##
  * **W/O**: **wiki** (vimwiki files only) vs. **other** (non-vimwiki) links
    1. it would be too confusing here, but often in wikis similar distinction is called "internal vs. external"
    1. the distinction is important, as **W** are _the only_ links for which
      1. (by a typical wiki convention) the file extension is not written in the source, it is implicit
      1. "enter link action" means open in buffer with _the corresponding wiki_ file
      1. in conversion to html, the linking is assumed to be to _the corresponding html_ file
  * **L/U**: **local** resources (files on the same system) vs. **universal** (or "uniform") resources (internet resources)
    1. the line is not completely clearcut here (because of the `file:///path...` URLs)
    1. allowing local resources with _no scheme_ is tricky: you'd better have a markup that allows you to clearly distinguish such **L** and **W** (!!!)
    1. the fact that **W** always implies **L** _does not_ mean
      1. **L** => **W**
      1. "no extension" => **L**
      1. "no extension" => **W**
  * **R/T**: **refer** to (simply make a link to) vs. **transclude** (inline linking, "include" data in the page)
    1. it is somewhat restrictive, but not completely unreasonably so, to allow transclusion for images only (although it is only a matter of time before someone starts asking about video, audio, or other objects, so if this is done in a very inflexible way, it may be difficult to support later with any semblance of consistency)
    1. it is somewhat restrictive, but not unreasonably so, to allow images of only certain "file extensions"
    1. it is _wrong_ to "automatically" infer
      1. "image extension" => **T**
      1. **T** image => automatically wrap the image in another link to the same image (this self-reference/thumbnailing is rarely needed, and should not be the default way to handle **T** images)
    1. again, there has to be a _scheme_ or _markup_ helping to distinguish **R** and **T**  even if **T** is not available for most links
      1. most big wikis go for the scheme (usually `Image:` or `img:`, but that is an easy solution only for systems like WikiMedia that do not allow **T** **U** images)
      1. for a personal wiki, you want both **T** **U** and **T** **L** images, therefore "image" scheme is problematic if you wanted to treat uniformly **T** **U** and **T** **L** (that apparently does not stop some from trying: http://www.wikimatrix.org/syntax.php?i=116 shows 3F Wiki `[[image:http://external.com/path.png]]`)
      1. rather obviously, you cannot use the "extension" to make this distinction, unless you want to perform some artificial extension gymnastics similar to vimwiki's (past?) "treatment" of `file:///` protocol (among other things), which will invariably create more problems than it "solves"
      1. many wikis choose markup: MoinMoin (parent of Google wiki) `{{http://foo.bar/foo.jpg}}` or `{{target|alt|params}}`, Wiki Creole `{{Image.jpg|title}}` (these are both wikis using `[[...]]` for **R** links and having overall very high degree of syntactic similarity to vimwiki)

## Possible organization ##
### Schemes ###
  * no scheme means **W**: `WikiLink` or "subwiki" link `dir1/dir2/WikiLink`
    * questionable: non-subwiki `../../dir3/WikiLink`; which wiki would it "belong" to?
    * possible syntax: `[[...]]` (throw in a "description" somewhere)
    * possible syntax for CamelCase people: `WikiLink` (No markup! This is not a good idea for a fairly important thing such as a link, and wikis that have some sense in them have moved away from this already; besides, there is the additional burden of supporting further syntax which can prevent every JavaScript, PhD or MacDonalds etc. turning into a wikilink)
  * schemes `wiki1:`, ..., `wiki5:`, `diary1:`,..., `diary5:` mean **W**
    * these are (internal) interwiki links
    * having names for wikis would be much better (but those names cannot conflict with established protocols); the above looks like a sensible default
    * possible syntax: as above `[[...]]`, subpaths should be accepted too
    * fairly obvious and easy to implement, as long as no fragments are involved, and it is clarified what are the various wikis (since they have potentially different syntax or configuration, it may be important for more advanced features)
  * scheme `local:` (or shorter `loc:`, but `l:` is too short) means **L**, we are referring to a local (typically non-wiki) file
    * for convenience, a relative path can be accepted (relative to what? this has to be made perfectly clear; the natural choices: the referring file's directory or the "current" wiki's main directory if that is unambiguously defined or user's home directory; much less natural choice: "html" or some other directory depending on yet another variable)
    * in this case, not just subdirectories, but also `local:../../file.ext` seems perfectly fine
    * absolutely no "extension" adding, subtracting, or any other mutilation
    * possible syntax: overload `[[...]]` (e.g., WikiCreole does that) or use `[...]`, either would work fine and allow for some sort of "description"
    * keep in mind user may want to **T** some of these resources
  * scheme `file:` with `///` it refers to the "localhost", and one has to use the absolute path
    * whether you think of it as **U** or **L** does not really matter, no need to trying to define it
    * absolutely no "extension" adding, subtracting, or any other mutilation, this is the standard IANA scheme!
    * possible syntax: as above, or "naked", with no markup (again, some wikis would object that "no markup" should not be turned into an active link, but at least (unlike the unmarked CamelCase), the presence of `file://` is a fairly reliable indicator that this is meant to be URL; for a personal wiki, it seems reasonable to allow these as active links)
  * scheme `http:`, `https:` and an assortment of others, typical **U** links
    * as above, nothing to see here

### Images ###
This is really about transclusion (think about images).
  * Because we want to allow **U** images (not just **L** images), it seems awkward trying to make the **R/T** distinction through a "scheme".
  * Because checking for "extension" does not reveal the intent (is it to be **R** linked or **T** linked?), the extension helps very little with this (unless you are willing to completely sacrifice the ability to **R** link to images).
  * Relying on "extension" to tell you it is an image is also sacrificing the ability to **T** link to server-generated images (which normally do not have the right extension, as in `http://yuml.me/diagram/scruffy/class/[Wiki file]-Vimwiki2HTML->[HTML file]`).  http://yuml.me/diagram/scruffy/class/%5BWiki%20file%5D-Vimwiki2HTML-%3E%5BHTML%20file%5D
  * What is left? Syntax, obviously. There has to be
    * either a special extra parameter in (already very overloaded) `[[...]]` indicating one wants **T** (in that case, there has to be also some place for extra parameters, such as the size)
    * or there is a distinct syntax for **T** links, such as `{{...}}` (used by http://moinmo.in/HelpOnLinking or http://www.wikicreole.org/wiki/Creole1.0#section-Creole1.0-ImageInline ), or a similar syntax `<<...>>` that would be easier to type on more keyboards (but does not seem common in wikis)
      * this makes it easy to deal with server-generated files
      * this makes it easy to "make space" for extra parameters (i.e. size in case of image)
      * it makes it easier to combine it with the **R** link syntax to provide "thumbnail" linking, where one image (the "thumbnail") is itself a link to another resource `[[URL_linked_resource|{{URL_thumbnail}}]]`; here the **T** thumbnail is used as the "description" part of the **R** link, so it does not look like a special rule (although it is a special situation, other combinations of "link in a link description" do not make much sense)
      * it is much easier to reuse this syntax for other conceivable transclusions (video or audio, perhaps even other components like navigation menus) without having to introduce more rules and exception and exceptions to exceptions governing the handling of the basic (and very important) **R** link (but one would have to rely on "extensions" or "extra parameters" to tell the type of the media)

## Summary ##
As the above tries to show, reasonable linking requirements can be taken care of with just two distinct markups (one for **R** links, for instance `[[...]]` syntax, and one for **T** links, for instance `{{...}}` syntax), provided one uses suitable "private" schemes. The schemes take care of the other distinctions that are really necessary; for vimwiki, `loc:`, `wiki1`, ..., `diary1`, ... is enough. More markup would be required if no private schemes are used. One could also think of attempting to do everything with a single markup, but then one either looses the ability to link to certain resources in the intended way, or the rules of use are going to be much more complex and less transparent.

Relative paths `../../file.ext` (with no protocol) are technically perfectly legitimate relative URI references. That does not mean they are useful in this form in a wiki, unless there is a suitable markup for these. Wikis are optimized to allow easy linking to other wikifiles on the same wiki. For other links (such as locally available files), it is common to require the use of (private) schemes such as `Image:` or `attachment:`. Using `loc:` would be easy to type and serve the purpose of marking these as local non-wiki files (with a relative path specification, unlike the official `file:` scheme).

There is also no major obstacle to allowing personal configurable schemes for user's frequently used sites/wikis/destinations: for instance
  * `wp:Wiki` could stand for `http://en.wikipedia.org/wiki/Wiki`
  * `Issues:111` for `http://code.google.com/p/vimwiki/issues/detail?id=111`
  * `doc:receipts/2012.txt` for `file:///home/joe/Documents/receipts/2012.txt`

Scheme and markup (sufficiently non-ambiguous markup) are simple and effective means of telling things apart.
"File extension" is not in the same league, it should be used only as a secondary differentiator, or for things that are of secondary importance only (for instance, the display of an icon next to a link based on the "type" of the link).


---


## Extra info: components of a traditional URL ##
This is meant for common URLs such as `http://www.abc.com/dir1/dir2/abc.php?x=y=z?25#here`, not for more general URIs http://en.wikipedia.org/wiki/Uniform_resource_identifier which would include resources such as `mailto:joe@abc.com` or `urn:issn:1535-3613`.

URL regex for parsing from newer RFC3986 http://tools.ietf.org/html/rfc3986 , written with "magic" `?` and `()` for simplicity
```
 ^(([^:/?#]+):)?(//([^/?#]*))?([^?#]*)(\?([^#]*))?(#(.*))?
  12            3  4          5       6  7        8 9
scheme    = $2
authority = $4
path      = $5
query     = $7
fragment  = $9
```

Notes:
  * important characters are `:/?#`
  * the query part can contain `/`
  * the fragment is the part after the first `#` in the string (and can contain anything)
  * the query is the part after the first `?` in the string (and can contain anything but `#`)
  * the scheme can in reality only contain alphanumeric chars (must start with one) and "+", "-", or ".", and is case-insensitive.
Basically, URL has to be parsed from left to right, and there is no mention of "extension", of course.


---





## Syntax examples ##
  * **Variant A**: needs `[[...]]` for **R** links, `{{...}}` for **T** links, _no scheme_ is allowed for **W** only (means wiki files in the same wiki), `loc:` for **L O** resources
  * **Variant B**: uses `[[...]]` for **W** (wiki) links, `[...]` for **O** (non-wiki) links, `{{...}}` for **T** links ("embedded" resources like images)

Not serious designs, lacking the generality and/or simplicity, here just for comparison:
  * **Variant C**: uses `[[...]]` for **W** (wiki) links, `[...]` for **O** (non-wiki) links, with some "file extension"-based detection for **T** links ("embedded" resources like images)
  * **Variant D**: uses `[[...]]` for all kind of links, with all kinds of kludges based on "file extension" detection or extra parameters to make (some of the) necessary distinctions

We are going to need `wiki1:`, ..., `wikiN:` schemes to allow interwiki linking, and probably also `diary1:`,...,`diaryN`, regardless of syntax.

There are some variations (more or less equivalent) of the bracketed syntaxes for allowing secondary arguments:  `[[arg1|arg2]]` or `[[arg1][arg2]]` for double-bracketed syntax, and `[arg1|arg2]` or `[arg1 arg2]` for single-bracketed one.
Here `arg1` is URL, (optional) `arg2` the description text (this order is popular in some wikis, such as those whose syntax was vimwiki originally based on).
The examples will be shown with the "pipe" separator.

For the transclusion links (images linked "inline"), one generally needs more parameters `arg3`, ... (for example, used to set the desired size or alignment for images). Again, "pipe" is going to be used as the argument separator.

### Variant A ###
Here, only two kinds of links are distinguished by syntax: `[[..]]` for **R** links, `{{...}}` for **T** links.
  * _no scheme_  means the resource is a wiki file in the same wiki (hence **W** in particular; and so it applies only to `[[...]]`).
  * Therefore we need a _faux_ scheme `loc:` to distinguish **L O** from **W** links, since we want to be able to write them both in shorthand, with relative paths (here _relative_ is going to mean relative to the containing wiki sourcefile).
  * It is possible to allow all **R** links without a markup, provided **W** links follow some restriction on naming (CamelCase), but it is not a good idea (certainly not for those _no scheme_ links).
It would relatively safe to allow naked links only for the most frequent and familiar schemes (`http:, https:, ftp:, file:, mailto:`).

#### R-links ####
**W** links (in HTML, the target of these links is the associated .html file, unlike the target of **O** links)
  1. `[[wikifile| Link in the same wiki]]`
  1. `[[relpath/wikifile| Link in the same wiki]]`  a possibly different directory, for example a subwiki
  1. `[[wikiJ:wikifile| Link to the j-th wiki]]`  wikifile in the "root" directory of the j-th wiki
  1. `[[wikiJ:relpath/wikifile| Link to the j-th wiki]]`  wikifile in the j-th wiki
  1. `[[diaryJ:wikifile| Link to the j-th diary]]`  wikifile in the "root" directory of the j-th diary
In HTML: the _no scheme_ links translate to plain relative path links (nearly verbatim `relpath/wikifile.html`), the other (interwiki) into `file:///` links with absolute paths (namely `file:///abs_path_to_htmlJ/relpath/wikiname.html`). Going from `wikiJ:` to `diaryJ:` or back can be done with relative paths too, in normal circumstances (for instance, if the diary is a "subwiki").

**L** **O** links (local files): do not start the `relpath` with `/`, use `file:///` for absolute paths
  1. `[[loc:file| File link]]`  file in the same directory as the containing wiki file
  1. `[[loc:relpath/file| File link]]`  file in the directory derived from the containing wiki file
  1. `[[loc:wikifile.ext| Source of the wikifile]]`  not a **W** link, we simply link to the source of the wikifile
  1. `[[loc:relpath/image.jpeg| Link to a local image]]`  not a **T** link, we simply link to the image file
In HTML: all these links translate to `file:///` links with absolute paths (because the html files are generally in different directory than wiki files); as explained in the second comment below, `file:///abs_path_to_wikiJ/relpath/file` would be the HTML target for example 2.

**U** **O** links (internet resources)
  1. `[[file:///abspath/file| File link done formally]]`  **L** **O** or **L** **U**, whatever, it is on "localhost"
  1. `[[file://abc.com/path/file| File link done formally]]`  **L** **U**, but good luck getting that link "work"
  1. `[[http://abc.com/abspath/file| Typical link]]`
  1. `[[http://abc.com/abspath/image.jpeg| Link to an image]]`  not a **T** link, we simply link to the image
In HTML: the target is identical in common cases.

#### T-links ####
More parameters are often needed here, e.g. size for images `{{URL| text| size=...| ...}}`. All examples below are written without the extra parameters.

**L** **O** links (local files): do not start the `relpath` with `/`, use `file:///` for absolute paths
  1. `{{loc:relpath/image.jpeg| A local image}}`  a **T** link, transclude the local image
  1. `{{file:///abspath/file| A local image done formally}}`  **L** **O** or **L** **U**, whatever, show the (presumably) image which is somewhere on "localhost"

**U** **O** links (internet resources)
  1. `{{http://abc.com/abspath/image.jpeg| An image}}`  a typical **T** link, "show" the image

#### Combination: T-links as "description" of an R-link ####
"Clickable image" or "thumbnail image" is another way to put it.
  1. `[[loc:France2005/imagefile.jpeg| {{loc:France2005/imagefile.jpeg| Small version of the image| width=100}}]` a small image is displayed, the image itself is a link to the same image file
  1. `[[http://www.flickr.com/photos/joe/12345678/| {{loc:France2005/image100px.jpeg| Small local version, click to see the original}}]` a local small version is displayed, links to the online version
  1. `[[diary1:2005-07-14| {{loc:France2005/imagefile.jpeg| Bastille Day| width=100}}]` a small image is displayed, links to a diary entry (and should work from any wiki)


### Variant B ###
Three kinds of links are distinguished by syntax:
> `[[...]]` for **W** (wiki) links, `[...]` for **O** (non-wiki) links, `{{...}}` for **T** links ("embedded" resources like images). (We assume there is no need for **W** **T** resources ("wiki images"), that is why a single syntax for **T** links is enough).
  * _no scheme_ in `[[...]]` is as in Variant A,
  * _no scheme_ in `[...]` means **L** **O** resource referenced by a (possibly) relative path.
  * There is no need for `loc:`, but it is not possible to allow both kinds or **R** links with no markup, since ambiguities would arise (even if wikinames are restricted to CamelCase or something like that).

#### R-links ####
**W** links: same as in Variant A

**L** **O** links (local files): do not start the `relpath` with `/`, use `file:///` for absolute paths
  1. `[file| File link]`  file in the same directory as the containing wiki file
  1. `[relpath/file| File link]`  file in the directory derived from the containing wiki file
  1. `[wikifile.ext| Source of the wikifile]`  not a **W** link, we simply link to the source of the wikifile
  1. `[relpath/image.jpeg| Link to a local image]`  not a **T** link, we simply link to the image file

**U** **O** links (internet resources)
  1. `[file:///abspath/file| File link done formally]`  **L** **O** or **L** **U**, whatever, it is on "localhost"
  1. `[file://abc.com/path/file| File link done formally]`  **L** **U**, but good luck getting that link "work"
  1. `[http://abc.com/abspath/file| Typical link]`
  1. `[http://abc.com/abspath/image.jpeg| Link to an image]`  not a **T** link, we simply link to the image

#### T-links ####

**L** **O** links (local files): do not start the `relpath` with `/`, use `file:///` for absolute paths
  1. `{{relpath/image.jpeg| A local image}}`  a **T** link, transclude the local image
  1. `{{file:///abspath/file| A local image done formally}}`  **L** **O** or **L** **U**, whatever, show the (presumably) image which is somewhere on "localhost"

**U** **O** links (internet resources)
  1. `{{http://abc.com/abspath/image.jpeg| An image}}`  a typical **T** link, "show" the image

#### Combination: T-links as "description" of an R-link ####
similar to Variant A, but always in two flavours: `[...]` with **O** links, `[[...]]` with **W** linksk (and no need for `loc:` anywhere)


### Variant C ###
  * **Variant C**: uses `[[...]]` for **W** (wiki) links, `[...]` for **O** (non-wiki) links, with some "file extension"-based detection for **T** links ("embedded" resources like images)

The idea is that if the detected "file extension" in **O** link is one of the few (such as `jpg, jpeg` or `png` for images), the user probably want to make this a **T** link. So it is really simple in very simple cases, although at the expense of more processing (the "file extension" is a lot harder to get than the scheme from a general URL and its extraction has to be done for every link)as well as potential guarding against the presence of further parameters (that have no function/sense for non-**T** links) that may be there in case this is an image.

Of course, if one wanted to have the ability to override the automatic decision to **T** an image, or be able to **T** images that do not have the approved extension (e.g., server-generated ones), there has to be even more parameters, more parsing/extracting, checking conditions etc.

In reality, systems using this syntax are more likely to advise you to make the link in HTML directly if you are not happy with the guesses the system makes about the nature of the link.

### Variant D ###
  * **Variant D**: uses `[[...]]` for all kind of links, with all kinds of kludges based on "file extension" detection or extra parameters to make (some of the) necessary distinctions.

Feel free to work on this case, trying to keep it under five pages. Could be done easily by stacking schemes, though. That would be somewhat incompatible with the normal expectations of the "scheme" of a URL, but it avoids the pitfalls of relying on "extension"  to make a fairly important decision. (An example mentioned in the first section was `[[image:http://external.com/path.png]]`.)

## Problems ##
The above described conversion of links to HTML targets relies on absolute paths for interwiki links. That means:
  * it is efficient: the generator does not need to inspect paths and do any calculations (other than concatenation) on them (but for each processed file, one has to know which wiki it belongs to, and the relative path from the wiki's "root" to the processed subwiki file; this path must be "invertible", with no filesystem symlinks on it)
  * it works with arbitrary configuration: each wiki's HTML directory can be completely unrelated to the others (as is the case with the current vimwiki)
  * it works when wikis are browsed locally (over `file:` protocol)

### Unconstrained configuration limits flexibility ###
Deficiencies if the generated HTML files were to be used on a webserver:
  * interwiki links would not necessarily work if browsed through a webserver (due to security restrictions)
  * interwiki links would almost certainly not work if the individual html directories were moved/copied to the "webspace" on a server

Making the interwiki links relative is not practical in general (in the completely unconstrained case):
  * different html directories could reside, for instance, on different filesystems/partitions, making a relative path traversal difficult or impossible
  * even if possible for each pair of paths, the necessary calculations for N squared pairs would have to be done each time vimwiki is run (if it does not use any persistent storage)
  * even if all of the above was not a problem in a specific case, after moving/copying the html directories to the webserver, the relative positions could change, making all the calculations useless again

The root of the problem is clear: it is the totally unconstrained configuration possibilities for html directories that prevent efficient and simple solutions. The solution is nearly obvious too:
  * instead of N html directories in arbitrary locations, they can be just a single configurable path for the main html directory
  * each subwiki will have one subdirectory in the main html directory
  * the names could be chosen for each wiki, serving as directory names, and possibly reused as scheme names instead of `wiki1:`,... ; since they _have_ to reside in the same directory, the uniqueness of names is guaranteed (what is not guaranteed is that they contain only character suitable for a scheme)
  * the relative path transversals are now trivial (`../wikiJ` goes from the html "root" of one wiki into the html "root" of J-th wiki)
  * the HTML generation is just as efficient as before, and generated files slightly smaller
  * most of all, the entire html directory can be moved or copied (even to a different system), without breaking any interwiki links
  * the existence of the common html directory makes it possible to reuse stylesheets, icons etc. that would otherwise have to be copied N times
The only slight blemish is that in the conceivably common case of a person with a single wiki, there is now an "extra" directory level for html files (but again, that extra directory is useful for storing stylesheets, icons etc).

Diaries must be subwikis of the main wiki (with an easily "invertible" relative path, that is, containing no symlinks), or else similar problems as above could arise. They should not be treated as completely independent wikis (but as subwikis, allowing mutually relative addressing).


### The orphan wiki problem ###

Another problem specific to a personal wiki: there are _orphan wiki files_, those files of wiki filetype which are not in a subwiki of one of the declared wikis, but are placed arbitrarily somewhere in the local filesystem. Since the calculation of a relative path traversing between these and the main html directory is difficult in general, and there no way to control where their html versions could be moved, it is not worth anyone's time to think how to make them interoperate with the other wiki files under all circumstances.

Links from these orphans to proper wiki files can be done with absolute paths, linking to them from regular wiki files would require doing an inspection and calculation of a proper path (whether absolute or relative does not matter), therefore causing slowdown in processing (which is absolutely not worth it).

Fortunately, most of the extra code in the generator is avoidable even if these orphan files are allowed. Simple solution of placing "their" generated HTML file in a fixed subdirectory of the main html directory would not work, since several of them may have the same name, and the relative **W** links would not be correct either.

The only solution which avoids the inefficiency of path inspection and calculation of traversal paths (for every single **W** link with relative path, not just those having something to do with orphan files!) is to _not allow_ referring to orphan wiki files by relative paths (from regular wiki files), and requiring the use of a scheme `orphan:` which identifies "orphan" resources.
  * `orphan:` wiki's "root" is the root of the filesystem (on systems having several non-united partitions, there may be the need to have several `orphan:` schemes, one for each partition).
  * **W** links between orphans can be done with relative paths and _no scheme_ (therefore resulting in a relative target address in HTML)
  * "interwiki" links to or from orphan files are done with absolute paths (and `file:` protocol), similarly to **L** **O** links, but with extension managment.
  * specifically, **W** links from regular wiki files to orphans must be done with absolute path, as in `orphan:/abs_path/orphanwiki`
All the above assumes that for orphans, the HTML file gets generated in the same directory where the orphan lives (since trying to place all of them in some `orphan_html` directory runs into the non-unique names problem). Another name for the scheme could be `root:` (but it could likely cause confusion with the (much more important) "root" of each wikifile directory, and not convey the fact that these wikifiles are the irregular kind).

Examples of **W** links:
  * from an orphan wiki file:
    1. `[[relpath/wikifile]]` links to another orphan wikifile (in HTML: the target is relative `relpath/wikiname.html`)
    1. `[[wiki3:relpath/wikifile]]` links to a proper wikifile (in HTML: the target is absolute `file:///abs_path_to_html3/relpath/wikifile.html`)
  * from a proper wiki file to an orphan:
    1. `[[orphan:/abspath/orphanwiki]]`  (in HTML: the target is `file:///abspath/orphanwiki.html`)
    1. BAD example: `[[../../../orphanwiki]]` is not guaranteed to work, the processor treats it as a regular internal wiki link, generating the relative target `../../../orphanwiki.html` (which may happen to work, but that should be considered just an accident)

### Media (or public) files on a webserver ###

When using vimwiki locally, there is no problem with links of all kinds in HTML versions. When moving the HTML files to a "production" webserver, all the `file:///` links either break or are no longer useful. This is to be expected (there is an important difference between **L** and **U**, after all), but is inconvenient if _some_ of the local non-wiki files referenced from wiki files were media or other files that were intended to be moved to the webserver as well (and in moving them, de facto changing them from **L** to **U** resources, making them "public").

There is a way to make it work (both in local and webserver copies) without regenerating all the HTML files.
The solution is clear: such "movable" local files have to be distinguished from the normal local files (which will never make it into the **U** zone) using a suitable scheme, just like in large wikis that use `media:` or `attachment:` "schemes" for wiki-internal (but non-wiki file type) resources that will be online.

To make the `media:` links survive the move, i.e. be functional both in the local version and the webserver copy (assuming the user takes care of copying over the actual media into the correct relative position on the webserver), the html generator would have to make targets for these resources relative. Assuming the simplification of html directory configuration has been done as suggested above, the most natural "root" directory for ("movable", or think of it as "public") media would be the main html path (or a subdirectory there, hopefully not having the same name as one of the wikis). This, among other things, allows sharing the media files between different wikis, and also make the "movable" local files clearly separated from local-but-never-intended-to-be-online resources.

Note the difference: the relative paths in `media:` are relative to the "root" media directory (which ought to be somewhere inside the main html directory), while for `loc:` it is relative to the current position. This difference is pretty much natural due to the nature of difference of "movable" (**L** now but soon-to-be **U** resources) and really local (private) resources. Besides, the name `loc:` hints very strongly at this distinction. And there is only one clearly specified directory that the user has to remember to copy over to the webserver (if `media` is inside the main html directory, one simply moves/copies that main directory, and all wikis become public, with all "public" links functional; it cannot possibly be simpler).

Example: assuming we are in the wikifile `wiki3:trips2005/France`, the media "root" is `/abspath_to_main_html_dir/media`, and using Variant A syntax.
  1. `{{loc:images/imagefile.jpeg| Eiffel Tower at night}}`  the HTML target is absolute `file:///abs_path_to_wiki3/trips2005/images/imagefile.jpeg`  (and the inline link will be unlikely to remain functional after any move to the **U** zone, it is a "private" resource)
  1. `{{media:France2005/imagefile.jpeg| Eiffel Tower at night}}` the HTML target is relative `rel_path_to_wiki3/../media/France2005/imagefile.jpeg` where `rel_path_to_wiki3` is simple `..` here (going from `trips2005` subwiki to the "root" of html for wiki3) , `rel_path_to_wiki3/..` goes to the main html directory; provided the `media/` is in the expected location on the webserver, this image would be shown even when looking at the generated file over http:

Note:
  * it is doubtful that vimwiki would be used in it present state for this kind of workflow, but it is a useful consideration anyway
  * the distinction between "private" and "media" (i.e. possibly public) local resources is necessary in order to consider a sensible conversion between different wiki formats (the established "public" wiki formats deal only with "media" resources, since "private" ones are of interest to "private" wikis only).
  * using symlinks in the local filesystem (from individual wiki directories, to the "media" directory) would allow to make `loc:` refer to the shared media files, but does not solve the problem of having "movable" html output, and (the necessary) clear separation between "private" and "public".
  * note that if Variant B syntax was used, one ought to declare whether the `media:` resources are more like the **W** type (to be used with `[[...]]`) or they are more like the **O** type (to be used with `[...]`) (assuming we are talking about **R**-linking), or whether both styles should be permitted; Variant A has no such problem, thus making it easier to learn (there is no decision to be taken there, a decision that which some users could find non-intuitive)

### Summary ###
All the problems can be satisfactorily resolved, making it possible to freely link between subwikis, different wikis, even orphan wikis, while keeping the processing fast and efficient, with no need to parse the individual paths. It is possible to make the syntactic rules both simple and consistent, therefore very easy to learn. But it is necessary to rationalize the configuration of HTML directories (with the current setup, vimwiki can be a "personal" wiki only). One can then end up with a design that is usable both as a personal (private) wiki (allowing one to easily reference local files) and as a normal (public) wiki, with no need to reconfigure or modify the actual HTML generator depending on the use case.


