set nocompatible

" set the file encoding order
set fencs=ucs-bom,utf-8,default,latin1,ucs-2le

" allow modified buffers to be kept off screen
set hidden

" allow backups over everything
set backspace=indent,eol,start

" show the cursor position at all times
set ruler

" start showing search results as soon as you start typing
set incsearch

" enable highlighting of search text
set hlsearch

" show line numbers
set number

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
map <F11> :simalt~x<CR>

" set up the Vundle Plugins
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" Rust file handling
Plugin 'rust-lang/rust.vim'

" All of your Plugins must be added before the following line
call vundle#end()

" enable filetype detection and do lang-based indenting
filetype plugin indent on

syntax on
set background=dark

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
