# GettingThingsDone with vimwiki #

  * Write pages that work with text-based todo tools (e.g. http://TodoTxt.com).

OR

  * Figure out how to grab TODO markers from wiki pages and do something useful with them.
    * E.g. copy them all to today's page or to a `TodoYYYMMDD` page, where you can arrange them as you like. Generate a fresh todolist page tomorrow. The old one is history or can be deleted.
    * When creating the todolist, set a marker on the copied chunk in the source page (e.g. if you had `TODO: sometask` change that to `TODO(YYYMMDD-t1): sometask`.  The number corresponds to a number in the todolist page. Don't change this number. The todo list may look like:

<pre>
# [ ](WikiPage#t1) this task<br>
# ![[X]](OtherPage#t3) other task (I moved this one up.)<br>
# [ ](BigEssay#t2) big task<br>
</pre>

> (For the motivation for `name#tn` see UtlStyleLinks.)
> When marking an item done, the original is changed to `DONE(YYYMMDD-1):`. When marking an item un-done, it is changed back to TODO.
  * If you generate a todolist, the dates and numbers on all `TODO(YYYMMDD-1):` stamps are updated (to the current time; counting from 1 again).
  * Should todolists be only per wiki? Or across wikis? I think one per wiki, otherwise we'll get a lot of unrelated tasks mixed up.