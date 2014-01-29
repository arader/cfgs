#!/bin/sh

cfg1="tmux.conf,$HOME/.tmux.conf"
cfg2="profile,$HOME/.profile"
cfg3="vimrc,$HOME/.vimrc"
cfg4="irssi/config,$HOME/.irssi/config"
cfg5="irssi/fired.theme,$HOME/.irssi/fired.theme"
cfg6="scripts/tmux/dot.sh,$HOME/scripts/tmux/dot.sh"
cfg7="scripts/tmux/notifications.sh,$HOME/scripts/tmux/notifications.sh"

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
