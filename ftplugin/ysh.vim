" Vim filetype plugin file
" Language:    YSH
" Maintainer:  sj2tpgk
" URL:         https://github.com/sj2tpgk/vim-oil

" Derived from ftplugin/csh.vim

if exists("b:did_ftplugin") | finish | endif
let b:did_ftplugin = 1

let s:save_cpo = &cpo
set cpo-=C

setl comments=:#
setl commentstring=#%s
setl formatoptions-=t
setl formatoptions+=rol

let b:undo_ftplugin = "setl comments< commentstring< formatoptions<"

if exists("loaded_matchit") && !exists("b:match_words")
    let b:match_words = ''
    let b:undo_ftplugin ..= " | unlet b:match_words"
endif

setl omnifunc=syntaxcomplete#Complete

if (has("gui_win32") || has("gui_gtk")) && !exists("b:browsefilter")
  let  b:browsefilter="YSH (*.ysh)\t*.ysh\n" ..
	\	      "All Files (*.*)\t*.*\n"
  let b:undo_ftplugin ..= " | unlet b:browsefilter"
endif

let &cpo = s:save_cpo
unlet s:save_cpo
