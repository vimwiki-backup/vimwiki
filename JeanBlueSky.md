# Introduction #

Just some ideas for building on vimwiki. I'll flesh this out as I do some more thinking.

# Details #

  * GettingThingsDoneWithVimwiki
  * TimeTrackingWithVimwiki

## Navigation ##

  * Make mappings operate in the **current** wiki by default. I.e. you can do `2\w\w` to go to the 2nd wiki's diary, but as long as you're in that wiki, `\w\w` will take you to that diary. Do `1\w\w` or `1\ww` to go back to the first wiki.

## Bookmarking ##
  * Write bookmarks in a structured format (reStructuredText data blocks?  YAML?) and parse them out of the wikis;
  * Sync them to Ubuntu One as part of Firefox bookmarks somehow.
  * Sync them to del.icio.us?

## Structured data ##
  * Bookmarks are just one example of this. Contact information (business cards), any kind of inventory ..
  * See https://github.com/mojombo/jekyll/wiki/YAML-Front-Matter

## Integration ##
  * Integrate with catch.com, because I take notes on my phone using the Catch Android app .. I want my catch notes to be a wiki of their own. Bidirectional sync. If catch can sync to file, that would work.
  * Integrate with PanDoc publishing tool.