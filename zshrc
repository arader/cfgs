# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/andrew/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall
autoload -U colors
colors
PROMPT="%{$fg_bold[black]%}%d
%{$fg_bold[black]%}[%{$fg_no_bold[red]%}%!%(?.. %{$fg_bold[red]%}(%?%))%{$fg_bold[black]%}] %{$fg_bold[black]%}%(1j.%%.)%# %{$reset_color%}"
RPROMPT=""
