# Barebone link HTML export #
There is bug I don't know how to fix yet. Imagine a line with a barebone link and < in the end of it that is not a part of the link:
```
http://helloworld.com/articles/index.html<
```
Current vimwiki to HTML converter converts it wrong making
```
<a href="http://helloworld.com/articles/index.html&lt;">http://helloworld.com/articles/index.html&lt;</a>
```
instead of
```
<a href="http://helloworld.com/articles/index.html">http://helloworld.com/articles/index.html</a>&lt;
```