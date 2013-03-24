#!/bin/bash

#
# This script converts gitit's into html, to be used with vimwiki's
# "customwiki2html" option.
#
# To use this script, you must have the Pandoc installed.
#
#   http://johnmacfarlane.net/pandoc/
#
# To verify your installation, check that the commands pandoc,
# is on your path.
#
# Also verify that this file is executable.
#
# Then, in your .vimrc file, set:
#
#   g:vimwiki_customwiki2html=$HOME.'/.vim/autoload/vimwiki/gitit2html.sh'
#
# On your next restart, Vimwiki will run this script instead of using the
# internal wiki2html converter.
#

PANDOC=pandoc

FORCE="$1"
SYNTAX="$2"
EXTENSION="$3"
OUTPUTDIR="$4"
INPUT="$5"
CSSFILE="$6"

FORCEFLAG=

[ $FORCE -eq 0 ] || { FORCEFLAG="-f"; };
[ $SYNTAX = "pandoc" ] || { echo "Error: Unsupported syntax"; exit -2; };

OUTPUT="$OUTPUTDIR"/$(basename "$INPUT" .$EXTENSION).html

VALID_CHARS='[^][\\]'  # ']' must be the first character in the '[...]' or '[^...]
FILENAME_CHARS='[^][\\#]'  # ']' must be the first character in the '[...]' or '[^...]
PROTOCOLS='https:\/\/\|http:\/\/\|www.\|ftp:\/\/\|file:\/\/\|mailto:'
SED_CMD1="s/\[\($VALID_CHARS\+\)\]()/[\1](\1)/g"
SED_CMD2="s/\[\($VALID_CHARS\+\)\](\($FILENAME_CHARS\+\)\(#$VALID_CHARS\+\)\?)/[\1](\2.html\3)/g"
SED_CMD3="s/\[\($VALID_CHARS\+\)\](\($PROTOCOLS\)\($VALID_CHARS\+\)\.html\(#$VALID_CHARS\+\)\?)/[\1](\2\3\4)/g"

cat "$INPUT" | \
    sed "$SED_CMD1; $SED_CMD2; $SED_CMD3;" |
    "$PANDOC" -s -f markdown -t html -c "$CSSFILE" -o "$OUTPUT"

