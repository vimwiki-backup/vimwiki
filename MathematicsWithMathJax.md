# Introduction #

Vimwiki currently supports mathematical syntax by default. This includes formulae, variables, etc. As the name suggests, this support is based on the powerful Javascript environment [MathJax](http://www.mathjax.org).

# Installation #
In order to make these features work, you have to follows a few simple steps:
  1. add a line to your Vimwiki HTML template;
  1. (optional) install MathJax locally for faster execution.

## Custom HTML template ##
Add **one** of the following lines to the header of your custom vimwiki HTML template.
  * **Easiest**: using the online MathJax engine:
```
<script type="text/javascript" src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML"></script>
```
The drawback is that you have to be online to see your math.

  * **Faster**: using a local MathJax copy:
```
<script type="text/javascript" src="mathjax/MathJax.js?config=TeX-AMS-MML_HTMLorMML"></script>
```
In this last case, you have to install a local copy of MathJax. Using the line above, it is stored under subfolder called "mathjax" of your main HTML wiki folder.

**Note**: your mathjax engine can actually reside wherever you can reach it; change the path in your HTML header accordingly.

# Use #
Currently, you can call three types of mathematical syntaxes:
  * **inline math**: use $ (dollar sign) to enclose your inline mathematics, e.g.:
```
The euclidean plane usually has $x$ and $ y $ as standard variables.
```
  * **block displaymath**: use `{{$` and `}}$` to enclose a displaymath environment. _The opening syntax must be on a single line, as the closing one. The contents are to be written on one or more lines in-between_, e.g.:
```
text text
{{$
\sum_{i=1}^N a_i^2 = \infty
}}$
text text
```
  * **block environments**: other block environments are supported in addition to displaymath. These include gather, align, cases, etc.. To use them, use %% placeholders after {{$ when you open your math block, e.g.:
```
{{$%equation*%
bla bla
}}$
```

Vimwiki and MathJax are smart enough to allow for whitespaces at the beginning or end of the line. However, their use is discouraged.

**Note**: block environments are mostly used for writing several lines of math after one another. This can be obtained e.g. via the align LaTeX environment:
```
{{$%align%
formula1 &= result1 \\
formula2 &= result2
}}$
```