# Store the current hostname or 'unknown' if we can't
# get one for some crazy reason
HOSTNAME=$(hostname -s | tr '[:upper:]' '[:lower:]')
: ${HOSTNAME:=unknown}

# Keep history files separated by year and month
# This will save the file in a '20XX.YY.history' file.
# in FreeBSD this is actually really easy, as the 'date'
# command is sane. However, since I use zsh on Cygwin as
# well, this needs to be more portable
#CURRDATE=$(date -j +%Y.%m)
#PREVDATE=$(date -j -v -1m -f %Y.%m.%d $CURRDATE.15 +%Y.%m)
CYEAR=$(date +%Y)
CMONTH=$(date +%-m)
PMONTH=$(($CMONTH - 1))

if [[ $PMONTH -eq 0 ]]
then
    PMONTH=12
    PYEAR=$(($CYEAR - 1))
else
    PYEAR=$CYEAR
fi

CURRDATE="$(printf '%d.%02d' $CYEAR $CMONTH)"
PREVDATE="$(printf '%d.%02d' $PYEAR $PMONTH)"

HISTDIR=~/.history/$HOSTNAME
mkdir -p $HISTDIR

HISTFILE=$HISTDIR/$CURRDATE.history
PREVHISTFILE=$HISTDIR/$PREVDATE.history
HISTSIZE=12000                  # Number of items to keep in memory
SAVEHIST=10000                  # Number of items to keep in file
setopt INC_APPEND_HISTORY       # Allow all shells to add to HISTFILE immediately
setopt EXTENDED_HISTORY         # Add timestamp info to HISTFILE
setopt HIST_IGNORE_ALL_DUPS     # Ignore all dups
setopt HIST_IGNORE_SPACE        # Don't save commands that beging with a space
setopt HIST_VERIFY              # Verify the history item that will be executed

# Load the previous month's history file, so we're never left
# without a history in our shell. Otherwise the 1st of the month
# would be frustrating besides just having to pay the rent.
fc -R $PREVHISTFILE

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

export CLICOLOR=1
export GREP_COLOR="0;36"

# For my own and others sanity
# git:
# %b => current branch
# %a => current action (rebase/merge)
# prompt:
# %F => color dict
# %f => reset color
# %~ => current path
# %* => time
# %n => username
# %m => shortname host
# %(?..) => prompt conditional - %(condition.true.false)

autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' check-for-changes true
zstyle :'vcs_info:git:*' get-revision true
zstyle ':vcs_info:git:*' stagedstr '%F{34} ●'
zstyle ':vcs_info:git:*' unstagedstr '%F{214} ●'
#zstyle ':vcs_info:*' nvcsformats 'non-git '
zstyle ':vcs_info:git:*' formats '%r/%S %F{cyan}%b%F{white}@%F{blue}%8.8i%m%u%c'
zstyle ':vcs_info:git*+set-message:*' hooks git-untracked git-stashed

### git: Show marker (T) if there are untracked files in repository
# Make sure you have added staged to your 'formats':  %c
function +vi-git-untracked(){
    if [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) == 'true' ]] && \
        git status --porcelain | fgrep '??' &> /dev/null ; then
        # This will show the marker if there are any untracked files in repo.
        # If instead you want to show the marker only if there are untracked
        # files in $PWD, use:
        #[[ -n $(git ls-files --others --exclude-standard) ]] ; then
        hook_com[unstaged]+='%F{160} ●'
    fi
}

function +vi-git-stashed() {
    local -a stashes

    if [[ -s ${hook_com[base]}/.git/refs/stash ]] ; then
        hook_com[misc]+='%F{63} ●'
    fi
}

setopt prompt_subst

precmd() {
    vcs_info
    local prefix

    prefix="%F{cyan}%n%F{white}@%F{blue}%m%F{white}:%F{63}"
    suffix="%F{white}%(1j. [%F{red}%j%F{white}].)%(?.. (%F{red}%?%F{white}%))
%(?.%F{77}.%F{red})%(!.❯❯.❯)%f "

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
bindkey "^R" history-incremental-pattern-search-backward

bindkey '\e.' insert-last-word

# auto-escape shell characters such as '&' and '!'
autoload -U url-quote-magic
zle -N self-insert url-quote-magic

#
# aliases
#
alias bt=transmission-remote
alias btc=bitcoin-cli
alias grep='grep --color=auto'
alias j=jobs
alias ll='ls -laFo'
