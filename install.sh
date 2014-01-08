#!/bin/sh

cfg1="tmux.conf,$HOME/.tmux.conf"
cfg2="profile,$HOME/.profile"
cfg3="vimrc,$HOME/.vimrc"

install()
{
    path=$(dirname `readlink -f $0`)
    file="$1"
    dest="$2"

    echo -n "installing $file in $dest... "

    if [ -e "$dest" ]
    then
        read -p "overwrite (y/n)? " overwrite
        [ "$overwrite" == "y" ] || return
    else
        echo
    fi

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
