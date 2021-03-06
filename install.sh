#!/bin/sh

cfg1="zshrc,$HOME/.zshrc"
cfg2="tmux.conf,$HOME/.tmux.conf"
cfg3="profile,$HOME/.profile"
cfg4="vimrc,$HOME/.vimrc"
cfg5="irssi/config,$HOME/.irssi/config"
cfg6="irssi/fired.theme,$HOME/.irssi/fired.theme"
cfg7="scripts/tmux/dot.sh,$HOME/scripts/tmux/dot.sh"
cfg8="scripts/tmux/notifications.sh,$HOME/scripts/tmux/notifications.sh"
cfg9="scripts/tmux/membar.sh,$HOME/scripts/tmux/membar.sh"
cfg10="scripts/tmux/cpubar.sh,$HOME/scripts/tmux/cpubar.sh"
cfg11="dircolors,$HOME/.dircolors"
cfg12="minttyrc,$HOME/.minttyrc"
cfg13="zsh/funcs/decrypt,$HOME/.zsh/funcs/decrypt"
cfg14="zsh/funcs/encrypt,$HOME/.zsh/funcs/encrypt"
cfg15="zsh/funcs/get-key,$HOME/.zsh/funcs/get-key"
cfg16="zsh/funcs/hist,$HOME/.zsh/funcs/hist"
cfg17="zsh/funcs/sign,$HOME/.zsh/funcs/sign"
cfg18="zsh/funcs/verify,$HOME/.zsh/funcs/verify"

install()
{
    path=$(dirname `readlink -f $0`)
    file="$1"
    dest="$2"
    destdir=$(dirname "$dest")

    echo -n "installing $file in $dest... "

    if [ -e "$dest" ]
    then
        read -p "overwrite (y/n)? " overwrite
        [ "$overwrite" == "y" ] || return
    else
        echo
    fi

    mkdir -p $destdir
    ln -s -f $path/$file $dest
}

echo 'installing cfg files to appropriate locations'

idx=1
eval cfgfiles=\$cfg$idx

while [ -n "$cfgfiles" ]
do
    file=$(echo $cfgfiles | cut -d, -f1)
    dest=$(echo $cfgfiles | cut -d, -f2)

    read -p "install $file (y/n)? " REPLY
    [ "$REPLY" == "y" ] && install "$file" "$dest"

    idx=`expr $idx + 1`
    eval cfgfiles=\$cfg$idx
done
