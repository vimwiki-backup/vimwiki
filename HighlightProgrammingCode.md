# I want to #
Highlight python code in html exported from vimwiki.

# Syntax highlighter #
  1. Get it from http://code.google.com/p/syntaxhighlighter/
  1. Unpack `scripts` and `styles` folders into `~/vimwiki_html/`.

# Set up vimwiki #
In a `.vimrc` add the following:
```
let g:vimwiki_list = [{'html_header': '~/vimwiki_html/header.tpl'}]
```

Create `~/vimwiki_html/header.tpl`:
```
<html>
  <head>
    <link type="text/css" rel="stylesheet" href="/styles/shCore.css" /> 
    <link type="text/css" rel="stylesheet" href="/styles/shThemeDefault.css" /> 
    <script type="text/javascript" src="/scripts/shCore.js"></script> 
    <script type="text/javascript" src="/scripts/shBrushPython.js"></script>
    <script type="text/javascript">
      SyntaxHighlighter.all();
    </script> 
  </head>
  <body>
```

# Highlight python code #
Open vimwiki's index file (or whatever) and add the following:

`{{{class="brush: python"`
```
class TestHelloWorld(object):
  """Hello world python."""
  def __init__(self, name):
    self.name = name

  def say(self):
    print("hello {0}".format(self.name))

```
`}}}`

Now execute `:Vimwiki2HTML` command.

Check the result.