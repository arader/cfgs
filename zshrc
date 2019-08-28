########
# Variables
##

typeset -A symbols
symbols=(
    BUSY                        '\uf251  '
    ERROR                       '\ufad5'
    GIT_RM                      '\uf458  '
    GIT_MOD                     '\uf459  '
    GIT_ADD                     '\uf457  '
    GIT_RENAME                  '\uf45a  '
    GIT_STASH                   '\uf53b  '
    ALERTING                    '\uf7d3 '
    WEATHER_CLEAR               '\ue30d  '
    WEATHER_CLEAR_NIGHT         '\ue32b  '
    WEATHER_RAIN                '\ue318  '
    WEATHER_SNOW                '\ue31a  '
    WEATHER_SLEET               '\ue3ad  '
    WEATHER_WIND                '\ue34b  '
    WEATHER_FOG                 '\ue313  '
    WEATHER_CLOUDY              '\ue312  '
    WEATHER_PARTLY_CLOUDY       '\ue302  '
    WEATHER_PARTLY_CLOUDY_NIGHT '\ue37e  '
    WEATHER_UNKNOWN             '\ue374  '
    COMMUTE_TIME_PREFIX         '\uf1b9 '
    COMMUTE_TIME_SUFFIX         ''
    )
#symbols=(
#    BUSY                        '...'
#    ERROR                       '!'
#    GIT_RM                      'D'
#    GIT_MOD                     'M'
#    GIT_ADD                     'A'
#    GIT_RENAME                  'R'
#    GIT_STASH                   'S'
#    ALERTING                    '!!'
#    WEATHER_CLEAR               'CLEAR'
#    WEATHER_CLEAR_NIGHT         'CLEAR'
#    WEATHER_RAIN                'RAIN'
#    WEATHER_SNOW                'SNOW'
#    WEATHER_SLEET               'SLEET'
#    WEATHER_WIND                'WIND'
#    WEATHER_FOG                 'FOG'
#    WEATHER_CLOUDY              'CLOUDY'
#    WEATHER_PARTLY_CLOUDY       'CLOUDY'
#    WEATHER_PARTLY_CLOUDY_NIGHT 'CLOUDY'
#    WEATHER_UNKNOWN             'NA'
#    COMMUTE_TIME_PREFIX         ''
#    COMMUTE_TIME_SUFFIX         ' min'
#    )

trips=(102 83)

########
# Dependencies
##

autoload -Uz add-zsh-hook

if [[ ! -a ~/.zsh/zsh-async ]]
then
    git clone -b 'v1.7.2' git@github.com:mafredri/zsh-async.git ~/.zsh/zsh-async
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

########
# Async Prompt Helpers
##

typeset -A PROMPTS
typeset -A PROMPTS_STATES
typeset -A PROMPTS_COUNTS
typeset -A PROMPTS_ERRORS

function start_prompt() {
    async_init
    async_register_callback prompt_worker prompt_callback
    async_start_worker prompt_worker
}

function queue_prompt() {
    local prompt_id
    prompt_id=$1
    shift
    PROMPTS_STATES[$prompt_id]="busy"
    let "PROMPTS_COUNTS[$prompt_id] = $PROMPTS_COUNTS[$prompt_id] + 1"
    async_job prompt_worker _async_prompt_worker $prompt_id $PROMPTS_COUNTS[$prompt_id] $@
}

function _async_prompt_worker() {
    local prompt_id
    prompt_id=$1
    shift
    print -n "$prompt_id $1 "
    shift
    eval $prompt_id $@
}

function prompt_callback() {
    # The callback is invoked with the following parameters
    # $1: job name, should be '_async_prompt_worker'
    # $2: job return code
    # $3: stdout of worker. '_async_prompt_worker' will output the following:
    #       prompt_id prompt_instance worker_output
    # $4: job execution time
    # $5: stderr of job
    # $6: 0 if job result buffer is empty, 1 if there are more jobs
    local output=$3
    local prompt_id=$output[(w)1]
    local prompt_instance=$output[(w)2]
    output=${output#$prompt_id $prompt_instance }

    if [[ $prompt_instance != $PROMPTS_COUNTS[$prompt_id] ]]
    then
        # Only process the latest instance of this prompt job
        return
    fi

    if [[ $2 == 0 ]]
    then
        PROMPTS[$prompt_id]=$output
        PROMPTS_STATES[$prompt_id]="done"
        PROMPTS_ERRORS[$prompt_id]=""
    else
        PROMPTS[$prompt_id]=""
        PROMPTS_STATES[$prompt_id]="error"
        PROMPTS_ERRORS[$prompt_id]=$@
    fi

    PROMPT=$(prompt)

    # '$6' is the number of async function results in the queue.
    # if this is the last result, reset the prompt
    if [[ $6 == 0 ]]
    then
        zle && zle reset-prompt
    fi
}

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
# Async Prompts
##

function queue_prompt_git() {
    queue_prompt prompt_git "$(pwd)"
}

function prompt_git() {
    local branch
    local commit
    local parent
    local curr
    local state

    if [[ $(\git -C "$1" branch 2>/dev/null) == "" ]]
    then
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

function queue_prompt_grafana_alerts() {
    [[ -f ~/.grafana.key ]] &&
        queue_prompt prompt_grafana_alerts
}

function prompt_grafana_alerts() {
    GRAFANA_KEY=${GRAFANA_KEY:=$(cat ~/.grafana.key)}
    GRAFANA_HOST=${GRAFANA_HOST:=$(cat ~/.grafana.host)}

    curl -s -H "Authorization: Bearer $GRAFANA_KEY" "https://$GRAFANA_HOST/api/alerts?state=alerting" | grep -qv \"id\" || print -n $symbols[ALERTING]
}

function queue_prompt_weather() {
    [[ -f ~/.darksky.key ]] &&
        [[ -f ~/.darksky.loc ]] &&
        queue_prompt prompt_weather
}

function prompt_weather() {
    local icon
    DARKSKY_KEY=${DARKSKY_KEY:=$(cat ~/.darksky.key)}
    DARKSKY_LOC=${DARKSKY_LOC:=$(cat ~/.darksky.loc)}

    [[ -z $DARKSKY_KEY ]] && exit 0
    [[ -z $DARKSKY_LOC ]] && exit 0

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
    [[ -f ~/.wsdot.key ]] && [[ $(hostname -f) == *".corp."* ]] && queue_prompt prompt_commute
}

function prompt_commute {
    WSDOT_KEY=${WSDOT_KEY:=$(cat ~/.wsdot.key)}

    if [[ -z $WSDOT_KEY ]]
    then
        exit 0
    fi

    local total
    total=0

    for trip in $trips
    do
        trip_time=$(curl -s https://www.wsdot.wa.gov/Traffic/api/TravelTimes/TravelTimesREST.svc/GetTravelTimeAsJson\?AccessCode=$WSDOT_KEY\&TravelTimeId=$trip | sed -e 's/.*"CurrentTime":\([0-9.]*\).*/\1/')
        total=$(($total + $trip_time))
    done

    print -n "$symbols[COMMUTE_TIME_PREFIX]$total$symbols[COMMUTE_TIME_SUFFIX]"
}

########
# Prompt
##

setopt prompt_subst

start_prompt

precmd() {
    queue_prompt_git
    queue_prompt_grafana_alerts
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

function prompt() {
    local prefix
    local middle
    local suffix
    local busy
    local pwdinfo

    for key val in ${(kv)PROMPTS_STATES}
    do
        if [[ $val == "busy" ]]
        then
            busy=$symbols[BUSY]
        elif [[ $val == "error" ]]
        then
            err=$symbols[ERROR]
        fi
    done

    pwdinfo="%~"

    if [[ $PROMPTS_STATES[prompt_git] != "busy" ]] && [[ ! -z $PROMPTS[prompt_git] ]]
    then
        pwdinfo=$PROMPTS[prompt_git]
    fi

    prefix="%F{cyan}%n%F{white}@%F{blue}%m%F{white}:"
    middle="%F{63}$pwdinfo %F{white}$PROMPTS[prompt_weather]%F{cyan}$PROMPTS[prompt_commute]"
    suffix="%F{white}%(1j. [%F{red}%j%F{white}].)%(?.. (%F{red}%?%F{white}%))$busy
%F{red}$err$PROMPTS[prompt_grafana_alerts]%(?.%F{77}.%F{red})%(!.❯❯.❯)%f "

    print -n $prefix$middle$suffix
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
