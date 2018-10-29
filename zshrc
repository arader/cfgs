########
# Core functionality
##
autoload -Uz add-zsh-hook

typeset -A symbols
#symbols=(
#    BUSY                        '\uf251  '
#    GIT_RM                      '\uf458  '
#    GIT_MOD                     '\uf459  '
#    GIT_ADD                     '\uf457  '
#    GIT_RENAME                  '\uf45a  '
#    GIT_STASH                   '\uf53b  '
#    WEATHER_CLEAR               '\ue30d  '
#    WEATHER_CLEAR_NIGHT         '\ue32b  '
#    WEATHER_RAIN                '\ue318  '
#    WEATHER_SNOW                '\ue31a  '
#    WEATHER_SLEET               '\ue3ad  '
#    WEATHER_WIND                '\ue34b  '
#    WEATHER_FOG                 '\ue313  '
#    WEATHER_CLOUDY              '\ue312  '
#    WEATHER_PARTLY_CLOUDY       '\ue302  '
#    WEATHER_PARTLY_CLOUDY_NIGHT '\ue37e  '
#    WEATHER_UNKNOWN             '\ue374  '
#    COMMUTE_TIME_PREFIX         '\uf1b9 '
#    COMMUTE_TIME_SUFFIX         ''
#    )
symbols=(
    BUSY                        '...'
    GIT_RM                      'D'
    GIT_MOD                     'M'
    GIT_ADD                     'A'
    GIT_RENAME                  'R'
    GIT_STASH                   'S'
    WEATHER_CLEAR               'CLEAR'
    WEATHER_CLEAR_NIGHT         'CLEAR'
    WEATHER_RAIN                'RAIN'
    WEATHER_SNOW                'SNOW'
    WEATHER_SLEET               'SLEET'
    WEATHER_WIND                'WIND'
    WEATHER_FOG                 'FOG'
    WEATHER_CLOUDY              'CLOUDY'
    WEATHER_PARTLY_CLOUDY       'CLOUDY'
    WEATHER_PARTLY_CLOUDY_NIGHT 'CLOUDY'
    WEATHER_UNKNOWN             'NA'
    COMMUTE_TIME_PREFIX         ''
    COMMUTE_TIME_SUFFIX         ' min'
    )

trips=(102 83)

if [[ ! -a ~/.zsh/zsh-async ]]
then
    git clone -b 'v1.7.1' git@github.com:mafredri/zsh-async.git ~/.zsh/zsh-async
fi
source ~/.zsh/zsh-async/async.zsh

if [[ ! -a ~/.zsh/fast-syntax-highlighting ]]
then
    git clone git@github.com:zdharma/fast-syntax-highlighting.git ~/.zsh/fast-syntax-highlighting
fi
source ~/.zsh/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh

if [[ ! -a ~/.zsh/zsh-autosuggestions ]]
then
    git clone git@github.com:zsh-users/zsh-autosuggestions.git ~/.zsh/zsh-autosuggestions
fi
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

function prompt() {
    local prefix
    local middle
    local suffix
    local busy

    if [[ $PROMPT_GIT_BUSY == 1 ]]
    then
        busy=$symbols[BUSY]
    fi

    prefix="%F{cyan}%n%F{white}@%F{blue}%m%F{white}:"
    middle="%F{63}$PROMPT_GIT %F{white}$PROMPT_WEATHER %F{cyan}$PROMPT_COMMUTE"
    suffix="%F{white}%(1j. [%F{red}%j%F{white}].)%(?.. (%F{red}%?%F{white}%))   $busy
%(?.%F{77}.%F{red})%(!.❯❯.❯)%f "

    print -n $prefix$middle$suffix
}

PROMPT_GIT_BUSY=0
function queue_prompt_git() {
    PROMPT_GIT_BUSY=1
    async_job prompt_worker prompt_git $(pwd)
}

function prompt_git() {
    local branch
    local commit
    local parent
    local curr
    local state

    print -n 'PROMPT_GIT '

    if [[ $(\git -C "$1" branch 2>/dev/null) == "" ]]
    then
        print -n '%~'
        return
    fi

    parent=$(git -C "$1" rev-parse --show-toplevel | xargs dirname)
    curr=${1#$parent/}
    branch=${$(git -C "$1" symbolic-ref HEAD 2>/dev/null)#refs/heads/}
    commit=$(git -C "$1" rev-parse HEAD | cut -c 1-7)
    state=$(git -C "$1" status --porcelain 2>/dev/null)

    print -n "$curr %F{cyan}$branch%F{white}@%F{blue}$commit"

    if [[ ! -z $(echo $state | grep -o "^ D") ]]
    then
        print -n "%F{yellow} $symbols[GIT_RM] "
    fi

    if [[ ! -z $(echo $state | grep -o "^ M") ]]
    then
        print -n "%F{yellow} $symbols[GIT_MOD] "
    fi

    if [[ ! -z $(echo $state | grep -o "^??") ]]
    then
        print -n "%F{yellow} $symbols[GIT_ADD] "
    fi

    if [[ ! -z $(echo $state | grep -o "^D") ]]
    then
        print -n "%F{green} $symbols[GIT_RM] "
    fi

    if [[ ! -z $(echo $state | grep -o "^M") ]]
    then
        print -n "%F{green} $symbols[GIT_MOD] "
    fi

    if [[ ! -z $(echo $state | grep -o "^R") ]]
    then
        print -n "%F{green} $symbols[GIT_RENAME] "
    fi

    if [[ ! -z $(echo $state | grep -o "^A") ]]
    then
        print -n "%F{green} $symbols[GIT_ADD] "
    fi

    if [[ -s "$1/.git/refs/stash" ]]
    then
        print -n "%F{green} $symbols[GIT_STASH]"
    fi
}

function queue_prompt_weather() {
    [[ -f ~/.darksky.key ]] &&
        [[ -f ~/.darksky.loc ]] &&
        async_job prompt_worker prompt_weather
}

function prompt_weather() {
    local icon
    DARKSKY_KEY=${DARKSKY_KEY:=$(cat ~/.darksky.key)}
    DARKSKY_LOC=${DARKSKY_LOC:=$(cat ~/.darksky.loc)}

    [[ -z $DARKSKY_KEY ]] && exit 0
    [[ -z $DARKSKY_LOC ]] && exit 0

    print -n 'PROMPT_WEATHER '

    forecast=$(curl -s https://api.darksky.net/forecast/$DARKSKY_KEY/$DARKSKY_LOC,$(($(date +%s) + 900))\?exclude\=minutely,hourly,daily,alerts,flags)
    degrees=$(echo $forecast | sed -e 's/.*"temperature":\([0-9]*\).*/\1/')
    icon=$(echo $forecast | sed -e 's/.*"icon":"\([^"]*\)".*/\1/')

    print -n "$degrees\u00b0 "

    if [[ "$icon" == "clear-day" ]]
    then
        print -n "$symbols[WEATHER_CLEAR]"
    elif [[ "$icon" == "clear-night" ]]
    then
        print -n "$symbols[WEATHER_CLEAR_NIGHT]"
    elif [[ "$icon" == "rain" ]]
    then
        print -n "$symbols[WEATHER_RAIN]"
    elif [[ "$icon" == "snow" ]]
    then
        print -n "$symbols[WEATHER_SNOW]"
    elif [[ "$icon" == "sleet" ]]
    then
        print -n "$symbols[WEATHER_SLEET]"
    elif [[ "$icon" == "wind" ]]
    then
        print -n "$symbols[WEATHER_WIND]"
    elif [[ "$icon" == "fog" ]]
    then
        print -n "$symbols[WEATHER_FOG]"
    elif [[ "$icon" == "cloudy" ]]
    then
        print -n "$symbols[WEATHER_CLOUDY]"
    elif [[ "$icon" == "partly-cloudy-day" ]]
    then
        print -n "$symbols[WEATHER_PARTLY_CLOUDY]"
    elif [[ "$icon" == "partly-cloudy-night" ]]
    then
        print -n "$symbols[WEATHER_PARTLY_CLOUDY_NIGHT]"
    else
        print -n "$symbols[WEATHER_UNKNOWN]"
    fi
}

function queue_prompt_commute() {
    [[ -f ~/.wsdot.key ]] && async_job prompt_worker prompt_commute
}

function prompt_commute {
    WSDOT_KEY=${WSDOT_KEY:=$(cat ~/.wsdot.key)}

    [[ -z $WSDOT_KEY ]] && exit 0

    print -n 'PROMPT_COMMUTE '

    local total
    total=0

    for trip in $trips
    do
        trip_time=$(curl -s http://www.wsdot.wa.gov/Traffic/api/TravelTimes/TravelTimesREST.svc/GetTravelTimeAsJson\?AccessCode=$WSDOT_KEY\&TravelTimeId=$trip | sed -e 's/.*"CurrentTime":\([0-9.]*\).*/\1/')
        total=$(($total + $trip_time))
    done

    print -n "$symbols[COMMUTE_TIME_PREFIX]$total$symbols[COMMUTE_TIME_SUFFIX]"
}

async_init
async_start_worker prompt_worker -n

prompt_callback() {
    if [[ $2 == 0 ]]
    then
        if [[ ! -z $3 ]]
        then
            output=$3
            # Okay, yes this looks absolutely crazy, but all this
            # is doing is: take the first word in the output
            # and treat it as a variable name. Assign the rest of
            # the output to the variable with that name
            # This makes it so that any async prompt function can
            # update only a section of the prompt, instead of
            # overwriting the whole prompt
            eval "$output[(w)1]='${output#$output[(w)1] }'"
            eval "$output[(w)1]_BUSY=0"
            PROMPT=$(prompt)
        fi
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

########
# Autocomplete
##

autoload -Uz compinit
compinit
setopt NO_BEEP                      # Don't beep for any reason
unsetopt LIST_BEEP                  # Don't beep on completion inserts
zstyle ':completion:*' menu select  # Show a menu for completion values

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=blue"

# Specify a max buffer size. This helps issues with slow pasting
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=12

########
# Scripts & Functions
##

fpath=(~/.zsh/funcs $fpath)

# autoload all executable scripts
if [[ -d ~/.zsh/funcs ]]
then
    for func in ~/.zsh/funcs/*(N-.x:t); do
        unhash -f $func 2>/dev/null
        autoload +X $func
    done
fi

########
# Colors
##

autoload -U colors
colors

if [[ -a ~/.dircolors ]]
then
    eval $(dircolors ~/.dircolors)
fi

export CLICOLOR=1
export LSCOLORS=exfxgxgxcxbxbxbxBxGxdx
export GREP_COLOR="0;36"

########
# Prompt
##

setopt prompt_subst

precmd() {
    queue_prompt_git
    PROMPT=$(prompt)
}
RPROMPT=""

PERIOD=30
add-zsh-hook periodic queue_prompt_weather
add-zsh-hook periodic queue_prompt_commute

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
