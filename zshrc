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

autoload -U colors
colors

autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr "$fg[green]S"
zstyle ':vcs_info:git:*' unstagedstr "$fg[yellow]U"
#zstyle ':vcs_info:*' nvcsformats 'non-git '
zstyle ':vcs_info:git:*' formats "%r/%S %b %m%u%c "

setopt prompt_subst

precmd() {
    vcs_info
    local prefix

    prefix="%n@%{$fg[red]%}%m%{$reset_color%}:"
    suffix="%{$reset_color%}%(1j. [%{$fg[red]%}%j%{$reset_color%}].)%(?.. (%{$fg[red]%}%?%{$reset_color%}%))
%(?..%{$fg[red]%})%(!.>>.>) %{$reset_color%}"

    if [[ -n ${vcs_info_msg_0_} ]]
    then
        PROMPT="$prefix${vcs_info_msg_0_}$suffix"
    else
        PROMPT="$prefix%~$suffix"
    fi
}
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

# auto-escape shell characters such as '&' and '!'
autoload -U url-quote-magic
zle -N self-insert url-quote-magic

#
# aliases
#
alias bt=transmission-remote
alias btc=bitcoin-cli
alias j=jobs
alias ll='ls -laFo'
