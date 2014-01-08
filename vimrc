set nocompatible

" allow backups over everything
set backspace=indent,eol,start

" show the cursor position at all times
set ruler

" start showing search results as soon as you start typing
set incsearch

" enable highlighting of search text
set hlsearch

set autoindent
set expandtab
set ts=4
set shiftwidth=4
set nu
set fencs=ucs-bom,utf-8,default,latin1,ucs-2le

set wrap!

set nobackup
set nowritebackup

map <F11> :simalt~x<CR>

"set foldmethod=syntax

if has("gui_running")
    set mousehide
    set guioptions=egrLt
    set lines=70
    set columns=90
    set guifont=MonteCarlo
endif

set diffexpr=MyDiff()
function MyDiff()
  let opt = '-a --binary '
  if &diffopt =~ 'icase' | let opt = opt . '-i ' | endif
  if &diffopt =~ 'iwhite' | let opt = opt . '-b ' | endif
  let arg1 = v:fname_in
  if arg1 =~ ' ' | let arg1 = '"' . arg1 . '"' | endif
  let arg2 = v:fname_new
  if arg2 =~ ' ' | let arg2 = '"' . arg2 . '"' | endif
  let arg3 = v:fname_out
  if arg3 =~ ' ' | let arg3 = '"' . arg3 . '"' | endif
  let eq = ''
  if $VIMRUNTIME =~ ' '
    if &sh =~ '\<cmd'
      let cmd = '""' . $VIMRUNTIME . '\diff"'
      let eq = '"'
    else
      let cmd = substitute($VIMRUNTIME, ' ', '" ', '') . '\diff"'
    endif
  else
    let cmd = $VIMRUNTIME . '\diff'
  endif
  silent execute '!' . cmd . ' ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3 . eq
endfunction

" set up our theme

syntax on
syntax reset

set background=dark
hi clear

" Vim >= 7.0 specific colors
if version >= 700
  hi CursorLine     guibg=#2d2d2d
  hi CursorColumn   guibg=#2d2d2d
  hi MatchParen     ctermfg=0   guifg=#f6f3e8 guibg=#857b6f gui=bold
  hi Pmenu          guifg=#f6f3e8 guibg=#444444
  hi PmenuSel       guifg=#000000 guibg=#cae682
endif

" General colors
hi Cursor       cterm=none  guifg=NONE  guibg=#656565 gui=none
hi Normal       ctermfg=248 cterm=none  guifg=#f6f3e8 guibg=#242424 gui=none
hi NonText      cterm=none  guifg=#808080 guibg=#303030 gui=none
hi LineNr       ctermfg=238 cterm=none  guifg=#857b6f guibg=#000000 gui=none
hi StatusLine   cterm=none  guifg=#f6f3e8 guibg=#444444 gui=none
hi StatusLineNC cterm=none  guifg=#857b6f guibg=#444444 gui=none
hi VertSplit    ctermfg=209 cterm=none  guifg=#444444 guibg=#444444 gui=none
hi Folded       cterm=none  guibg=#384048 guifg=#a0a8b0 gui=none
hi Title        cterm=none  guifg=#f6f3e8 guibg=NONE    gui=bold
hi Visual       cterm=none  guifg=#f6f3e8 guibg=#444444 gui=none
hi SpecialKey   cterm=none  guifg=#808080 guibg=#343434 gui=none

" Syntax highlighting
hi Comment      ctermfg=242 guifg=#99968b gui=none
hi Todo         ctermfg=254 guifg=#8f8f8f gui=bold
hi Constant     ctermfg=167 guifg=#e5786d gui=none
hi String       ctermfg=167 guifg=#e5786d gui=none
hi Identifier   ctermfg=114 guifg=#cae682 gui=none
hi Function     ctermfg=114 guifg=#cae682 gui=none
hi Type         ctermfg=114 guifg=#cae682 gui=none
hi Statement    ctermfg=37  guifg=#8ac6f2 gui=none
hi Keyword      ctermfg=37  guifg=#8ac6f2 gui=none
hi PreProc      ctermfg=167 guifg=#e5786d gui=none
hi Number       ctermfg=167 guifg=#e5786d gui=none
hi Special      ctermfg=80  guifg=#e7f6da gui=none
