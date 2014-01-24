PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin:$HOME/bin; export PATH

# Setting TERM is normally done through /etc/ttys.  Do only override
# if you're sure that you'll never log in via telnet or xterm or a
# serial line.
# TERM=xterm; 	export TERM

BLOCKSIZE=K;    export BLOCKSIZE
EDITOR=vim;     export EDITOR
PAGER=less;     export PAGER
GIT_PAGER=less  export GIT_PAGER

# unset the MAIL var, the tmux status bar will be used to check for mail
unset MAIL

# use fancy colors in `ls`
CLICOLOR=yes;   export CLICOLOR
LSCOLORS=Bxfxcxdxbxegedabagacad;    export LSCOLORS

# set ENV to a file invoked each time sh is started for interactive use.
ENV=$HOME/.shrc; export ENV

# Aliases
alias tmux='tmux -2'
