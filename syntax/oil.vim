" Vim syntax file
" Language:    Oil Shell
" Maintainer:  sj2tpgk
" URL:         https://github.com/sj2tpgk/vim-oil

" Derived from syntax/csh.vim, and technique borrowed from pangloss/vim-javascript

if exists("b:current_syntax") | finish | endif


" Helper commands {{{

" Usage: OilHiDefLink TO FROM1 FROM2 ...
"        same as "hi def link FROM1 TO" and "hi def link FROMN FROM1" for each N>=2
" Usage: OilHiDefLink TO @FROMCLUSTER
"        same as "OilHiDefLink TO FROM1 FROM2 ..." where FROM1 FROM2 ... are items
"        in the cluster FROMCLUSTER defined with OilSynCluster
command! -nargs=+ OilHiDefLink :call s:hiDefLink([<f-args>])
fu! s:hiDefLink(args)
    let a = a:args
    if a[1] =~ '^@'
        " a[0] is TO. a[1] is @FROMCLUSTER
        let cluster = substitute(a[1], '^@', '', '')
        if has_key(s:synClusters, cluster)
            call s:hiDefLink([a[0], cluster] + s:synClusters[cluster])
        else
            echoerr "No such cluster defined with OilSynCluster: " . cluster
        endif
    else
        " a[0] is TO. a[1] is FROM1. a[2:] is [FROM2,...]
        exe "hi def link " . a[1] . " " . a[0]
        for from in a[2:] | exe "hi def link " . from . " " . a[1] | endfor
    endif
endfu

" Usage: OilSynCluster NAME ITEM1 ITEM2 ...
"        same as "syn cluster NAME contains=ITEM1,ITEM2,..."
"        but remembers the cluster so it can be referenced in "OilHiDefLink TO @NAME"
command! -nargs=+ OilSynCluster :call s:synCluster([<f-args>])
let s:synClusters = {}
fu! s:synCluster(args)
    let s:synClusters[a:args[0]] = a:args[1:]
    exe "syn cluster " . a:args[0] . " contains=" . join(a:args[1:], ',')
endfu

" }}}


" ===== Keywords ===== {{{
" Note: keywords inside expression modes are defined later.
" keywords
syn keyword oilKwd        break class continue data do done enum esac exit fi func function import in return then time until
syn keyword oilKwd        skipwhite nextgroup=oilProcName proc
syn keyword oilKwdCond    skipwhite nextgroup=oilCaseStart     case
syn keyword oilKwdCond    else
" keywords that (may) sta expression mode
syn keyword oilKwdCond    skipwhite nextgroup=oilParenExprWrap if elif
syn keyword oilKwdRepeat  skipwhite nextgroup=oilParenExprWrap for while
syn keyword oilKwdAssign  skipwhite nextgroup=oilAssignVar     var const setvar setglobal setref
" shopt (extracted from oil/frontend/option_def.py)
syn match   oilShoptFlagS contained skipwhite nextgroup=oilShoptOptS +-\(s\|set\)+
syn match   oilShoptFlagU contained skipwhite nextgroup=oilShoptOptU +-\(u\|unset\)+
syn keyword oilShoptOptS  contained skipwhite nextgroup=oilShoptOptS
            \ allow_csub_psub assoc_expand_once autocd cdable_vars cdspell checkhash checkjobs checkwinsize cmdhist command_sub_errexit compat_array complete_fullquote dashglob direxpand dirspell dotglob dynamic_scope emacs errexit eval_unsafe_arith execfail expand_aliases extdebug extglob extquote failglob force_fignore globasciiranges globstar gnu_errfmt hashall histappend histreedit histverify hostcomplete huponexit inherit_errexit interactive interactive_comments lastpipe lithist localvar_inherit localvar_unset login_shell mailwarn nocaseglob nocasematch noclobber no_empty_cmd_completion noexec noglob nounset nullglob parse_amp parse_at parse_at_all parse_backslash parse_backticks parse_brace parse_dollar parse_dynamic_arith parse_equals parse_ignored parse_paren parse_raw_string parse_tea parse_triple_quote pipefail posix process_sub_fail progcomp progcomp_alias promptvars redefine_module redefine_proc restricted_shell _running_trap shift_verbose sigpipe_status_ok simple_echo simple_eval_builtin simple_test_builtin simple_word_eval sourcepath strict_argv strict_arith strict_array strict_control_flow strict_errexit strict_glob strict_nameref strict_tilde strict_word_eval verbose verbose_errexit vi xpg_echo xtrace xtrace_details xtrace_rich
syn keyword oilShoptOptU  contained skipwhite nextgroup=oilShoptOptU
            \ allow_csub_psub assoc_expand_once autocd cdable_vars cdspell checkhash checkjobs checkwinsize cmdhist command_sub_errexit compat_array complete_fullquote dashglob direxpand dirspell dotglob dynamic_scope emacs errexit eval_unsafe_arith execfail expand_aliases extdebug extglob extquote failglob force_fignore globasciiranges globstar gnu_errfmt hashall histappend histreedit histverify hostcomplete huponexit inherit_errexit interactive interactive_comments lastpipe lithist localvar_inherit localvar_unset login_shell mailwarn nocaseglob nocasematch noclobber no_empty_cmd_completion noexec noglob nounset nullglob parse_amp parse_at parse_at_all parse_backslash parse_backticks parse_brace parse_dollar parse_dynamic_arith parse_equals parse_ignored parse_paren parse_raw_string parse_tea parse_triple_quote pipefail posix process_sub_fail progcomp progcomp_alias promptvars redefine_module redefine_proc restricted_shell _running_trap shift_verbose sigpipe_status_ok simple_echo simple_eval_builtin simple_test_builtin simple_word_eval sourcepath strict_argv strict_arith strict_array strict_control_flow strict_errexit strict_glob strict_nameref strict_tilde strict_word_eval verbose verbose_errexit vi xpg_echo xtrace xtrace_details xtrace_rich
" builtins in command language
syn keyword oilBuiltin    set shift test
syn keyword oilBuiltin    alias append argparse bg bind boolstatus cd command compadjust compgen complete compopt describe dirs echo fg fopen fork forkwait getopts hash hay haynode help history jobs json mapfile module popd pp printf pushd pwd read readarray runproc shvar source type umask unalias use wait write
syn keyword oilBuiltin    skipwhite nextgroup=oilShoptFlag.* shopt
" todo keywords inside comments
syn keyword oilTodo       contained TODO FIXME NOTE
" }}}


" ===== String and escape sequences ====== {{{

" Strings (D means "",  S means '',  C means $'')
" note: later rules have higher priority
OilSynCluster oilStringList
            \ oilStringD oilStringS oilStringC oilStringMD oilStringMS oilStringMC
syn region  oilStringD    start=+\\\@1<!"+     skip=+\\\\\|\\"+ end=+"+   contains=oilEscapeD,oilEscapeDE,oilVar,oilCommandSub,oilBracketExprWrap,oilExprWrapExprSubE
syn region  oilStringS    start=+\\\@1<!'+                      end=+'+
syn region  oilStringC    start=+\\\@1<![$c]'+ skip=+\\\\\|\\'+ end=+'+   contains=oilEscapeC,oilEscapeCE
syn region  oilStringMD   start=+"""+                           end=+"""+ contains=oilEscapeD,oilEscapeDE,oilVar,oilCommandSub,oilBracketExprWrap,oilExprWrapExprSubE
syn region  oilStringMS   start=+'''+                           end=+'''+
syn region  oilStringMC   start=+[$c]'''+                       end=+'''+ contains=oilEscapeC,oilEscapeCE

" Escape sequences
OilSynCluster oilEscapeList  oilEscapeD  oilEscapeC
OilSynCluster oilEscapeEList oilEscapeDE oilEscapeCE
syn match oilEscapeD  contained +\\[$"\\]+
syn match oilEscapeDE contained +\\\(x\d\{2}\|u\d\{4}\|[xu]{\d*}\|[a-zA-Z0-9']\)+    " invalid sequences in double quotes
syn match oilEscapeC  contained +\\\(x\d\{2}\|u\d\{4}\|[xu]{\d*}\|[a-zA-Z0-9"\\']\)+
syn match oilEscapeCE contained +\\[$]+                                              " invalid sequences in C-style strings

" }}}


" ===== Parens, braces and brackets ===== {{{
OilSynCluster oilParenList
            \ oilParen oilBrace oilBracket oilParenExprWrap oilBraceCase oilParenExprWrap

syn region oilParen                     matchgroup=oilDelim        start=+(+    end=+)+  contains=TOP
syn region oilBrace                     matchgroup=oilDelim        start=+{+    end=+}+  contains=TOP
syn region oilBracket                   matchgroup=oilDelim        start=+\[+   end=+\]+ contains=TOP

" if (expr)
syn region oilParenExprWrap   contained matchgroup=oilExprWrapList start=+(+    end=+)+  contains=@oilExpr_List

" invalid paren usage (like $func(arg) inside double quotes)
syn region oilParenExprWrapE  contained matchgroup=Error           start=+(+    end=+)+  contains=oilParenExprWrapE

" $(cmd)
syn region oilParenCommandSub contained matchgroup=oilCommandSub   start=+(+    end=+)+  contains=TOP

" pattrens in case block
syn region oilParenCasePat    contained matchgroup=oilParenCasePat start=+(+    end=+)+  nextgroup=oilCaseClauseBody skipwhite skipempty

" case { }
syn region oilBraceCase       contained matchgroup=oilDelim        start=+{+    end=+}+  contains=oilCaseClause

" $[expr]
syn region oilBracketExprWrap contained matchgroup=oilExprWrapList start=+\$\[+ end=+\]+ contains=@oilExpr_List

" }}}


" ===== Expression mode wrappers ===== {{{
OilSynCluster oilExprWrapList
            \ oilParenExprWrap oilExprWrapExprSub oilBracketExprWrap oilExprWrapAssign oilExprWrapPPrint
OilSynCluster oilExprWrapEList
            \ oilParenExprWrapE oilExprWrapExprSubE

" $func(args) (expression substitution)
syn match  oilExprWrapExprSub  +\$[a-zA-Z_][a-zA-Z_0-9]*\>\ze(+ nextgroup=oilParenExprWrap

" $func(args) inside double quotes is error
syn match  oilExprWrapExprSubE +\$[a-zA-Z_][a-zA-Z_0-9]*\>\ze(+ nextgroup=oilParenExprWrapE contained

" var foo = expr
" TODO what if a dict or a multiline string is assigned
syn match  oilAssignVar       +\w\++        contained skipwhite skipempty nextgroup=oilAssignEqual
syn match  oilAssignEqual     +=+           contained skipwhite skipempty nextgroup=oilExprWrapAssign,oilVar,oilCommandSub
syn match  oilExprWrapAssign  +[^$"' ].*$+  contained contains=@oilExpr_List,oilComment

" = expr (at the beginning of line)
syn region oilExprWrapPPrint  start=+^\_s*=+ms=e+1 end=+$+ contains=@oilExpr_List,oilComment oneline

" }}}


" ===== Expression mode components ===== {{{
OilSynCluster oilExpr_List
            \ @oilStringList oilVariable oilParenExprWrap oilExpr_Eggex oilExpr_Op oilExpr_Function oilExpr_Constant

syn region  oilExpr_Eggex    contained start=+/+ skip=+\\\\\|\\/+ end=+/+ containedin=oilParenExprWrap,oilBracketExprWrap
syn keyword oilExpr_Op       contained and or not == ~
syn keyword oilExpr_Function contained abs len strip startswith tup _start _end _match
syn keyword oilExpr_Constant contained true false
" }}}


" ===== Misc ===== {{{

" Case block beginning   (that is, "$x" in "case $x { ... }")
syn match  oilCaseStart      contained skipwhite skipempty  +[^{]*+                  contains=TOP nextgroup=oilBraceCase
" Case block clause      (from "(pat)" to ";;")
syn region oilCaseClause     contained skipwhite skipempty start=+([^)]\+)+ end=+;;+ contains=oilParenCasePat keepend
" Case block clause body (after "(pat)" to ";;")
syn region oilCaseClauseBody contained skipwhite skipempty start=+.+ end=+;;+        contains=TOP

" Comment
syn match  oilComment    +\$\@1<!#.*$+ contains=oilTodo,@Spell " excluding $#

" Cluster for variable name
OilSynCluster oilVarList
            \ oilAssignVar oilAssignVar2 oilVar

" xxx=yyy (at line beginning)
syn match  oilAssignVar2 +^[a-zA-Z0-9]\+\ze\s*=+

" $var, ${var}, $#, @ary
syn match  oilVar        +\$[a-zA-Z_0-9]\+\>\ze\([^(]\|$\)+ " excluding $xx(yy) etc.
syn match  oilVar        +\${[a-zA-Z_0-9]\+}+
syn match  oilVar        +\$#+
syn match  oilVar        +@[a-zA-Z_0-9]\++

" $(cmd)
syn match  oilCommandSub +\$\ze(+ nextgroup=oilParenCommandSub

" "myproc" in "proc myproc()"
syn match  oilProcName   +[a-zA-Z_0-9]\++ contained

" func() { ... } (at line beginning)
syn match  oilFuncName   +^[a-zA-Z_0-9]\+\ze()+

" }}}


" Define the default highlighting {{{
if !exists("skip_oil_syntax_inits")

    " Keywords
    OilHiDefLink Keyword     oilKwd oilKwdAssign
    OilHiDefLink Conditional oilKwdCond
    OilHiDefLink Repeat      oilKwdRepeat
    OilHiDefLink Special     oilShoptFlagS oilShoptOptS
    OilHiDefLink Comment     oilShoptFlagU oilShoptOptU
    OilHiDefLink Statement   oilBuiltin
    OilHiDefLink Todo        oilTodo

    " Strings and escape sequences
    OilHiDefLink String      @oilStringList
    OilHiDefLink Special     @oilEscapeList
    OilHiDefLink Error       @oilEscapeEList

    " Expression wrapper
    OilHiDefLink Type        @oilExprWrapList
    OilHiDefLink Error       @oilExprWrapEList

    " Expression mode components
    OilHiDefLink String      oilExpr_Eggex
    OilHiDefLink Identifier  oilExpr_Op oilExpr_Function
    OilHiDefLink Constant    oilExpr_Constant

    " Variables (definitions and substitutions)
    OilHiDefLink Identifier  @oilVarList

    " Misc
    OilHiDefLink PreProc     oilCommandSub oilParenCommandSub
    OilHiDefLink Function    oilProcName oilFuncName
    OilHiDefLink Comment     oilComment

endif
" }}}


unlet s:synClusters
delcommand OilSynCluster
delcommand OilHiDefLink

let b:current_syntax = "oil"

