au BufRead,BufNewFile *.oil	set filetype=oil
au BufRead,BufNewFile *     if getline(1) =~ '^#!\(/usr/bin/env oil\|/bin/oil\)' | set filetype=oil | endif
