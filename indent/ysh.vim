" Vim indent file
" Language:    YSH
" Maintainer:  sj2tpgk
" URL:         https://github.com/sj2tpgk/vim-oil

" Derived from indent/sh.vim


if exists("b:did_indent") | finish | endif
let b:did_indent = 1

" Set indentexpt
setl indentexpr=GetOilIndent()

" Options for cindent()
setl cinoptions<       " clear
setl cinoptions+=j1,J1 " dict (tell cindent() not to confuse "prop: val" with labels)
setl cinoptions+=#1,P0 " # is not preprocessor lines; so allow right-shifting them

" cinkeys and indentkeys also must be modified
setl cinkeys<
setl cinkeys-=:                  " don't trigger indent with :
setl cinkeys-=0#                 " don't put # at column 1
setl cinkeys+==fi,=esac,=done    " reindent when those keywords are typed
setl indentkeys<
setl indentkeys-=:               " same
setl indentkeys-=0#              " same
setl indentkeys+==fi,=esac,=done " same

" misc
setl smartindent

let b:undo_indent = 'setl indentexpr< indentkeys< smartindent<'

if exists("*GetOilIndent") | finish | endif

let s:cpo_save = &cpo
set cpo&vim


" ===== Helpers =====

fu! s:HasSyntaxAt(lnum, col, item)
    " Check if (lnum, col) has given syntax item
    return join(map(synstack(a:lnum, a:col), "synIDattr(v:val, 'name')"), " ") =~ a:item
endfu

fu! s:GetlineStripCommentTrim(lnum)
    " Example: "command 'a#c' # comment" ==> "command 'a#c'"
    let line = getline(a:lnum)
    let i    = stridx(line, "#", 0) " Note: string index is one less than corresponding column number

    while 1

        if i == -1
            " No '#' found
            let commentStripped = line
            break
        endif

        if s:HasSyntaxAt(a:lnum, i+1, "oilComment")
            " Found '#' and it starts a comment (not in string etc.)
            let commentStripped = i == 0 ? "" : line[:i-1]
            break
        endif

        let i = stridx(line, "#", i+1)

    endwh

    return substitute(commentStripped, '\s*$', "", "")
endfu

fu! s:IsOpening(lnum)
    " TODO not to be confused by "{" in string
    return s:GetlineStripCommentTrim(a:lnum) =~ '.*[{][^}]*$'
endfu

fu! s:IsContinuing(lnum)
    " Check if line {lnum} ends with a pipe (|) or backshash (\)
    return s:GetlineStripCommentTrim(a:lnum) =~ '.*[|\\]$'
endfu

fu! s:IsDictProp(lnum)
    return getline(a:lnum) =~ '^\s*[a-zA-Z0-9_]*:'
endfu

fu! s:IsMultiStringAt(lnum)
    " Check if column 1 of a line is in a multiline string
    return s:HasSyntaxAt(a:lnum, 1, "oilStringM")
endfu

fu! s:IsCaseClauseStart(lnum)
    " Check current line starts with case pattern "(pat)"
    return s:HasSyntaxAt(a:lnum, indent(a:lnum), "oilCasePatParen")
endfu

fu! s:IsInCaseClause(lnum)
    " Check current line is in a case clause (from "(pat)" to ";;")
    return s:HasSyntaxAt(a:lnum, 1, "oilCaseClause")
endfu

fu! s:PrevNonBlankNonContinued(lnum)
    " Return the line number of the first line at or above {lnum}
    " that is not blank and not continued (i.e. with pipe or backshash).
    let ans = prevnonblank(a:lnum)
    while ans > 0 && s:IsContinuing(prevnonblank(ans - 1))
        let ans = prevnonblank(ans - 1)
    endwh
    return ans
endfu


" ===== Main =====

fu! GetOilIndent(debug=0)

    " Mostly same as cindent(), but handle pipes, multiline strings etc.

    let lnum              = a:debug ? line(".") : v:lnum
    let lnumP             = prevnonblank(lnum - 1)
    let lnumPNonContinued = s:PrevNonBlankNonContinued(lnum - 1)
    let indeP             = indent(lnumP)
    let indePNonContinued = indent(lnumPNonContinued)
    let cin               = cindent(lnum)

    if a:debug | echo [[lnumP, lnumPNonContinued], cin, s:IsContinuing(lnum) ? "Cont" : "", s:IsOpening(lnum) ? "Open" : "", s:IsDictProp(lnum) ? "DictProp" : "", s:IsCaseClauseStart(lnum) ? "CaseStart" : "", s:GetlineStripCommentTrim(lnum)] | endif

    " First line: zero indent
    if lnum == 0 | return 0 | endif

    " Inside multiline string: keep current indent
    if s:IsMultiStringAt(lnum) | return -1 | endif

    " Line after pipe or continued statement
    if s:IsContinuing(lnumP) | return indePNonContinued + &sw | endif

    " Case clause: increase indent
    if s:IsCaseClauseStart(lnumPNonContinued) && s:IsInCaseClause(lnum) | let cin += &sw | endif

    " Line after [line after pipe or continued statement]
    if lnumP > lnumPNonContinued
        if cin < indePNonContinued | return cin | endif
        return cin - &sw
    endif

    " Second or later statements in block (cindent() tries to indent after semicolon-less line.)
    if cin > indeP && (!s:IsOpening(lnumP)) | return cin - &sw | endif

    " TODO: Line after multiline string: same indent as the start of the multiline string
    " this impl is incorrect (on block closing)
    " if s:IsMultiStringAt(lnumPNonContinued)
    "     let l1 = s:PrevNonBlankNonContinued(lnumPNonContinued - 1)
    "     while s:IsMultiStringAt(l1) && l1 > 0 | let l1 = s:PrevNonBlankNonContinued(l1 - 1) | endwh
    "     return indent(l1)
    " endif

    " Sh-style blocks (e.g. if/then/elif/else/fi, case/in/esac, for/while/do/done)
    " simple approximation
    if s:GetlineStripCommentTrim(lnumPNonContinued) =~ '^\s*\(\(if\|elif\)\>.*\<then\|then\|else\|case\>.*\<in\|in\|\(for\|while\)\>.*\<do\|do\)$'
        let cin += &sw
    elseif s:GetlineStripCommentTrim(lnum) =~ '^\s*\(elif\|else\|fi\|esac\|done\)$'
        let cin -= &sw
    endif

    " Fallback
    return cin

endfu


let &cpo = s:cpo_save
unlet s:cpo_save

