au BufRead,BufNewFile *.ysh	set filetype=ysh
au BufRead,BufNewFile *     if getline(1) =~ '^#!\(/usr/bin/env ysh\|/bin/ysh\)' | set filetype=ysh | endif
