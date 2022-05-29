#!/bin/sh

# "./test.sh" to test nvim, "./test.sh x" to test vim
[ -n "$1" ] && vim=vim || vim=nvim
d=$(dirname "$0")
cd "$d" && $vim -u vimrc -o test.oil shebang

