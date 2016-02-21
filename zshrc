HISTFILE=~/.histfile
HISTSIZE=100000
SAVEHIST=100000
setopt hist_ignore_all_dups hist_ignore_space
bindkey -v
export KEYTIMEOUT=1

zstyle :compinstall filename '/home/andrew/.zshrc'

autoload -Uz compinit
compinit

fpath=(~/dev/scripts/zsh/funcs $fpath)

# autoload all executable scripts
if [[ -d ~/dev/scripts/zsh/funcs ]]
then
    for func in ~/dev/scripts/zsh/funcs/*(N-.x:t); do
        unhash -f $func 2>/dev/null
        autoload +X $func
    done
fi

#
# prompt
#
autoload -U colors
colors

PROMPT="%n@%m:%d%(1j. [%{$fg_bold[red]%}%j%{$reset_color%}].)%(?.. (%{$fg_bold[red]%}%?%{$reset_color%}%))
%(?..%{$fg_bold[red]%})%(!.>>.>) %{$reset_color%}"
RPROMPT=""

function zle-line-init zle-keymap-select {
    VIM_PROMPT="%{$fg_bold[yellow]%} [% EDIT]%  %{$reset_color%}"
    RPROMPT="${${KEYMAP/vicmd/$VIM_PROMPT}/(main|viins)/} $EPS1"
    zle reset-prompt
}

zle -N zle-line-init
zle -N zle-keymap-select

autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search # Up
bindkey "^[[B" down-line-or-beginning-search # Dow

bindkey '\e.' insert-last-word

#
# aliases
#
alias bt=transmission-remote
alias btc=bitcoin-cli
alias j=jobs
alias ll='ls -laFo'
