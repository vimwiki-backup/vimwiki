# Introduction #

Implement an easy, non-intrusive way of tracking your time while using Vim.

What's special about this time tracking tool?

  1. My life is already in Vim, I don't want to switch to a different tool to do my time tracking.
  1. I'm not a robot: sometimes I log things late, or change my mind about how things are named. So I want a tool where I can easily munge things afterwards.
  1. I don't want my time log to live on someone else's servers, in some database format.
  1. I want my log lines to have rich context. I want to be able to annotate it, and log lines should automatically link detailed work pages.

# Time Tracking With Vimwiki #

On any page, hit `\ll` to log that line. If you're in a wiki, the line is
logged with the wiki name as prefix. If you're on a file, the line is logged
with the absolute filename as prefix.

By default, lines are logged to today's page in the default wiki's diary.
The rationale for this is that personally you live only one timeline, so to
give a realistic picture of what you did, all times need to be logged in one
place.

If you use a wiki per project or per context, the logged lines will be
categorized in the report, keeping projects together.

In general, follow GTimeLog's practice. See: http://mg.pov.lt/gtimelog/

## Generating reports ##

Append all the diary pages you're interested in to `~/.gtimelog/timelog.txt` and
use gtimelog's reporting functionality. For example, to copy this month's pages:

```
$ cat wiki/diary/2011-04-*.wiki >> ~/.gtimelog/timelog.txt
```

Gtimelog only looks at timestamped lines so don't worry about extra text in your pages.

# Example #

  * I type `\w\w` to go to today's page, and type the word "Arrived". I hit `\ll` to log that line, which results in: `2011-01-01 09:14: Arrived` being added to page `[[2011-01-01]]`
  * I go to page `projectname/FeatureX` and write "Working on [bug #123](https://code.google.com/p/vimwiki/issues/detail?id=123)". I go on working and making notes. Finally I log that line at 09:44.
  * At 10:04 I log "Coffee xx" on today's page.
  * At 10:36 I log "Working on [bug #123](https://code.google.com/p/vimwiki/issues/detail?id=123)" on page `projectname/DatabaseConfig`.
  * At 12:32 I log "Writing terms of reference" on page `projectname/HiringOpsTeam`.

In the meantime, I updated `holiday/HotelsOnIsland` and `holiday/PlacesToSee`.

This could result in a `2011-01-01` page like the following (non-matching
lines are ignored):

```
Hmm today's going to be a long day ..

2011-01-01 09:14: Arrived

Something to remember, last night I went to see !SomeMovie with !SomeFriend and
they said it reminded them of bla bla. 

2011-01-01 09:16: !SomeMovie xx

  I hit enter on !SomeMovie to create the page and added a note. When I saved
  it added the previous line. Note that I added the "xx" after the fact, to
  show that it's not work-time. (For xx read asterisk-asterisk. Logs like
  these are not counted as work, but do show up in a work/slacking report.)

2011-01-01 09:44: projectname: !FeatureX: Working on bug #123

  * remember to look at mailinglist in a while
  * blabla

2011-01-01 10:04: Coffee xx
2011-01-01 10:10: projectname: !HiringOpsTeam
2011-01-01 10:14: holiday: !HotelsOnIsland
2011-01-01 10:36: projectname: !DatabaseConfig: Working on bug #123
2011-01-01 10:40: projectname: !HiringOpsTeam
2011-01-01 10:54: holiday: !PlacesToSee

  Here you can see I was getting a bit distracted thinking about my holiday:
  I started to write some terms of reference, but broke away to update some
  holiday notes.

2011-01-01 12:32: projectname: !HiringOpsTeam: Writing terms of reference
```

Out-of-order timestamps won't matter, they're sorted before reporting.

From the above page, GTimeLog creates the following report:

```
To: activity-list@example.com
Subject: Monthly report for Anonymous (2011/01)

                                                                time
Holiday: !HotelsOnIsland                                         4 min
Holiday: !PlacesToSee                                            14 min
Projectname: !DatabaseConfig: Working on bug #123                22 min
Projectname: !FeatureX: Working on bug #123                      30 min
Projectname: !HiringOpsTeam                                      10 min
Projectname: !HiringOpsTeam: Writing terms of reference          1 hour 38 min

Total work done this month: 2 hours 58 min

By category:

holiday                                                         18 min
projectname                                                     2 hours 40 min
```

This approach could be used independently of GTimeLog, or timestamps could be
parsed from diary pages and concatenated with GTimeLog's `gtimelog.txt` file.
This would allow you to use GTimeLog's GUI if you prefer.

See
http://bazaar.launchpad.net/~gtimelog-dev/gtimelog/trunk/view/head:/README.txt
for some more sweet things about the GTimeLog file format and reporting.