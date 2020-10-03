" allow vimrc files in the working directory to be sourced, albeit securely
set exrc
set secure

" set the file encoding order
set fencs=ucs-bom,utf-8,default,latin1,ucs-2le

" allow modified buffers to be kept off screen
set hidden

" shouldn't be necessary to force this, buy YouCompleteMe lags my escape
set noesckeys

" always show just the menu (no popup, no preview) with completions
set completeopt=menuone

" allow backups over everything
set backspace=indent,eol,start

" always show status line
set laststatus=2

" show the sign column at all times to prevent text shifting
set signcolumn=yes

" show the cursor position at all times
set ruler

" start showing search results as soon as you start typing
set incsearch

" enable highlighting of search text
set hlsearch

" show the current line number on the line, but relative line number elsewhere
set number
set relativenumber

" further, actually highlight the current line number
set cursorlineopt=number
set cursorline

" extreme mode, highlight the current column too
set cursorcolumn

set fillchars+=vert:┆,stl:-

" when starting a new line, copy the indent of the previous line
set autoindent

" uses spaces for <TAB> key
set expandtab

" tabs should be 4 spaces long
set ts=4

" the number of chars to shift lines for indenting
set shiftwidth=4

" turn off word wrapping
set nowrap

" keep track of 150 commands
set history=150

" get rid of swp files
set nobackup
set nowritebackup

" map F11 to a 'go to fullscreen mode' shortcut
nnoremap <F11> :simalt~x<CR>

" map F12 to open file name under cursor
nnoremap <F12> gf

nnoremap <silent> ,<space> :nohlsearch<CR>

" set up the Vundle Plugins
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'ycm-core/YouCompleteMe'
Plugin 'rust-lang/rust.vim'
Plugin 'igankevich/mesonic'

" All of your Plugins must be added before the following line
call vundle#end()

" enable filetype detection and do lang-based indenting
filetype plugin indent on

function! GitBranch()
  return system("git rev-parse --abbrev-ref HEAD 2>/dev/null | tr -d '\n'")
endfunction

function! StatuslineGit()
  let l:branchname = GitBranch()
  return strlen(l:branchname) > 0?'  '.l:branchname.' ':''
endfunction

set statusline=
set statusline+=%#Normal#%{StatuslineGit()}
set statusline+=\ \ %#StatusLine#%(%f\ %m%r%)
set statusline+=\ %=
set statusline+=%#Normal#
set statusline+=\ %y
set statusline+=\ \[%{&fileencoding?&fileencoding:&encoding}\]
set statusline+=\ \[%{&fileformat}\]
set statusline+=\ %p%%
set statusline+=\ %l,%c
set statusline+=\ 

syntax on

set background=dark

highlight StatusLine cterm=NONE ctermbg=NONE ctermfg=YELLOW
highlight StatusLineNC cterm=NONE ctermbg=NONE ctermfg=20
highlight VertSplit cterm=NONE ctermbg=NONE ctermfg=19
highlight SignColumn ctermbg=NONE
highlight Error cterm=NONE ctermbg=NONE ctermfg=RED
highlight CursorLineNr ctermbg=NONE ctermfg=DARKBLUE cterm=NONE
highlight CursorColumn ctermbg=NONE cterm=BOLD
highlight ColorColumn cterm=UNDERLINE ctermbg=NONE ctermfg=RED
highlight YcmErrorSection ctermbg=NONE ctermfg=RED cterm=UNDERLINE

"sign define YcmError text=╏╏

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
