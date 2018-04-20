########
# Core functionality
##
autoload -Uz add-zsh-hook

if [[ ! -a ~/.zsh-async ]]
then
    git clone -b 'v1.6.0' git@github.com:mafredri/zsh-async ~/.zsh-async
fi
source ~/.zsh-async/async.zsh

function prompt() {
    local prefix
    local middle
    local suffix

    prefix="%F{cyan}%n%F{white}@%F{blue}%m%F{white}:%F{63}"
    middle=${1:=%~}
    suffix="%F{white}%(1j. [%F{red}%j%F{white}].)%(?.. (%F{red}%?%F{white}%))
%(?.%F{77}.%F{red})%(!.❯❯.❯)%f "

    print -n $prefix$middle$suffix
}

function git_prompt() {
    local branch
    local commit
    local parent
    local state

    parent=$(git -C "$1" rev-parse --show-toplevel | xargs dirname)
    curr=${1#parent/}
    branch=${$(git -C "$1" symbolic-ref HEAD 2>/dev/null)#refs/heads/}
    commit=$(git -C "$1" rev-parse HEAD | cut -c 1-7)
    state=$(git -C "$1" status --porcelain 2>/dev/null)

    print -n "$curr %F{cyan}$branch%F{white}@%F{blue}$commit"

    if [[ ! -z $(echo $state | grep -o "^ M\|^ R") ]]
    then
        print -n '%F{214} ●'
    fi

    if [[ ! -z $(echo $state | grep -o "^M\|^R") ]]
    then
        print -n '%F{34} ●'
    fi

    if [[ ! -z $(echo $state | grep -o "^??") ]]
    then
        print -n '%F{160} ●'
    fi

    if [[ -s "$1/.git/refs/stash" ]]
    then
        print -n '%F{63} ●'
    fi
}

function async_prompt() {
    if [[ $(\git -C "$1" branch 2>/dev/null) != "" ]]
    then
        git_prompt $1
    fi
}

async_init
async_start_worker prompt_worker -n

prompt_callback() {
    if [[ $2 == 0 ]]
    then
        PROMPT=$(prompt $3)
    else
        PROMPT=$@
    fi

    zle && zle reset-prompt
}

async_register_callback prompt_worker prompt_callback

########
# Shell History
##

# Store the current hostname or 'unknown' if we can't
# get one for some crazy reason
HISTHOST=$(hostname -s | tr '[:upper:]' '[:lower:]')
: ${HISTHOST:=unknown}

# Keep history files separated by year and month
# This will save the file in a '20XX.YY.history' file.
# in FreeBSD this is actually really easy, as the 'date'
# command is sane. However, since I use zsh on Cygwin as
# well, this needs to be more portable
#CURRDATE=$(date -j +%Y.%m)
#PREVDATE=$(date -j -v -1m -f %Y.%m.%d $CURRDATE.15 +%Y.%m)

HISTDIR=~/.history/$HISTHOST
mkdir -p $HISTDIR

function update_histfile() {
    CURRMONTH=$(date +%-m)

    if [[ $HISTMONTH != $CURRMONTH ]]
    then
        HISTYEAR=$(date +%Y)
        HISTMONTH=$CURRMONTH

        CURRDATE="$(printf '%d.%02d' $HISTYEAR $HISTMONTH)"

        HISTFILE=$HISTDIR/$CURRDATE.history
    fi
}

update_histfile
HISTSIZE=12000                  # Number of items to keep in memory
SAVEHIST=10000                  # Number of items to keep in file
setopt INC_APPEND_HISTORY       # Allow all shells to add to HISTFILE immediately
setopt EXTENDED_HISTORY         # Add timestamp info to HISTFILE
setopt HIST_IGNORE_ALL_DUPS     # Ignore all dups
setopt HIST_IGNORE_SPACE        # Don't save commands that beging with a space
setopt HIST_VERIFY              # Verify the history item that will be executed

# Load as much old history as we can, so we're never left
# without a history in our shell. Otherwise the 1st of the month
# would be frustrating besides just having to pay the rent.
for histfile in $HISTDIR/*.history(N)
do
    fc -R $histfile
done

bindkey -v
export KEYTIMEOUT=1

zstyle :compinstall filename '/home/andrew/.zshrc'

add-zsh-hook precmd update_histfile

zle -N zle-line-init
zle -N zle-keymap-select

autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search # Up
bindkey "^[[B" down-line-or-beginning-search # Down
bindkey "^R" history-incremental-pattern-search-backward

bindkey '\e.' insert-last-word

# auto-escape shell characters such as '&' and '!'
autoload -U url-quote-magic
zle -N self-insert url-quote-magic

########
# Autocomplete
##

autoload -Uz compinit
compinit
setopt NO_BEEP                      # Don't beep for any reason
unsetopt LIST_BEEP                  # Don't beep on completion inserts
zstyle ':completion:*' menu select  # Show a menu for completion values

if [[ -d ~/.zsh/zsh-autosuggestions ]]
then
    source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=blue"

    # Specify a max buffer size. This helps issues with slow pasting
    ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=12
fi

########
# Scripts & Functions
##

fpath=(~/dev/scripts/zsh/funcs $fpath)

# autoload all executable scripts
if [[ -d ~/dev/scripts/zsh/funcs ]]
then
    for func in ~/dev/scripts/zsh/funcs/*(N-.x:t); do
        unhash -f $func 2>/dev/null
        autoload +X $func
    done
fi

########
# Colors
##

autoload -U colors
colors

export CLICOLOR=1
export GREP_COLOR="0;36"

########
# Prompt
##

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
    async_job prompt_worker async_prompt $(pwd)
    PROMPT=$(prompt)
}
RPROMPT=""

function zle-line-init zle-keymap-select {
    VIM_PROMPT="%{$fg_bold[yellow]%} [% EDIT]%  %{$reset_color%}"
    RPROMPT="${${KEYMAP/vicmd/$VIM_PROMPT}/(main|viins)/} $EPS1"
    zle reset-prompt
}

########
# Aliases
##

alias bt=transmission-remote
alias btc=bitcoin-cli
alias grep='grep --color=auto'
alias j=jobs
alias ll='ls -laFo'
alias qr=qrcli
