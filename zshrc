# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt hist_ignore_all_dups hist_ignore_space
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/andrew/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

#
# prompt
#
autoload -U colors
colors
PROMPT="%d%(1j. [%{$fg_bold[red]%}%j%{$reset_color%}].)%(?.. (%{$fg_bold[red]%}%?%{$reset_color%}%))
%(?..%{$fg_bold[red]%})%(!.>>.>) %{$reset_color%}"
RPROMPT=""

#
# aliases
#
alias bt=transmission-remote
alias btc=bitcoin-cli
alias j=jobs
alias irssi='irssi --hostname="0x666.tk"'
alias ll='ls -laFo'
